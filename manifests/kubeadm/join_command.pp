# @summary Kubernetes kubeadm join command
#
# Kubernetes kubeadm join command
#
# @example
#   include kubeinstall::kubeadm::join_command
#
# @param admin_token
#   Use this token for both discovery-token and tls-bootstrap-token in
#   `kubeadm join` command
#
# @param admin_ca_cert_hash
#   For token-based discovery, validate that the root CA public key matches this
#   hash. The root CA found during discovery must match this value
#
# @param admin_apiserver_address
#   API server andpoint address
#
class kubeinstall::kubeadm::join_command (
  Optional[Kubeinstall::Token]
          $admin_token             = undef,
  Optional[Kubeinstall::CACertHash]
          $admin_ca_cert_hash      = undef,
  Optional[Kubeinstall::Address]
          $admin_apiserver_address = undef,
  Integer $admin_apiserver_port    = 6443,
  Integer $apiserver_bind_port     = $kubeinstall::apiserver_bind_port,
  String  $cluster_name            = $kubeinstall::cluster_name,
  Stdlib::Unixpath
          $cri_socket              = $kubeinstall::cri_socket,
  Stdlib::Fqdn
          $node_name               = $kubeinstall::node_name,
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

  # set Join credentials to those provided via parameters (by cluster administrator via parameters)
  if $admin_token and $admin_ca_cert_hash and $admin_apiserver_address {
    $token               = $admin_token
    $ca_cert_hash        = $admin_ca_cert_hash
    $api_server_endpoint = "${admin_apiserver_address}:${admin_apiserver_port}"
  }
  else  {
    # get controller join credentials for k8s cluster
    $join_discovery = kubeinstall::discovery_hosts(
      'Kubeinstall::Token_discovery',
      ['title', 'ca_cert_hash', 'apiserver_address', 'apiserver_port'],
      ['cluster_name', '==', $cluster_name],
    )

    # if not empty - use first credentials' set
    if $join_discovery[0] {
      [$token, $ca_cert_hash, $apiserver_address, $apiserver_port] = $join_discovery[0]

      $api_server_endpoint = "${apiserver_address}:${apiserver_port}"
    }
    else {
      $token = undef
      $ca_cert_hash = undef
      $api_server_endpoint = undef
    }
  }

  notify { [$token, $ca_cert_hash, $api_server_endpoint]: }

  # provided via parameters (Kubernetes controller credentials)
  if $token and $api_server_endpoint and $ca_cert_hash {
    $init_discovery = {
      'discovery' => {
        'bootstrapToken'    => {
          'apiServerEndpoint'        => $api_server_endpoint,
          'token'                    => $token,
          'unsafeSkipCAVerification' => false,
          'caCertHashes'             => [$ca_cert_hash],
        },
        'timeout'           => '5m0s',
        'tlsBootstrapToken' => $token,
      }
    }
  }
}
