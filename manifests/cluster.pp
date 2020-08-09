# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   include kubeinstall::cluster
class kubeinstall::cluster (
  Kubeinstall::Address
          $apiserver_address = $kubeinstall::apiserver_advertise_address,
  Integer $apiserver_port    = $kubeinstall::apiserver_bind_port,
  String  $cluster_name      = $kubeinstall::cluster_name,
  Optional[Kubeinstall::CACertHash]
          $ca_cert_hash      = $facts['kubeadm_discovery_token_ca_cert_hash'],
) {
  kubeadm_token { 'default':
    ensure => present,
  }

  if $facts['kubeadm_token_list'] and $facts['kubeadm_token_list'][0] {
    $token_data = $facts['kubeadm_token_list'][0]
    $token = $token_data['token']
  }
  else {
    $token = undef
  }

  # https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/
  # https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#join-nodes
  # kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
  if $token and $ca_cert_hash {
    @@kubeinstall::token_discovery { $token:
      ca_cert_hash      => $ca_cert_hash,
      apiserver_address => $apiserver_address,
      apiserver_port    => $apiserver_port,
      cluster_name      => $cluster_name,
    }

    @@exec { 'kubeadm-join-control-plane':
      command => "kubeadm join --token ${token} ${apiserver_address}:${apiserver_port} --discovery-token-ca-cert-hash ${ca_cert_hash} --control-plane", # lint:ignore:140chars
      path    => '/usr/bin:/bin',
      creates => '/etc/kubernetes/kubelet.conf',
      tag     => $cluster_name,
    }
  }
}
