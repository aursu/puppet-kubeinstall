# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::runtime::containerd::install
class kubeinstall::runtime::containerd::install (
  Kubeinstall::Containerd::VersionPrefix $version = $kubeinstall::params::containerd_version,
) inherits kubeinstall::params {
  if $version in ['installed', 'present', 'latest'] {
    $containerd_version = $kubeinstall::params::containerd_version
  }
  else {
    $version_data  = split($version, '[-]')
    $containerd_version = $version_data[0]
  }

  $dir = '/usr/local/bin'
  $containerd_binaries = [
    "${dir}/containerd-shim-runc-v1",
    "${dir}/containerd-stress",
    "${dir}/containerd-shim-runc-v2",
    "${dir}/containerd",
    "${dir}/containerd-shim",
    "${dir}/ctr",
  ]
  if $version == 'absent' {
    file { $containerd_binaries:
      ensure => absent,
    }
  }
  else {
    $archive = "containerd-${containerd_version}-linux-amd64.tar.gz"
    $source = "https://github.com/containerd/containerd/releases/download/v${containerd_version}/${archive}"

    # [root@localhost ~]# tar ztf containerd-1.7.7-linux-amd64.tar.gz
    # bin/
    # bin/containerd-shim-runc-v1
    # bin/containerd-stress
    # bin/containerd-shim-runc-v2
    # bin/containerd
    # bin/containerd-shim
    # bin/ctr

    archive { $archive:
      path          => "/tmp/${archive}",
      source        => $source,
      extract       => true,
      extract_path  => '/usr/local',
      cleanup       => true,
      creates       => '/usr/local/bin/containerd',
      checksum_url  => "${source}.sha256sum",
      checksum_type => 'sha256',
    }

    file { $containerd_binaries:
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      require => Archive[$archive],
    }
  }
}
