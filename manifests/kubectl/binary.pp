# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::kubectl::binary
class kubeinstall::kubectl::binary (
  Kubeinstall::VersionPrefix $version = $kubeinstall::kubernetes_version,
) {
  class { 'kubeinstall::component::kubectl':
    kubernetes_version => $version,
  }
}
