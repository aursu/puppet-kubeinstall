# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::install
class kubeinstall::install (
  Kubeinstall::Version $kubernetes_version = $kubeinstall::kubernetes_version,
)
{
  include kubeinstall::repos
  include systemd::systemctl::daemon_reload

  # https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
  package {
    default:
      ensure  => $kubernetes_version,
      require => Class['kubeinstall::repos'],
    ;
    'kubeadm': ;
    'kubelet':
      notify => Class['systemd::systemctl::daemon_reload'],
    ;
    'kubectl': ;
  }
}
