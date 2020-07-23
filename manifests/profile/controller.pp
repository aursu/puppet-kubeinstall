# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::profile::controller
class kubeinstall::profile::controller {
  include kubeinstall::profile::kubernetes

  class { 'kubeinstall::install::controller': }
}
