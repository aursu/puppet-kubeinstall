# @summary Set selinux in permissive mode
#
# Set selinux in permissive mode
#
# @example
#   include kubeinstall::system::selinux::noop
class kubeinstall::system::selinux::noop {
    class {'selinux':
      mode => 'permissive',
    }
}
