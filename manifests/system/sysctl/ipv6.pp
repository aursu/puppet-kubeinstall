# @summary Enable/Disable IPv6
#
# Enable/Disable IPv6
#
# @example
#   include kubeinstall::system::sysctl::ipv6
class kubeinstall::system::sysctl::ipv6 (
  Boolean $manage_sysctl_settings = $kubeinstall::manage_sysctl_settings,
  Boolean $disable                = $kubeinstall::disable_ipv6,
)
{
  if $disable {
    $disable_value = '1'
  }
  else {
    $disable_value = '0'
  }

  if $manage_sysctl_settings {
    sysctl {
      default:
        ensure => present,
        value  => $disable_value,
      ;
      'net.ipv6.conf.all.disable_ipv6': ;
      'net.ipv6.conf.default.disable_ipv6': ;
    }
  }
}
