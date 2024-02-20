# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::globals
class kubeinstall::globals (
  Kubeinstall::VersionPrefix $kubernetes_version = $kubeinstall::kubernetes_version,
)  inherits kubeinstall::params {
  if versioncmp($kubernetes_version, '1.29.0') >= 0 {
    $topolvm_scheduler_config = 'kubeinstall/topolvm/scheduler-config.v1.29.yaml'
  }
  else {
    $topolvm_scheduler_config = 'kubeinstall/topolvm/scheduler-config.yaml'
  }
}
