# @summary Docker container runtime setup
#
# Use Docker as container runtime for Kubernetes
# see https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
#
# @example
#   include kubeinstall::runtime::docker
class kubeinstall::runtime::docker (
  String $dockerd_version    = $kubeinstall::dockerd_version,
  String $containerd_version = $kubeinstall::containerd_version,
)
{
  class { 'dockerinstall::profile::install':
    dockerd_version    => $dockerd_version,
    containerd_version => $containerd_version,
  }
}
