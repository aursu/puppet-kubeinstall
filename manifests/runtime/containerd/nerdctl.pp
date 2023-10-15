# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::runtime::containerd::nerdctl
class kubeinstall::runtime::containerd::nerdctl (
  Kubeinstall::NerdCTL::Version $version = $kubeinstall::params::nerdctl_version,
) inherits kubeinstall::params {
  include kubeinstall
  include kubeinstall::directory_structure
  if $version in ['installed', 'present', 'latest'] {
    $nerdctl_version = $kubeinstall::params::nerdctl_version
  }
  else {
    $nerdctl_version = $version
  }

  $dir = '/usr/local/bin'
  $nerdctl_binaries = [
    "${dir}/nerdctl",
    "${dir}/containerd-rootless-setuptool.sh",
    "${dir}/containerd-rootless.sh",
  ]

  # https://github.com/containerd/nerdctl/releases/download/v1.6.2/nerdctl-1.6.2-linux-amd64.tar.gz
  if $version == 'absent' {
    file { $nerdctl_binaries:
      ensure => absent,
    }
  }
  else {
    $archive = "nerdctl-${nerdctl_version}-linux-amd64.tar.gz"
    $source = "https://github.com/containerd/nerdctl/releases/download/v${nerdctl_version}/${archive}"
    $checksum_url = "https://github.com/containerd/nerdctl/releases/download/v${nerdctl_version}/SHA256SUMS"

    archive { $archive:
      path            => "/tmp/${archive}",
      source          => $source,
      extract         => true,
      extract_command => "tar zxf %s --strip-components=1 -C ${dir}",
      extract_path    => $dir,
      cleanup         => true,
      # firewall plugin has been introduced in v0.8.0
      creates         => "${dir}/nerdctl",
      checksum_url    => $checksum_url,
      checksum_type   => 'sha256',
    }

    file { $nerdctl_binaries:
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      require => Archive[$archive],
    }
  }
}
