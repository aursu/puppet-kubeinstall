# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::profile::worker
#
# @param local_persistent_volumes
#   Added ability for cluster administrator to setup local persistent volumes
#   into Kubernetes cluster. This hash should containn only volumes located on
#   currennt worker node.
#
# @param node_labels
#   Added ability to setup node labels
#
class kubeinstall::profile::worker (
  Hash[String, Hash] $local_persistent_volumes = {},
  Hash[String, String] $node_labels = {},
) {
  include kubeinstall::profile::kubernetes

  class { 'kubeinstall::cluster':
    cluster_role             => 'worker',
    local_persistent_volumes => $local_persistent_volumes,
    node_labels              => $node_labels,
  }

  class { 'kubeinstall::install::worker': }

  include kubeinstall::install::cleanup
}
