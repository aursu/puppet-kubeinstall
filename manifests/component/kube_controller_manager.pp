# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::component::kube_controller_manager
class kubeinstall::component::kube_controller_manager (
  Kubeinstall::VersionPrefix $kubernetes_version = $kubeinstall::kubernetes_version,
) {
  kubeinstall::component::instance { 'kube-controller-manager':
    kubernetes_version => $kubernetes_version,
  }
}
