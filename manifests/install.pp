# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::install
class kubeinstall::install (
  Kubeinstall::Version $kubernetes_version = $kubeinstall::kubernetes_version,
  Kubeinstall::Version $kubeadm_version    = $kubeinstall::kubeadm_version,
) {
  include kubeinstall::repos
  include kubeinstall::systemctl::daemon_reload

  # if we do not know exect versions for Ubuntu  OS - use patterns
  if $facts['os']['name'] == 'Ubuntu' and $kubernetes_version =~ /^1\.2[0-9]\.[0-9]+$/ {
    $kubernetes_version_pattern = "${kubernetes_version}-00"
  }
  else {
    $kubernetes_version_pattern = $kubernetes_version
  }

  if $facts['os']['name'] == 'Ubuntu' and $kubeadm_version =~ /^1\.2[0-9]\.[0-9]+$/ {
    $kubeadm_version_pattern = "${kubeadm_version}-00"
  }
  else {
    $kubeadm_version_pattern = $kubeadm_version
  }

  # https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
  package {
    default:
      ensure  => $kubernetes_version_pattern,
      require => Class['kubeinstall::repos'],
      ;
    'kubeadm':
      ensure  => $kubeadm_version_pattern,
      ;
    'kubelet':
      notify => Class['kubeinstall::systemctl::daemon_reload'],
      ;
    'kubectl': ;
  }
}
