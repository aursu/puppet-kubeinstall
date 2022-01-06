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
      $answered_true = $results.filter |$result| { $result[answer] == true }
      $reboot_targets = $answered_true.map |$result| { $result.target }

      run_task('reboot', $reboot_targets)
    }
}
