# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::component::kubectl
class kubeinstall::component::kubectl (
  Kubeinstall::VersionPrefix $kubernetes_version = $kubeinstall::kubernetes_version,
) {
  kubeinstall::component::instance { 'kubectl':
    kubernetes_version => $kubernetes_version,
  }
}
