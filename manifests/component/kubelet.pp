# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::component::kubelet
class kubeinstall::component::kubelet (
  Kubeinstall::VersionPrefix $kubernetes_version = $kubeinstall::kubernetes_version,
) {
  kubeinstall::component::instance { 'kubelet':
    kubernetes_version => $kubernetes_version,
  }
}
