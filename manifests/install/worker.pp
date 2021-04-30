# @summary Kubernetes installation on worker node
#
# Kubernetes installation on worker node
#
# @example
#   include kubeinstall::install::worker
class kubeinstall::install::worker {
  include kubeinstall::install::node
  include kubeinstall::kubeadm::join_command

  Class['kubeinstall::install::node'] -> Class['kubeinstall::kubeadm::join_command']
}
