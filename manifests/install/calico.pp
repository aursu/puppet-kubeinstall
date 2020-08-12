# @summary Install Project Calico CNI service
#
# Install Project Calico CNI service
#
# @example
#   include kubeinstall::install::calico
class kubeinstall::install::calico (
  String  $version   = $kubeinstall::calico_cni_version,
  Stdlib::Fqdn
          $node_name = $kubeinstall::node_name,
  Optional[Integer]
          $mtu       = $kubeinstall::calico_mtu,
  Boolean $calicoctl = $kubeinstall::install_calicoctl,
){
  # https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises#install-calico-with-kubernetes-api-datastore-50-nodes-or-less
  # https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network
  exec { 'calico-install':
    command     => "kubectl apply -f https://docs.projectcalico.org/${version}/manifests/calico.yaml",
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    environment => [
      'KUBECONFIG=/etc/kubernetes/admin.conf',
    ],
    onlyif      => "kubectl get nodes ${node_name}",
    unless      => 'kubectl -n kube-system get daemonset calico-node',
  }

  # MTU
  # https://docs.projectcalico.org/networking/mtu#determine-mtu-size
  if $mtu {
    class { 'kubeinstall::calico::veth_mtu':
      mtu     => $mtu,
      require => Exec['calico-install'],
    }
  }

  if $calicoctl {
    include kubeinstall::calico::calicoctl
  }
}
