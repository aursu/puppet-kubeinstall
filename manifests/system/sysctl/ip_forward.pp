# @summary Enable IPv4 forwarding
#
# Enable IPv4 forwarding
#
# @example
#   include kubeinstall::system::sysctl::ip_forward
class kubeinstall::system::sysctl::ip_forward (
  Boolean $manage_sysctl_settings = $kubeinstall::manage_sysctl_settings,
)
{
  if $manage_sysctl_settings {
    sysctl { 'net.ipv4.ip_forward':
      ensure => present,
      value  => '1',
    }
  }
}
