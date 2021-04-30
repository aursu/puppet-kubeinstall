# @summary Stop kubelet service
#
# Stop kubelet service
#
# @example
#   include kubeinstall::service::stop
class kubeinstall::service::stop {
  # we can not stop service which is not installed
  include kubeinstall::install

  exec { 'kubelet':
    command     => 'systemctl stop kubelet.service',
    path        => '/usr/bin:/usr/sbin',
    refreshonly => true,
    onlyif      => 'systemctl status kubelet.service',
    require     => Class['kubeinstall::install'],
  }
}
