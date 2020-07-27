# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::install::controller
class kubeinstall::install::controller {
  include kubeinstall::install::node
  include kubeinstall::kubeadm::config
  include kubeinstall::kubeadm::init_command

  # TODO: https://kubernetes.io/docs/setup/best-practices/certificates/
  # TODO: https://github.com/kubernetes/kubeadm/blob/master/docs/ha-considerations.md#options-for-software-load-balancing
}
