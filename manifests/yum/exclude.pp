# @summary Exclude package kubernetes-cni from update process
#
# Exclude package kubernetes-cni from update process
#
# @example
#   include kubeinstall::yum::exclude
class kubeinstall::yum::exclude (
  Boolean $manage = $kubeinstall::manage_yum_excludes,
)
{
  if $manage {
    yum::config { 'exclude':
      # it produce some strange conflict
      ensure => 'kubernetes-cni',
    }
  }
}
