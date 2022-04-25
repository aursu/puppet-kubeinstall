# @summary Setup Kubernetes repositories
#
# Setup Kubernetes repositories
#
# @example
#   include kubeinstall::repos
class kubeinstall::repos {
  if $facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'], '7') >= 0 {
    yumrepo { 'kubernetes':
      ensure        => 'present',
      baseurl       => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
      descr         => 'Kubernetes',
      enabled       => '1',
      gpgcheck      => '1',
      gpgkey        => 'https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
      repo_gpgcheck => '0',
      # it produce some strange conflict
      exclude       => 'kubernetes-cni',
    }
  }
  elsif $facts['os']['name'] == 'Ubuntu' {
    $dist = $facts['os']['distro']['codename']
    $release = "kubernetes-${dist}"

    apt::source { 'kubernetes':
      comment  => 'Kubernetes apt repository',
      location => 'https://apt.kubernetes.io/',
      # no bionic, no focal and upper
      release  => 'kubernetes-xenial',
      repos    => 'main',
      key      => {
        id     => '7F92E05B31093BEF5A3C2D38FEEA9169307EA071',
        source => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
      }
    }
  }
}
