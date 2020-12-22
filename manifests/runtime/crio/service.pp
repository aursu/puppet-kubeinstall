# @summary CRI-O service management
#
# CRI-O service management
#
# @example
#   include kubeinstall::runtime::crio::service
class kubeinstall::runtime::crio::service {
  include kubeinstall::runtime::crio::install

  service { 'crio':
    ensure  => running,
    enable  => true,
    require => Package['cri-o'],
  }
}
