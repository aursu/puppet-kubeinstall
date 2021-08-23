# @summary Set selinux in permissive mode
#
# Set selinux in permissive mode
#
# @example
#   include kubeinstall::system::selinux::noop
class kubeinstall::system::selinux::noop {
  # puppet-selinux does not support Ubuntu
  unless $facts['os']['name'] == 'Ubuntu' {
    class {'selinux':
      mode => 'permissive',
    }
  }
}
