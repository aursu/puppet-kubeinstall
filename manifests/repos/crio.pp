# @summary CRI-O repository setup
#
# CRI-O repository setup
#
# @example
#   include kubeinstall::repos::crio
class kubeinstall::repos::crio (
  Kubeinstall::Release $kuberel = $kubeinstall::kubernetes_release,
) inherits kubeinstall::params {
  # https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o
  $osname = $facts['os']['name']
  $osmaj  = $facts['os']['release']['major']
  $centos_stream = $kubeinstall::params::centos_stream

  if $osname == 'CentOS' {
    if $centos_stream {
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

    yumrepo { "devel_kubic_libcontainers_stable_cri-o_${kuberel}":
      ensure   => 'present',
      baseurl  => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${kuberel}/${os}/",
      descr    => "devel:kubic:libcontainers:stable:cri-o:${kuberel} (${os})",
      enabled  => '1',
      gpgcheck => '1',
      gpgkey   => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${kuberel}/${os}/repodata/repomd.xml.key",
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

    apt::source { "devel:kubic:libcontainers:stable:cri-o:${kuberel}":
      comment  => "packaged versions of CRI-O for Kubernetes ${kuberel}",
      location => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${kuberel}/${os}/",
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
