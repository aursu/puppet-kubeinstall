# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::kubeadm::init_command
class kubeinstall::kubeadm::init_command (
  Stdlib::Fqdn
          $node_name = $kubeinstall::node_name,
)
{
  include kubeinstall::kubeadm::config

  exec { 'kubeadm init':
    command     => 'kubeadm init --config=/etc/kubernetes/kubeadm-init.conf',
    path        => '/bin:/usr/bin',
    environment => [
      'KUBECONFIG=/etc/kubernetes/admin.conf',
    ],
    unless      => "kubectl get nodes ${node_name}",
    require     => File['/etc/kubernetes/kubeadm-init.conf'],
  }
}
