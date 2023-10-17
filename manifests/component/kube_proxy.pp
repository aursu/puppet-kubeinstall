# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::component::kube_proxy
class kubeinstall::component::kube_proxy (
  Kubeinstall::VersionPrefix $kubernetes_version = $kubeinstall::kubernetes_version,
) {
  kubeinstall::component::instance { 'kube-proxy':
    kubernetes_version => $kubernetes_version,
  }
}
