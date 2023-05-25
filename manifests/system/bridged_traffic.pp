# @summary Load netfilter bridge kernel module
#
# Load netfilter bridge kernel module
#
# @example
#   include kubeinstall::system::bridged_traffic
class kubeinstall::system::bridged_traffic (
  Boolean $manage_kernel_modules = $kubeinstall::manage_kernel_modules,
) {
  include kubeinstall::system::sysctl::net_bridge

  if $manage_kernel_modules {
    kmod::load { 'br_netfilter': }

    Kmod::Load['br_netfilter'] -> Class['kubeinstall::system::sysctl::net_bridge']
  }
}
