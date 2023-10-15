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

  $nerdctl_binaries = [
    'nerdctl',
    'containerd-rootless-setuptool.sh',
    'containerd-rootless.sh',
  ]

  # https://github.com/containerd/nerdctl/releases/download/v1.6.2/nerdctl-1.6.2-linux-amd64.tar.gz
  if $version == 'absent' {
    $nerdctl_binaries.each |$binary| {
      file { "/usr/local/bin/${binary}":
        ensure => absent,
      }
    }
  }
  else {
    $archive = "nerdctl-${nerdctl_version}-linux-amd64.tar.gz"
    $source = "https://github.com/containerd/nerdctl/releases/download/v${nerdctl_version}/${archive}"
    $checksum_url = "https://github.com/containerd/nerdctl/releases/download/v${nerdctl_version}/SHA256SUMS"

    $local_dir = "/usr/local/nerdctl-${nerdctl_version}"
    file { [$local_dir, "${local_dir}/bin", "${local_dir}/lib"]:
      ensure => directory,
      before => [
        Exec["${archive}-SHA256SUMS"],
        Archive[$archive],
      ],
    }

    exec { "${archive}-SHA256SUMS":
      command => "curl -L ${checksum_url} -O",
      creates => "${local_dir}/lib/SHA256SUMS",
      path    => '/bin:/usr/bin',
      cwd     => "${local_dir}/lib",
    }

    archive { $archive:
      path         => "${local_dir}/lib/${archive}",
      source       => $source,
      extract      => true,
      extract_path => "${local_dir}/bin",
      cleanup      => false,
      # firewall plugin has been introduced in v0.8.0
      creates      => "${local_dir}/bin/nerdctl",
    }

    $nerdctl_binaries.each |$binary| {
      exec { "/usr/local/bin/${binary}":
        command => "cp ${local_dir}/bin/${binary} /usr/local/bin/${binary}",
        creates => "/usr/local/bin/${binary}",
        onlyif  => "grep ${archive} ${local_dir}/lib/SHA256SUMS | sha256sum --check",
        path    => '/bin:/usr/bin',
        cwd     => "${local_dir}/lib",
        require => [
          Exec["${archive}-SHA256SUMS"],
          Archive[$archive],
        ],
      }

      file { "/usr/local/bin/${binary}":
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        require => Exec["/usr/local/bin/${binary}"],
      }
    }
  }
}
