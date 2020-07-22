# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall
class kubeinstall (
  Kubeinstall::Version $kubernetes_version,
  String $dockerd_version,
  String $containerd_version,
  Boolean $manage_kernel_modules,
  Boolean $manage_sysctl_settings,
  Boolean $disable_swap,
  Boolean $disable_firewall,
  Boolean $disable_selinux,
)
{
}
