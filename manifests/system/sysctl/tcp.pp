# @summary sysctl/kernel settings for TCP stack
#
# sysctl/kernel settings for TCP stack
#
# @example
#   include kubeinstall::system::sysctl::tcp
class kubeinstall::system::sysctl::tcp (
  Boolean $manage_sysctl_settings = $kubeinstall::manage_sysctl_settings,
  # https://lore.kernel.org/netdev/20191030163620.140387-1-edumazet@google.com/
  Integer $net_core_somaxconn     = 4096,
)
{
  if $manage_sysctl_settings {
    # based on this bug https://github.com/docker-library/redis/issues/35
    sysctl { 'net.core.somaxconn':
      ensure => present,
      value  => $net_core_somaxconn,
    }
  }
}
