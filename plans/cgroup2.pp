# @summary Set hostname on target hosts
#
# Enable cgroups v2 on target hosts
#
# @param targets
#   Nodes for which cgroups v2 should be enabled
#
plan kubeinstall::cgroup2 (
  TargetSpec $targets,
  Boolean    $reboot = false,
) {
  $results = run_task(
    'kubeinstall::cgroup2',
    $targets,
    'Enable cgroups v2',
    '_catch_errors' => true,
    '_run_as' => 'root',
  )

  if $reboot {
    $reboot_targets = $results.ok_set.filter_set |$res| { $res['reboot'] == true }.targets

    return run_task('reboot', $reboot_targets)
  }

  return $results
}
