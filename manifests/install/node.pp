# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::install::node
class kubeinstall::install::node {
  include kubeinstall::system
  include kubeinstall::runtime::docker
  include kubeinstall::service

  file { '/root/.kube':
    ensure => directory,
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
  }

  file { ['/etc/kubernetes', '/etc/kubernetes/manifests']:
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  Class['kubeinstall::system'] -> Class['kubeinstall::service']
  Class['kubeinstall::runtime::docker'] -> Class['kubeinstall::service']
}
