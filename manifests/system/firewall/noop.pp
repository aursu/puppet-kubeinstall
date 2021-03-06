# @summary Disable firewalld service
#
# Disable firewalld service
#
# @example
#   include kubeinstall::system::firewall::noop
class kubeinstall::system::firewall::noop {
  if $facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'], '7') >= 0 {
    class { 'firewalld':
      service_ensure => 'stopped',
      service_enable => false,
    }
  }
}
