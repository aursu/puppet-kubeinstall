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
  }
  else {
    # installed, latest
    $criorel = $kubernetes_release
  }

  # https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o
  $osname = $facts['os']['name']

  if $osname in ['CentOS', 'Rocky'] {
    yumrepo { 'cri-o':
      ensure   => 'present',
      baseurl  => "https://pkgs.k8s.io/addons:/cri-o:/stable:/v${criorel}/rpm/",
      descr    => 'CRI-O',
      enabled  => '1',
      gpgcheck => '1',
      gpgkey   => "https://pkgs.k8s.io/addons:/cri-o:/stable:/v${criorel}/rpm/repodata/repomd.xml.key",
    }
  }
  elsif $osname == 'Ubuntu' {
    # https://github.com/cri-o/packaging/blob/main/README.md#usage
    exec { "curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/v${criorel}/deb/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/cri-o-v${criorel}-apt-keyring.gpg":
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
}
