# @summary Stop kubelet service
#
# Stop kubelet service
#
# @example
#   include kubeinstall::service::stop
class kubeinstall::service::stop {
  exec { 'kubelet':
    command     => 'systemctl stop kubelet.service',
    path        => '/usr/bin:/usr/sbin',
    refreshonly => true,
  }
}
