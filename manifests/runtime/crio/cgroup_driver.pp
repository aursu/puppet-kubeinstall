# @summary Configure cgroup driver for CRI-O
#
# Configure cgroup driver for CRI-O
#
# @example
#   include kubeinstall::runtime::crio::cgroup_driver
class kubeinstall::runtime::crio::cgroup_driver {
  # https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cgroup-driver

  # CRI-O uses the systemd cgroup driver per default. To switch to the cgroupfs
  # cgroup driver, either edit /etc/crio/crio.conf or place a drop-in
  # configuration in /etc/crio/crio.conf.d/02-cgroup-manager.conf
}
