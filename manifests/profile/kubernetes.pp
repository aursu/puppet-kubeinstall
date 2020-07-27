# @summary Base setup for any kubernetes node
#
# Base setup for any kubernetes node
#
# @example
#   include kubeinstall::profile::kubernetes
class kubeinstall::profile::kubernetes {
  class { 'kubeinstall': }
  include kubeinstall::install::node
}
