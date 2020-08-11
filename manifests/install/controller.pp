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

  # create bootstrap token
  kubeadm_token { 'default':
    ensure => present,
  }

  include kubeinstall::cluster

  Class['kubeinstall::kubeadm::init_command'] -> Class['kubeinstall::install::calico']

  # TODO: https://kubernetes.io/docs/setup/best-practices/certificates/
  # TODO: https://github.com/kubernetes/kubeadm/blob/master/docs/ha-considerations.md#options-for-software-load-balancing
}
