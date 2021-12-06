# @summary Docker container runtime setup
#
# Use Docker as container runtime for Kubernetes
# see https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
#
# @example
#   include kubeinstall::runtime::docker
#
# @param network_bridge_ip
#   Default bridge network address (conform to daemon.json bip parameter)
#
# @param selinux
#   Whether to enable selinux support
#
class kubeinstall::runtime::docker (
  String  $dockerd_version    = $kubeinstall::dockerd_version,
  String  $containerd_version = $kubeinstall::containerd_version,
  Optional[Integer]
          $mtu                = $kubeinstall::docker_mtu,
  Optional[String]
          $network_bridge_ip  = $kubeinstall::network_bridge_ip,
  Optional[Boolean]
          $selinux            = $kubeinstall::cri_selinux,
)
{
  class { 'dockerinstall::profile::install':
    dockerd_version    => $dockerd_version,
    containerd_version => $containerd_version,
  }
  contain dockerinstall::profile::install

  class { 'dockerinstall::profile::daemon':
    cgroup_driver     => 'systemd',
    log_driver        => 'json-file',
    log_opts          => {
      'max-size' => '100m',
    },
    storage_driver    => 'overlay2',
    storage_opts      => [
      'overlay2.override_kernel_check=true',
    ],
    mtu               => $mtu,
    network_bridge_ip => $network_bridge_ip,
    selinux           => $selinux,
  }
  contain dockerinstall::profile::daemon
}
