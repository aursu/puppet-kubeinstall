# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::install::worker
class kubeinstall::install::worker {
  include kubeinstall::install::node

  $join_token = kubeinstall::discovery_hosts('Kubeadm_token')
  notify { $join_token: }

}
