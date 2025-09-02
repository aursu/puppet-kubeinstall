# @summary CRI-O repository setup
#
# CRI-O repository setup
#
# @example
#   include kubeinstall::repos::crio
class kubeinstall::repos::crio (
  Kubeinstall::Release $kubernetes_release = $kubeinstall::kubernetes_release,
  Variant[
    Enum['installed', 'latest'],
    Pattern[/^1\.[0-9]+\.[0-9]+(~[0-9]+)?$/]
  ] $crio_version = $kubeinstall::crio_version,
) inherits kubeinstall::params {
  include bsys::params

  $version_data = split($crio_version, '[.]')
  if $version_data[1] {
    $major_version = $version_data[0]
    $minor_version = $version_data[1]

    # crio_release is CRI-O version up to minor part
    $criorel = "${major_version}.${minor_version}"
    $crio_release = $crio_version
  }
  else {
    # installed, latest
    $criorel = $kubernetes_release
    $crio_release = "${criorel}.0"
  }

  # https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o
  $osname = $facts['os']['name']
  $osmaj  = $facts['os']['release']['major']

  if $osname in ['CentOS', 'Rocky'] {
    if versioncmp($crio_release, '1.33.0') >= 0 {
      yumrepo { 'cri-o':
        ensure   => 'present',
        baseurl  => "https://download.opensuse.org/repositories/isv:/cri-o:/stable:/v${criorel}/rpm/",
        descr    => 'CRI-O',
        enabled  => '1',
        gpgcheck => '1',
        gpgkey   => "https://download.opensuse.org/repositories/isv:/cri-o:/stable:/v${criorel}/rpm/repodata/repomd.xml.key",
      }
    }
    elsif versioncmp($crio_release, '1.28.2') >= 0 {
      yumrepo { 'cri-o':
        ensure   => 'present',
        baseurl  => "https://pkgs.k8s.io/addons:/cri-o:/stable:/v${criorel}/rpm/",
        descr    => 'CRI-O',
        enabled  => '1',
        gpgcheck => '1',
        gpgkey   => "https://pkgs.k8s.io/addons:/cri-o:/stable:/v${criorel}/rpm/repodata/repomd.xml.key",
      }
    }
    else {
      if $osmaj in ['8', '9'] {
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
  }
  elsif $osname == 'Ubuntu' {
    if versioncmp($crio_release, '1.33.0') >= 0 {
      exec { "curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/v${criorel}/deb/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/cri-o-v${criorel}-apt-keyring.gpg":
        path   => '/usr/bin:/bin',
        unless => "gpg /etc/apt/trusted.gpg.d/cri-o-v${criorel}-apt-keyring.gpg",
        before => Apt::Source['cri-o'],
      }

      apt::source { 'cri-o':
        comment  => 'cri-o apt repository',
        location => "https://download.opensuse.org/repositories/isv:/cri-o:/stable:/v${criorel}/deb/",
        release  => '',
        repos    => '/',
        keyring  => "/etc/apt/trusted.gpg.d/cri-o-v${criorel}-apt-keyring.gpg",
      }
    }
    elsif versioncmp($crio_release, '1.28.2') >= 0 {
      $keyrel = $criorel ? {
        '1.28' => '1.29',
        default => $criorel,
      }

      # https://github.com/cri-o/packaging/blob/main/README.md#usage
      exec { "curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/v${keyrel}/deb/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/cri-o-v${criorel}-apt-keyring.gpg":
        path   => '/usr/bin:/bin',
        unless => "gpg /etc/apt/trusted.gpg.d/cri-o-v${criorel}-apt-keyring.gpg",
        before => Apt::Source['cri-o'],
      }

      apt::source { 'cri-o':
        comment  => 'cri-o apt repository',
        location => "https://pkgs.k8s.io/addons:/cri-o:/stable:/v${criorel}/deb/",
        release  => '',
        repos    => '/',
        keyring  => "/etc/apt/trusted.gpg.d/cri-o-v${criorel}-apt-keyring.gpg",
      }
    }
    else {
      if $osmaj == '24.04' {
        $os = "x${osname}_22.04"
      }
      else {
        $os = "x${osname}_${osmaj}"
      }

      exec { "curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${os}/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/devel-kubic-libcontainers-stable-apt-keyring.gpg":
        path   => '/usr/bin:/bin',
        unless => 'gpg /etc/apt/trusted.gpg.d/devel-kubic-libcontainers-stable-apt-keyring.gpg',
        before => Apt::Source['devel:kubic:libcontainers:stable'],
      }

      # https://github.com/cri-o/cri-o/blob/main/install.md#apt-based-operating-systems
      apt::source { 'devel:kubic:libcontainers:stable':
        comment  => 'packaged versions of CRI-O',
        location => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${os}/",
        release  => '',
        repos    => '/',
        keyring  => '/etc/apt/trusted.gpg.d/devel-kubic-libcontainers-stable-apt-keyring.gpg',
      }

      apt::source { "devel:kubic:libcontainers:stable:cri-o:${criorel}":
        comment  => "packaged versions of CRI-O for Kubernetes ${criorel}",
        location => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${criorel}/${os}/",
        release  => '',
        repos    => '/',
        keyring  => '/etc/apt/trusted.gpg.d/devel-kubic-libcontainers-stable-apt-keyring.gpg',
      }
    }
  }
}
