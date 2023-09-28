# @summary Setup Kubernetes directories
#
# Setup Kubernetes directories on target hosts
#
# @param targets
#   Nodes for which Kubernetes directories should be enabled
#
plan kubeinstall::setup (
  TargetSpec $targets,
) {
  run_plan(facts, $targets)
  return apply($targets) {
    include kubeinstall
    class { 'kubeinstall::directory_structure': }
  }
}
