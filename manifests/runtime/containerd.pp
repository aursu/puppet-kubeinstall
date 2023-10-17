# @summary Installing containerd
#
# Installing containerd as CRI runtime
#
# @param config_content
#   Content for /etc/containerd/config.toml
#
# @param set_config
#   Whether to replace /etc/containerd/config.toml content with content provided by
#   `config_content`
#
# @example
#   include kubeinstall::runtime::containerd
class kubeinstall::runtime::containerd (
  Kubeinstall::Containerd::VersionPrefix $version = $kubeinstall::params::containerd_version,
  Stdlib::IP::Address $pod_subnet = '10.85.0.0/16',
  Optional[String] $config_content = undef,
  Boolean $set_config = false,
) inherits kubeinstall::params {
  class { 'kubeinstall::runtime::containerd::install':
    version => $version,
  }

  class { 'kubeinstall::runtime::containerd::config':
    content     => $config_content,
    set_content => $set_config,
  }

  class { 'kubeinstall::cni::config::bridge':
    ipv4_subnet => $pod_subnet,
  }

  include kubeinstall::runtime::containerd::service
  include kubeinstall::runtime::containerd::nerdctl
  include kubeinstall::runtime::containerd::crictl
}
