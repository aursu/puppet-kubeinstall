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
  Optional[String] $config_content = undef,
) inherits kubeinstall::params {
  class { 'kubeinstall::runtime::containerd::install':
    version => $version,
  }

  class { 'kubeinstall::runtime::containerd::config':
    content => $config_content,
  }

  include kubeinstall::runtime::containerd::runc
  include kubeinstall::runtime::containerd::cni_plugins
  include kubeinstall::runtime::containerd::service
  include kubeinstall::runtime::containerd::nerdctl
  include kubeinstall::runtime::containerd::crictl

  Class['kubeinstall::runtime::containerd::install'] -> Class['kubeinstall::runtime::containerd::service']
  Class['kubeinstall::runtime::containerd::runc'] -> Class['kubeinstall::runtime::containerd::service']
  Class['kubeinstall::runtime::containerd::cni_plugins'] -> Class['kubeinstall::runtime::containerd::service']
}
