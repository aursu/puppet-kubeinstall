# @summary A short summary of the purpose of this class
#
# A description of what this class does
# see https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
#
# @example
#   include kubeinstall::kubeadm::init_command
class kubeinstall::kubeadm::init_command (
  Stdlib::Fqdn
          $node_name = $kubeinstall::node_name,
) {
  include kubeinstall::kubeadm::config

  exec { 'kubeadm-init':
    command     => 'kubeadm init --config=/etc/kubernetes/kubeadm-init.conf',
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    environment => [
      'KUBECONFIG=/etc/kubernetes/admin.conf',
    ],
    unless      => "kubectl get nodes ${node_name}",
    creates     => '/etc/kubernetes/manifests/kube-apiserver.yaml',
    require     => Class['kubeinstall::kubeadm::config'],
  }
}
