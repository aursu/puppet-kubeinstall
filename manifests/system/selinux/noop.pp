# @summary Set selinux in permissive mode
#
# Set selinux in permissive mode
#
# @example
#   include kubeinstall::system::selinux::noop
class kubeinstall::system::selinux::noop {
  if $facts['selinux'] {
    class {'selinux':
      mode => 'permissive',
    }
  }
}
