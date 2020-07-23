# @summary Base setup for any kubernetes host
#
# Base setup for any kubernetes host
#
# @example
#   include kubeinstall::profile::kubernetes
class kubeinstall::profile::kubernetes {
  class { 'kubeinstall': }
  class { 'kubeinstall::service': }
}
