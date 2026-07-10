# @summary Back up an etcd cluster with restic
#
# Self-contained etcd backup for control-plane nodes: takes an `etcdctl snapshot
# save` to a real file, verifies it with `etcdutl snapshot status`, streams the
# verified snapshot into a restic repository, applies retention (`forget`), and
# removes the local snapshot. A separate `prune` timer reclaims space.
#
# Scheduling uses systemd timers (kubeinstall is systemd-centric). restic is
# installed by `kubeinstall::restic` (self-contained — see the tech-debt note
# there); etcdctl/etcdutl by `kubeinstall::etcd::etcdctl`.
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
  include kubeinstall::restic
  include kubeinstall::etcd::etcdctl

  $config_dir   = $kubeinstall::restic::config_dir
  $bin_dir      = $kubeinstall::restic::bin_dir
  $env_file      = "${config_dir}/etcd.env"
  $lockfile      = '/run/restic-etcd.lock'
  $backup_script = "${bin_dir}/etcd-backup.sh"
  $prune_script  = "${bin_dir}/etcd-restic-prune.sh"

  $pass = $password =~ Sensitive ? {
    true    => $password.unwrap,
    default => $password,
  }
  $forget_flags = $keep.map |$rule, $count| { "--keep-${rule} ${count}" }

  # transient snapshot workspace
  file { $snapshot_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  # restic repository env
  file { $env_file:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0600',
    show_diff => false,
    content   => Sensitive(epp('kubeinstall/etcd/restic.env.epp', {
          repository => $repository,
          password   => $pass,
          env        => $repo_env,
    })),
    require   => Class['kubeinstall::restic'],
  }

  # local repo backing dir (no-op for s3:/remote backends)
  if $manage_directory and $repository =~ Stdlib::Absolutepath {
    $repo_parent = dirname($repository)

    exec { 'kubeinstall-etcd-restic-mkdir':
      command => "mkdir -p '${repo_parent}'",
      creates => $repo_parent,
      path    => ['/usr/bin', '/bin'],
    }

    file { $repository:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      require => Exec['kubeinstall-etcd-restic-mkdir'],
    }

    $init_require = [File[$env_file], File[$repository], File['/usr/local/bin/restic']]
  }
  else {
    $init_require = [File[$env_file], File['/usr/local/bin/restic']]
  }

  # backup wrapper: snapshot -> verify -> restic -> forget -> cleanup
  file { $backup_script:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => epp('kubeinstall/etcd/backup.sh.epp', {
        env_file     => $env_file,
        lockfile     => $lockfile,
        snapshot_dir => $snapshot_dir,
        endpoints    => $endpoints,
        cacert       => $cacert,
        cert         => $cert,
        key          => $key,
        forget_flags => $forget_flags,
    }),
    require => [Class['kubeinstall::restic'], File[$env_file], File[$snapshot_dir]],
  }

  # idempotent repository init
  if $init {
    exec { 'kubeinstall-etcd-restic-init':
      command => "/bin/bash -c 'set -a; . ${env_file}; set +a; restic init'",
      unless  => "/bin/bash -c 'set -a; . ${env_file}; set +a; restic cat config >/dev/null 2>&1'",
      path    => ['/usr/local/bin', '/usr/bin', '/bin'],
      require => $init_require,
    }
  }

  # systemd service + timer for the backup
  systemd::unit_file { 'etcd-backup.service':
    content => epp('kubeinstall/etcd/service.epp', {
        description => 'etcd snapshot backup (restic)',
        exec_start  => $backup_script,
    }),
    require => File[$backup_script],
  }

  systemd::unit_file { 'etcd-backup.timer':
    content => epp('kubeinstall/etcd/timer.epp', {
        description => 'etcd snapshot backup (restic)',
        on_calendar => $on_calendar,
    }),
    enable  => $enable,
    active  => $enable,
    require => Systemd::Unit_file['etcd-backup.service'],
  }

  # prune on its own schedule (single lock owner, expensive/exclusive)
  if $manage_prune {
    file { $prune_script:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0750',
      content => epp('kubeinstall/etcd/prune.sh.epp', {
          env_file => $env_file,
          lockfile => $lockfile,
      }),
      require => File[$env_file],
    }

    systemd::unit_file { 'etcd-restic-prune.service':
      content => epp('kubeinstall/etcd/service.epp', {
          description => 'etcd restic repository prune',
          exec_start  => $prune_script,
      }),
      require => File[$prune_script],
    }

    systemd::unit_file { 'etcd-restic-prune.timer':
      content => epp('kubeinstall/etcd/timer.epp', {
          description => 'etcd restic repository prune',
          on_calendar => $prune_on_calendar,
      }),
      enable  => $enable,
      active  => $enable,
      require => Systemd::Unit_file['etcd-restic-prune.service'],
    }
  }
}
