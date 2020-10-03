# @summary kubernetes installation on controller node
#
# kubernetes installation on controller node
#
# @example
#   include kubeinstall::install::controller
class kubeinstall::install::controller (
  Boolean $web_ui_dashboard = $kubeinstall::web_ui_dashboard,
){
  include kubeinstall::install::node
  include kubeinstall::kubeadm::config
  include kubeinstall::kubeadm::init_command
  include kubeinstall::install::calico
  if $web_ui_dashboard  {
    include kubeinstall::install::dashboard
  }
  include kubeinstall::cluster

  # create bootstrap token
  kubeadm_token { 'default':
    ensure => present,
  }

  # persistent volumes objects directory
  file { '/etc/kubernetes/manifests/persistentvolumes':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  Class['kubeinstall::kubeadm::init_command'] -> Class['kubeinstall::install::calico']

  # TODO: https://kubernetes.io/docs/setup/best-practices/certificates/
  # TODO: https://github.com/kubernetes/kubeadm/blob/master/docs/ha-considerations.md#options-for-software-load-balancing
}
