# @summary A short summary of the purpose of this class
#
# A description of what this class does
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
