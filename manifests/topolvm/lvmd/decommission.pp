# @summary Remove a TopoLVM lvmd installation from a host
#
# Stops, disables and removes the `lvmd` systemd unit installed by
# `kubeinstall::topolvm::lvmd`, and optionally the binary and configuration it
# placed. For a host that no longer participates in a Kubernetes cluster and so
# has no CSI driver left to talk to `lvmd`.
#
# Worth stating plainly, because it is the question anyone reviewing this will
# ask: **this class does not touch LVM.** Volume groups, logical volumes,
# filesystems and mounts are left exactly as they are. `lvmd` is a gRPC daemon
# that creates and deletes logical volumes on request; removing it removes the
# means of asking, not the storage. It also leaves `xfsprogs` and `e2fsprogs`
# alone, since anything on the host may depend on them.
#
# @param purge_files
#   Whether to remove the binary, the configuration directory and the runtime
#   socket directory as well as the unit. Defaults to true. Set false to stop
#   the service but leave the installation in place, for a staged removal.
#
# @param socket_dir
#   Runtime directory holding the gRPC socket, removed when `purge_files` is
#   set. Matches `kubeinstall::topolvm::lvmd`'s default.
#
# @example Decommission lvmd on a repurposed node
#   include kubeinstall::topolvm::lvmd::decommission
#
class kubeinstall::topolvm::lvmd::decommission (
  Boolean $purge_files = true,
  Stdlib::Absolutepath $socket_dir = '/run/topolvm',
) {
  # The resource title is deliberately the same one `kubeinstall::topolvm::lvmd`
  # uses. Declaring both classes on a host is then a duplicate-declaration
  # failure at catalogue compilation - loud and immediate - rather than two
  # classes taking turns starting and stopping the service on every agent run.
  # Same reasoning as the rpcbind hardening class.
  systemd::unit_file { 'lvmd.service':
    ensure => absent,
    enable => false,
    active => false,
  }

  if $purge_files {
    file { ['/opt/sbin/lvmd', '/etc/topolvm', $socket_dir]:
      ensure  => absent,
      force   => true,
      require => Systemd::Unit_file['lvmd.service'],
    }
  }
}
