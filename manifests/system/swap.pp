# @summary Disable swap on the system
#
# Disable swap on the system
#
# @example
#   include kubeinstall::system::swap
class kubeinstall::system::swap {
  # proceed  only if swap exists
  if $facts['memory'] and $facts['memory']['swap'] {
    exec { 'swapoff -a':
      path => '/usr/sbin:/sbin:/usr/bin:/bin',
    }

    $facts['partitions'].each |$part, $opts| {
      if $opts['filesystem'] == 'swap' {
        # remove from fstab
        mount { "swap-${part}":
          ensure => 'absent',
          name   => 'swap',
          device => $part,
          fstype => 'swap',
        }
      }
    }
  }
}
