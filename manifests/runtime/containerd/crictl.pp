# @summary CLI and validation tools
#
# CLI and validation tools for Kubelet Container Runtime Interface (CRI)
#
# @example
#   include kubeinstall::runtime::containerd::crictl
class kubeinstall::runtime::containerd::crictl (
  Kubeinstall::Version $version = $kubeinstall::params::cri_tools_version,
) {
  # https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.28.0/crictl-v1.28.0-linux-amd64.tar.gz
  if $version in ['installed', 'present', 'latest'] {
    $cri_tools_version = $kubeinstall::params::cri_tools_version
  }
  else {
    $cri_tools_version = $version
  }

  if $version == 'absent' {
    file { '/usr/local/bin/crictl':
      ensure => absent,
    }
  }
  else {
    $archive = "crictl-v${cri_tools_version}-linux-amd64.tar.gz"
    $source = "https://github.com/kubernetes-sigs/cri-tools/releases/download/v${cri_tools_version}/${archive}"

    archive { $archive:
      path          => "/tmp/${archive}",
      source        => $source,
      extract       => true,
      extract_path  => '/usr/local/bin',
      cleanup       => true,
      creates       => '/usr/local/bin/crictl',
      checksum_url  => "${source}.sha256",
      checksum_type => 'sha256',
    }

    file { '/usr/local/bin/crictl':
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      require => Archive[$archive],
    }
  }
}
