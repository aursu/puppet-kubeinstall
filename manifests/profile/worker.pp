# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::profile::worker
class kubeinstall::profile::worker {
  include kubeinstall::profile::kubernetes

  class { 'kubeinstall::install::worker': }
}
