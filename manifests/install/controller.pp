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
) {
  include kubeinstall::install::node
  include kubeinstall::kubeadm::config
  include kubeinstall::kubeadm::init_command
  include kubeinstall::install::calico
  include kubeinstall::install::kube_scheduler

  if $web_ui_dashboard {
    include kubeinstall::install::dashboard

    Class['kubeinstall::kubeadm::init_command'] -> Class['kubeinstall::install::dashboard']
  }

  if $setup_admin_config {
    include kubeinstall::kubectl::config

    Class['kubeinstall::kubeadm::init_command'] -> Class['kubeinstall::kubectl::config']
  }

  include kubeinstall::cluster

  # create bootstrap token
  kubeadm_token { 'default':
    ensure => present,
  }

  file {
    default:
      ensure => directory,
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
      ;
    # storage classes objects directory
    "${manifests_directory}/manifests/storageclasses": ;
    # persistent volumes objects directory
    "${manifests_directory}/manifests/persistentvolumes": ;
    # secret objects directory
    "${manifests_directory}/manifests/secrets":
      mode => '0710',
      ;
    # services objects directory
    # https://kubernetes.io/docs/concepts/services-networking/service/
    "${manifests_directory}/manifests/services": ;
  }

  Class['kubeinstall::install::node']
  -> Class['kubeinstall::kubeadm::init_command']
  -> Class['kubeinstall::install::calico']

  # TODO: https://kubernetes.io/docs/setup/best-practices/certificates/
  # TODO: https://github.com/kubernetes/kubeadm/blob/master/docs/ha-considerations.md#options-for-software-load-balancing
}
