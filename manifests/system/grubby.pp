# @summary Install grubby
#
# Install grubby tool
#
# @example
#   include kubeinstall::system::grubby
class kubeinstall::system::grubby (
  Boolean $manage = $kubeinstall::manage_grubby,
)
{
  if $manage {
    package { 'grubby':
      ensure => 'present'
    }
  }
}
