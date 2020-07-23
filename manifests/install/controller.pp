# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::install::controller
class kubeinstall::install::controller {
  # --control-plane-endpoint
  # --cri-socket /var/run/docker.sock
  # --apiserver-advertise-address=

  # TODO: https://github.com/kubernetes/kubeadm/blob/master/docs/ha-considerations.md#options-for-software-load-balancing

  include kubeinstall::service
  include tlsinfo
  include tlsinfo::tools::cfssl
}
