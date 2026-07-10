# @summary Back up an etcd cluster with restic
#
# Etcd backup for control-plane nodes. The etcd-specific work lives here — take
# an `etcdctl snapshot save` to a real file and verify it with `etcdutl snapshot
# status` — while all the generic restic mechanics (install, repository env +
# init + prune, backup wrapper, retention, scheduling, locking) are delegated to
# the `aursu/restic` module.
#
# The snapshot is modelled as a `restic::job` in **path mode**: a `pre_command`
# writes and verifies the snapshot file, restic backs that file up, and a
# `post_command` (`trap … EXIT`) removes it — so a failed run never leaves a
# stale snapshot behind. Scheduling uses systemd timers (kubeinstall is
# systemd-centric). restic is installed by the `restic` class; etcdctl/etcdutl
# by `kubeinstall::etcd::etcdctl`.
#
# Apply only on control-plane nodes (the etcd members).
#
# @param repository        RESTIC_REPOSITORY (local path for the operational tier, s3:… for off-site).
# @param password          restic repository encryption password (loss = unrecoverable — escrow it).
# @param repo_env          extra backend env for the repo (e.g. AWS_ACCESS_KEY_ID for S3).
# @param endpoints         etcd client endpoint.
# @param cacert            etcd CA certificate.
# @param cert              etcd client certificate.
# @param key               etcd client key.
# @param snapshot_dir      directory for the transient snapshot file.
# @param on_calendar       systemd OnCalendar for the backup.
# @param keep              restic forget retention policy.
# @param enable            enable+start the timers.
# @param init              run `restic init` if the repository is absent.
# @param manage_directory  create the local repo's backing dir (no-op for remote backends).
# @param manage_prune      install the prune timer.
# @param prune_on_calendar systemd OnCalendar for the prune.
#
# @example
#   class { 'kubeinstall::etcd::backup':
#     repository => '/var/backups/etcd/restic',
#     password   => $repo_password,
#   }
class kubeinstall::etcd::backup (
  String                             $repository,
  Variant[String, Sensitive[String]] $password,
  Hash[String, String]               $repo_env          = {},
  String                             $endpoints         = 'https://127.0.0.1:2379',
  Stdlib::Absolutepath               $cacert            = '/etc/kubernetes/pki/etcd/ca.crt',
  Stdlib::Absolutepath               $cert              = '/etc/kubernetes/pki/etcd/server.crt',
  Stdlib::Absolutepath               $key               = '/etc/kubernetes/pki/etcd/server.key',
  Stdlib::Absolutepath               $snapshot_dir      = '/var/backups/etcd',
  String                             $on_calendar       = '*-*-* 03:30:00',
  Hash[Enum['last', 'hourly', 'daily', 'weekly', 'monthly', 'yearly'], Integer] $keep = { 'daily' => 7 },
  Boolean                            $enable            = true,
  Boolean                            $init              = true,
  Boolean                            $manage_directory  = true,
  Boolean                            $manage_prune      = true,
  String                             $prune_on_calendar = '*-*-* 04:20:00',
) {
  include restic
  include kubeinstall::etcd::etcdctl

  $bin_dir         = $restic::bin_dir
  $snapshot        = "${snapshot_dir}/etcd-snapshot.db"
  $snapshot_script = "${bin_dir}/etcd-snapshot.sh"

  # transient snapshot workspace
  file { $snapshot_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  # etcd-specific snapshot+verify helper (invoked as the job's pre_command)
  file { $snapshot_script:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => epp('kubeinstall/etcd/snapshot.sh.epp', {
        endpoints => $endpoints,
        cacert    => $cacert,
        cert      => $cert,
        key       => $key,
    }),
    require => Class['restic'],
  }

  # restic repository (systemd-timer prune) — generic mechanics in aursu/restic
  restic::repository { 'etcd':
    repository        => $repository,
    password          => $password,
    env               => $repo_env,
    init              => $init,
    manage_directory  => $manage_directory,
    manage_prune      => $manage_prune,
    schedule_provider => 'systemd_timer',
    prune_on_calendar => $prune_on_calendar,
    enable            => $enable,
  }

  # backup job in path mode: snapshot+verify (pre) → restic backup → forget,
  # with the snapshot removed on any exit (post/trap).
  restic::job { 'etcd':
    repository        => 'etcd',
    paths             => [$snapshot],
    pre_command       => "'${snapshot_script}' '${snapshot}'",
    post_command      => "rm -f '${snapshot}'",
    snapshot_tag      => 'etcd',
    keep              => $keep,
    schedule_provider => 'systemd_timer',
    on_calendar       => $on_calendar,
    enable            => $enable,
    require           => [
      File[$snapshot_dir],
      File[$snapshot_script],
      Class['kubeinstall::etcd::etcdctl'],
    ],
  }
}
