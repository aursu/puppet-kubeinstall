# @summary Install containerd
#
# Install containerd
#
# @param targets
#   Nodes for which containerd should be enabled
#
plan kubeinstall::runtime::containerd (
  TargetSpec $targets,
) {
  run_plan(facts, $targets)
  return apply($targets) {
    include kubeinstall
    class { 'kubeinstall::runtime::containerd': }
  }
}
