# @summary kubernetes installation on controller node
#
# kubernetes installation on controller node
#
# @example
#   include kubeinstall::install::controller
class kubeinstall::install::controller (
  Boolean $web_ui_dashboard = $kubeinstall::web_ui_dashboard,
  Stdlib::Unixpath $manifests_directory = $kubeinstall::manifests_directory,
  Boolean $setup_admin_config  = true,
  Optional[Enum['controller', 'joined_controller']] $cluster_role = 'controller',
) {
  include kubeinstall::install::node
  include kubeinstall::kubeadm::config
  include kubeinstall::install::kube_scheduler
  include kubeinstall::directory_structure
  include kubeinstall::cluster

  if $cluster_role == 'controller' {
    include kubeinstall::kubeadm::init_command
    include kubeinstall::install::calico

    # create bootstrap token
    kubeadm_token { 'default':
      ensure => present,
    }

    if $web_ui_dashboard {
      include kubeinstall::install::dashboard

      Class['kubeinstall::kubeadm::init_command'] -> Class['kubeinstall::install::dashboard']
    }

    Class['kubeinstall::install::node']
    -> Class['kubeinstall::kubeadm::init_command']
    -> Class['kubeinstall::install::calico']
  }
  else {
    class { 'kubeinstall::kubeadm::join_command':
      control_plane => true,
    }

    Class['kubeinstall::install::node'] -> Class['kubeinstall::kubeadm::join_command']
  }

  if $setup_admin_config {
    include kubeinstall::kubectl::config

    if $cluster_role == 'controller' {
      Class['kubeinstall::kubeadm::init_command'] -> Class['kubeinstall::kubectl::config']
    }
    else {
      Class['kubeinstall::kubeadm::join_command'] -> Class['kubeinstall::kubectl::config']
    }
  }
  # TODO: https://kubernetes.io/docs/setup/best-practices/certificates/
  # TODO: https://github.com/kubernetes/kubeadm/blob/master/docs/ha-considerations.md#options-for-software-load-balancing
}
