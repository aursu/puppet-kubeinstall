# @summary CRI-O repository setup
#
# CRI-O repository setup
#
# @example
#   include kubeinstall::repos::crio
class kubeinstall::repos::crio (
  Kubeinstall::Release $kuberel = $kubeinstall::kubernetes_release,
  Variant[
    Enum['installed', 'latest'],
    Pattern[/^1\.[0-9]+\.[0-9]+(~[0-9]+)?$/]
  ] $crio_version = $kubeinstall::crio_version,
) inherits kubeinstall::params {
  include bsys::params

  if $crio_version in ['installed', 'latest'] {
    $criorel = $kuberel
  }
  else {
    if $bsys::params::osname == 'Ubuntu' {
      $version_data  = split($crio_version, '[~]')
      if $version_data[1] {
        $criorel = $version_data[0]
      }
      else {
        $criorel = $crio_version
      }
    }
    else {
      $criorel = $crio_version
    }
  }

  # https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o
  $osname = $facts['os']['name']
  $osmaj  = $facts['os']['release']['major']

  if $osname == 'CentOS' {
    if $bsys::params::centos_stream {
      $os = "${osname}_${osmaj}_Stream"
    }
    else {
      $os = "${osname}_${osmaj}"
    }

    yumrepo { 'devel_kubic_libcontainers_stable':
      ensure   => 'present',
      baseurl  => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${os}/",
      descr    => "Stable Releases of Upstream github.com/containers packages (${os})",
      enabled  => '1',
      gpgcheck => '1',
      gpgkey   => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${os}/repodata/repomd.xml.key",
    }

    yumrepo { "devel_kubic_libcontainers_stable_cri-o_${criorel}":
      ensure   => 'present',
      baseurl  => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${criorel}/${os}/",
      descr    => "devel:kubic:libcontainers:stable:cri-o:${criorel} (${os})",
      enabled  => '1',
      gpgcheck => '1',
      gpgkey   => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${criorel}/${os}/repodata/repomd.xml.key",
    }
  }
  elsif $osname == 'Ubuntu' {
    $os = "x${osname}_${osmaj}"

    # https://github.com/cri-o/cri-o/blob/main/install.md#apt-based-operating-systems
    apt::source { 'devel:kubic:libcontainers:stable':
      comment  => 'packaged versions of CRI-O',
      location => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${os}/",
      release  => '', # no release folder
      repos    => '/',
      key      => {
        id     => '2472D6D0D2F66AF87ABA8DA34D64390375060AA4',
        source => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${os}/Release.key",
        ensure => 'refreshed',
      },
    }

    apt::source { "devel:kubic:libcontainers:stable:cri-o:${criorel}":
      comment  => "packaged versions of CRI-O for Kubernetes ${criorel}",
      location => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${criorel}/${os}/",
      release  => '',
      repos    => '/',
      key      => {
        id     => '2472D6D0D2F66AF87ABA8DA34D64390375060AA4',
        source => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${os}/Release.key",
        ensure => 'refreshed',
      },
    }
  }
}
