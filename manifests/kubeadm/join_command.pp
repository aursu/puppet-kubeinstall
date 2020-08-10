# @summary Kubernetes kubeadm join command
#
# Kubernetes kubeadm join command
#
# @example
#   include kubeinstall::kubeadm::join_command
#
# @param join_token
#   Use this token for both discovery-token and tls-bootstrap-token in
#   `kubeadm join` command
#
# @param join_ca_cert_hash
#   For token-based discovery, validate that the root CA public key matches this
#   hash. The root CA found during discovery must match this value
#
# @param join_apiserver_address
#   API server andpoint address
#
class kubeinstall::kubeadm::join_command (
  Optional[Kubeinstall::Token]
          $join_token                 = $kubeinstall::join_token,
  Optional[Kubeinstall::CACertHash]
          $join_ca_cert_hash          = $kubeinstall::join_ca_cert_hash,
  Optional[Kubeinstall::Address]
          $join_apiserver_address     = $kubeinstall::join_apiserver_address,
  Integer $join_apiserver_port        = $kubeinstall::join_apiserver_port,
)
{
  include kubeinstall::cluster

  # set Join credentials to those provided via parameters (by cluster administrator via parameters)
  if $join_token and $join_ca_cert_hash and $join_apiserver_address {
    $token               = $join_token
    $ca_cert_hash        = $join_ca_cert_hash
    $apiserver_address   = $join_apiserver_address
    $apiserver_port      = $join_apiserver_port
  }
  else  {
    $token             = $kubeinstall::cluster::join_token
    $ca_cert_hash      = $kubeinstall::cluster::join_ca_cert_hash
    $apiserver_address = $kubeinstall::cluster::join_apiserver_address
    # cast into integer variable
    $apiserver_port    = $kubeinstall::cluster::join_apiserver_port + 0
  }

  class { 'kubeinstall::kubeadm::join_config':
    token             => $token,
    ca_cert_hash      => $ca_cert_hash,
    apiserver_address => $apiserver_address,
    apiserver_port    => $apiserver_port,
  }

  exec { 'kubeadm-join-config':
    command => 'kubeadm join --config=/etc/kubernetes/kubeadm-join.conf',
    path    => '/usr/bin:/bin',
    creates => '/etc/kubernetes/kubelet.conf',
    require => File['/etc/kubernetes/kubeadm-join.conf'],
  }
}
