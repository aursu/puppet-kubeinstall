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
  Optional[Integer]
          $mtu               = undef,
)
{
  class { 'dockerinstall::profile::install':
    dockerd_version    => $dockerd_version,
    containerd_version => $containerd_version,
  }

  class { 'dockerinstall::profile::daemon':
    cgroup_driver  => 'systemd',
    log_driver     => 'json-file',
    log_opts       => {
      'max-size' => '100m',
    },
    storage_driver => 'overlay2',
    storage_opts   => [
      'overlay2.override_kernel_check=true',
    ],
    mtu            => $mtu,
  }
}
