# @summary Installing containerd
#
# Installing containerd as CRI runtime
#
# @example
#   include kubeinstall::runtime::containerd
class kubeinstall::runtime::containerd (
  Kubeinstall::Containerd::VersionPrefix $version = $kubeinstall::params::containerd_version,
) inherits kubeinstall::params {
  class { 'kubeinstall::runtime::containerd::install':
    version => $version,
  }

  include kubeinstall::runtime::containerd::runc
  include kubeinstall::runtime::containerd::cni_plugins
  include kubeinstall::runtime::containerd::service
  include kubeinstall::runtime::containerd::nerdctl

  Class['kubeinstall::runtime::containerd::install'] -> Class['kubeinstall::runtime::containerd::service']
  Class['kubeinstall::runtime::containerd::runc'] -> Class['kubeinstall::runtime::containerd::service']
  Class['kubeinstall::runtime::containerd::cni_plugins'] -> Class['kubeinstall::runtime::containerd::service']
}
