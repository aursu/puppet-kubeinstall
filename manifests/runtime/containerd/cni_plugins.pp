# @summary CNI network plugins
#
# CNI network plugins, maintained by the containernetworking team
#
# @example
#   include kubeinstall::runtime::containerd::cni_plugins
class kubeinstall::runtime::containerd::cni_plugins (
  Kubeinstall::CNIPlugins::Version $version = $kubeinstall::params::cni_plugins_version,
) inherits kubeinstall::params {
  include kubeinstall
  include kubeinstall::directory_structure

  $dir = $kubeinstall::params::cni_plugins_dir
  $plugins_binaries = [
    "${dir}/loopback",
    "${dir}/bandwidth",
    "${dir}/ptp",
    "${dir}/vlan",
    "${dir}/host-device",
    "${dir}/tuning",
    "${dir}/vrf",
    "${dir}/sbr",
    "${dir}/tap",
    "${dir}/dhcp",
    "${dir}/static",
    "${dir}/firewall",
    "${dir}/macvlan",
    "${dir}/dummy",
    "${dir}/bridge",
    "${dir}/ipvlan",
    "${dir}/portmap",
    "${dir}/host-local",
  ]
  if $version in ['installed', 'present', 'latest'] {
    $plugins_version = $kubeinstall::params::cni_plugins_version
  }
  else {
    $plugins_version = $version
  }

  # https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
  if $version == 'absent' {
    file { $plugins_binaries:
      ensure => absent,
    }
  }
  else {
    $archive = "cni-plugins-linux-amd64-v${plugins_version}.tgz"
    $source = "https://github.com/containernetworking/plugins/releases/download/v${plugins_version}/${archive}"

    archive { $archive:
      path          => "/tmp/${archive}",
      source        => $source,
      extract       => true,
      extract_path  => $dir,
      cleanup       => true,
      # firewall plugin has been introduced in v0.8.0
      creates       => "${dir}/firewall",
      checksum_url  => "${source}.sha256",
      checksum_type => 'sha256',
    }

    file { $plugins_binaries:
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      require => Archive[$archive],
    }
  }
}
