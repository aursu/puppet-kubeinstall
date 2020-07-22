# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::system
class kubeinstall::system (
  Boolean $disable_swap     = $kubeinstall::disable_swap,
  Boolean $disable_firewall = $kubeinstall::disable_firewall,
  Boolean $disable_selinux  = $kubeinstall::disable_selinux,
){
  include kubeinstall::system::bridged_traffic

  if $disable_swap {
    include kubeinstall::system::swap
  }
  if $disable_firewall {
    include kubeinstall::system::firewall::noop
  }
  if $disable_selinux {
    include kubeinstall::system::selinux::noop
  }
}
