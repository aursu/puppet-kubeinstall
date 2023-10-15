# @summary Install containerd
#
# Install containerd
#
# @param targets
#   Nodes for which containerd should be enabled
#
plan kubeinstall::containerd (
  TargetSpec $targets,
  String $version = '1.7.7',
) {
  run_plan(facts, $targets)
  return apply($targets) {
    include kubeinstall
    class { 'kubeinstall::runtime::containerd': version => $version, }
  }
}
