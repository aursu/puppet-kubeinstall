# @summary Setup Kubernetes repositories
#
# Setup Kubernetes repositories
#
# @example
#   include kubeinstall::repos
class kubeinstall::repos (
  Kubeinstall::Release $kuberel = $kubeinstall::kubernetes_release,
) {
  include bsys::repo

  if $facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'], '7') >= 0 {
    yumrepo { 'kubernetes':
      ensure   => 'present',
      baseurl  => "https://pkgs.k8s.io/core:/stable:/v${kuberel}/rpm/",
      descr    => 'Kubernetes',
      enabled  => '1',
      gpgcheck => '1',
      gpgkey   => "https://pkgs.k8s.io/core:/stable:/v${kuberel}/rpm/repodata/repomd.xml.key",
    }

    Yumrepo['kubernetes'] ~> Class['bsys::repo']
  }
  elsif $facts['os']['name'] == 'Ubuntu' {
    $dist = $facts['os']['distro']['codename']

    exec { "curl -fsSL https://pkgs.k8s.io/core:/stable:/v${kuberel}/deb/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-v${kuberel}-apt-keyring.gpg":
      path   => '/usr/bin:/bin',
      unless => "gpg /etc/apt/trusted.gpg.d/kubernetes-v${kuberel}-apt-keyring.gpg",
      before => Apt::Source['kubernetes'],
    }

    apt::source { 'kubernetes':
      comment  => 'Kubernetes apt repository',
      location => "https://pkgs.k8s.io/core:/stable:/v${kuberel}/deb/",
      release  => '',
      repos    => '/',
      keyring  => "/etc/apt/trusted.gpg.d/kubernetes-v${kuberel}-apt-keyring.gpg",
    }

    Apt::Source['kubernetes'] ~> Class['bsys::repo']
  }
}
