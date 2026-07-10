# @summary Install the restic backup client (self-contained)
#
# Installs a pinned restic binary via puppet-archive and creates the config/bin
# directories used by `kubeinstall::etcd::backup`.
#
# NOTE (tech debt): this duplicates the restic install in `lsys::restic`.
# `kubeinstall` must NOT depend on `lsys` ("local sys" is a leaf module). The
# intended long-term fix is to extract a shared restic install into `bsys`
# ("basic sys"), which kubeinstall already depends on. Until then this stays
# self-contained here.
#
# @param version     restic version to install from the upstream GitHub release.
# @param config_dir  directory holding the repository env file (0700).
# @param bin_dir     directory holding generated wrapper scripts (0750).
#
# @example
#   include kubeinstall::restic
class kubeinstall::restic (
  String               $version    = '0.19.1',
  Stdlib::Absolutepath $config_dir = '/etc/restic',
  Stdlib::Absolutepath $bin_dir    = '/opt/backup',
) {
  file { $config_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  file { $bin_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }

  $arch = $facts['os']['architecture'] ? {
    'aarch64' => 'arm64',
    'arm64'   => 'arm64',
    default   => 'amd64',
  }
  $asset  = "restic_${version}_linux_${arch}.bz2"
  $tmp    = "/tmp/${asset}"
  $target = "/usr/local/bin/restic-${version}"

  archive { "kubeinstall-restic-${version}":
    path    => $tmp,
    source  => "https://github.com/restic/restic/releases/download/v${version}/${asset}",
    extract => false,
    creates => $target,
    cleanup => false,
  }

  exec { "kubeinstall-restic-install-${version}":
    command => "bunzip2 -kfc ${tmp} > ${target} && chmod 0755 ${target}",
    creates => $target,
    path    => ['/usr/bin', '/bin', '/usr/local/bin'],
    require => Archive["kubeinstall-restic-${version}"],
  }

  file { '/usr/local/bin/restic':
    ensure  => link,
    target  => $target,
    require => Exec["kubeinstall-restic-install-${version}"],
  }
}
