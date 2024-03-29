# @summary Setup bridged traffic processing with iptables
#
# Setup bridged traffic processing with iptables
#
# @example
#   include kubeinstall::system::sysctl::net_bridge
class kubeinstall::system::sysctl::net_bridge (
  Boolean $manage_sysctl_settings = $kubeinstall::manage_sysctl_settings,
) {
  if $manage_sysctl_settings {
    sysctl {
      default:
        ensure => present,
        value  => '1',
        ;
      'net.bridge.bridge-nf-call-ip6tables': ;
      'net.bridge.bridge-nf-call-iptables': ;
    }
  }
}
