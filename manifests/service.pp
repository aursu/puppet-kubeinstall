# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::service
class kubeinstall::service
{
  include kubeinstall::runtime::docker
  include kubeinstall::install
  include kubeinstall::system

  service { 'kubelet':
    ensure  => running,
    enable  => true,
    require => [
      Class['kubeinstall::runtime::docker'],
      Class['kubeinstall::system'],
      Class['kubeinstall::install']
    ]
  }
}
