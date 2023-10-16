# @summary Installing containerd
#
# Installing containerd as CRI runtime
#
# @param config_content
#   Content for /etc/containerd/config.toml
#
# @example
#   include kubeinstall::runtime::containerd
class kubeinstall::runtime::containerd (
  Kubeinstall::Containerd::VersionPrefix $version = $kubeinstall::params::containerd_version,
  Stdlib::IP::Address $bridge_subnet = '10.85.0.0/16',
  Optional[String] $config_content = undef,

) inherits kubeinstall::params {
  class { 'kubeinstall::runtime::containerd::install':
    version => $version,
  }

  class { 'kubeinstall::runtime::containerd::config':
    content => $config_content,
  }

  class { 'kubeinstall::cni::config::bridge':
    ipv4_subnet => $bridge_subnet,
  }

  include kubeinstall::runtime::containerd::service
  include kubeinstall::runtime::containerd::nerdctl
  include kubeinstall::runtime::containerd::crictl
}
