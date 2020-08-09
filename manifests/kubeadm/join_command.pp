# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::kubeadm::join_command
class kubeinstall::kubeadm::join_command (
  Optional[Kubeinstall::Token]
          $token             = undef,
  Optional[Kubeinstall::CACertHash]
          $ca_cert_hash      = undef,
  Optional[Kubeinstall::Address]
          $apiserver_address = undef,
  Integer $apiserver_port    = $kubeinstall::apiserver_bind_port,
  String  $cluster_name      = $kubeinstall::cluster_name,
  Stdlib::Unixpath
          $cri_socket        = $kubeinstall::cri_socket,
  Stdlib::Fqdn
          $node_name         = $kubeinstall::node_name,
){
  # https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2#JoinConfiguration
  # kubeadm config print join-defaults
  $init_header  = {
    'apiVersion' => 'kubeadm.k8s.io/v1beta2',
    'kind' => 'JoinConfiguration'
  }

  $init_base = {
    'caCertPath' => '/etc/kubernetes/pki/ca.crt',
    'nodeRegistration' => {
      'criSocket' => $cri_socket,
      'name'      => $node_name,
      'taints'    => nil,
    }
  }

  $token_discovery = kubeinstall::discovery_hosts(
    'Kubeinstall::Token_discovery',
    ['title', 'ca_cert_hash', 'apiserver_address', 'apiserver_port'],
    ['cluster_name', '==', $cluster_name],
  )

  notify { $token_discovery: }

  if $token and $apiserver_address and $ca_cert_hash {
    $init_discovery = {
      'discovery' => {
        'bootstrapToken'    => {
          'apiServerEndpoint'        => "${apiserver_address}:${apiserver_port}",
          'token'                    => $token,
          'unsafeSkipCAVerification' => false,
          'caCertHashes'             => [
            $ca_cert_hash,
          ]
        },
        'timeout'           => '5m0s',
        'tlsBootstrapToken' => $token,
      }
    }
  }
}
