# @summary Set selinux in permissive mode
#
# Set selinux in permissive mode
#
# @example
#   include kubeinstall::system::selinux::noop
class kubeinstall::system::selinux::noop (
  Enum['permissive', 'disabled']
            $mode = 'permissive',
)
{
  # puppet-selinux does not support Ubuntu
  unless $facts['os']['name'] == 'Ubuntu' {
    class {'selinux':
      mode => $mode,
    }
  }
}
