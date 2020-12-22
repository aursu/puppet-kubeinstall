# @summary Load overlay kernel module to support Overlay FS
#
# Load overlay kernel module to support Overlay FS
#
# @example
#   include kubeinstall::system::overlay
class kubeinstall::system::overlay (
  Boolean $manage_kernel_modules = $kubeinstall::manage_kernel_modules,
)
{
  if $manage_kernel_modules {
    kmod::load { 'overlay': }
  }
}
