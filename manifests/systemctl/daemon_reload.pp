# @summary Reload the systemctl daemon
#
# @example
#   include kubeinstall::systemctl::daemon_reload
class kubeinstall::systemctl::daemon_reload {
  exec { 'systemd-reload-3acb7d7':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    path        => $facts['path'],
  }
}
