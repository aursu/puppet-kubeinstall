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
  contain kubeinstall::system::bridged_traffic
  # Following https://kubernetes.io/docs/setup/production-environment/container-runtimes/
  # recommendations
  contain kubeinstall::system::sysctl::ip_forward
  contain kubeinstall::system::overlay

  if $disable_swap {
    contain kubeinstall::system::swap
  }
  if $disable_firewall {
    include kubeinstall::system::firewall::noop
  }
  if $disable_selinux {
    include kubeinstall::system::selinux::noop
  }
}
