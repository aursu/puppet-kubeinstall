# @summary Kubernetes conntroller setup
#
# Kubernetes conntroller setup
#
# @example
#   include kubeinstall::profile::controller
#
# @param helm_client
#   Whether to install Helm client binary or not
#
class kubeinstall::profile::controller (
  Boolean $helm_client = true,
  Optional[Enum['controller', 'joined_controller']] $cluster_role = 'controller',
) {
  include kubeinstall::profile::kubernetes

  class { 'kubeinstall::cluster':
    cluster_role => $cluster_role,
  }

  class { 'kubeinstall::install::controller':
    cluster_role => $cluster_role,
  }

  if $helm_client {
    class { 'kubeinstall::install::helm_binary': }
    include kubeinstall::helm::completion
  }
}
