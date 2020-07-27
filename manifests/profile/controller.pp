# @summary Kubernetes conntroller setup
#
# Kubernetes conntroller setup
#
# @example
#   include kubeinstall::profile::controller
class kubeinstall::profile::controller {
  include kubeinstall::profile::kubernetes

  class { 'kubeinstall::install::controller': }
}
