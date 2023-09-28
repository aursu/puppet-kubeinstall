# @summary Kubectl admin config
#
# Kubectl admin config
#
# @example
#   include kubeinstall::kubectl::config
class kubeinstall::kubectl::config (
  Stdlib::Unixpath $kubeconfig = '/etc/kubernetes/admin.conf',
) {
  file { '/root/.kube/config':
    mode   => '0600',
    source => "file://${kubeconfig}",
  }
}
