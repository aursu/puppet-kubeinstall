# @summary Base setup for any kubernetes node
#
# Base setup for any kubernetes node
#
# @example
#   include kubeinstall::profile::kubernetes
class kubeinstall::profile::kubernetes {
  include kubeinstall
  include kubeinstall::install::node

  # Repositories this module used to declare and no longer does. Puppet forgets
  # them rather than removing them, so they have to be named somewhere - and
  # every Kubernetes node is exactly the set of hosts that once had them.
  include kubeinstall::repos::cleanup
}
