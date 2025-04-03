# @summary Kubernetes kubeadm join command configuration
#
# Kubernetes kubeadm join command configuration
#
# @example
#   include kubeinstall::kubeadm::join_config
#
# @param apiserver_advertise_address
#   If the node should host a new control plane instance, the IP address the
#   API Server will advertise it's listening on
#
# @param apiserver_bind_port
#   If the node should host a new control plane instance, the port for the API
#   Server to bind to.
#
# @param control_plane
#   Whether to create a new control plane instance on this node
#
# @param certificate_key
#   is the key that is used for decryption of certificates after they are downloaded from the
#   secret upon joining a new control plane node. The corresponding encryption key is in the
#   InitConfiguration. The certificate key is a hex encoded string that is an AES key of size 32 bytes.
#
class kubeinstall::kubeadm::join_config (
  Kubeinstall::Token $token,
  Kubeinstall::CACertHash $ca_cert_hash,
  Kubeinstall::Address $apiserver_address,
  Integer $apiserver_port = $kubeinstall::join_apiserver_port,
  Kubeinstall::Address $apiserver_advertise_address = $kubeinstall::apiserver_advertise_address,
  Integer $apiserver_bind_port = $kubeinstall::apiserver_bind_port,
  Stdlib::Unixpath $cri_socket = $kubeinstall::cri_socket,
  Stdlib::Fqdn $node_name = $kubeinstall::node_name,
  Boolean $control_plane = $kubeinstall::join_control_plane,
  Kubeinstall::CgroupDriver $cgroup_driver = $kubeinstall::cgroup_driver,
  Optional[Kubeinstall::CertificateKey] $certificate_key = $kubeinstall::join_certificate_key,
) {
  # https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2#JoinConfiguration
  # kubeadm config print join-defaults
  $join_header  = {
    'apiVersion' => 'kubeadm.k8s.io/v1beta3',
    'kind' => 'JoinConfiguration',
  }

  # https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#configure-cgroup-driver-used-by-kubelet-on-control-plane-node
  $kubelet_extra_args = {
    # Flag --cgroup-driver has been deprecated, This parameter should be set via the config file specified by the Kubelet's --config flag
    # 'cgroup-driver' => $cgroup_driver,
  }

  $join_base = {
    'caCertPath' => '/etc/kubernetes/pki/ca.crt',
    'nodeRegistration' => {
      'criSocket'        => $cri_socket,
      'name'             => $node_name,
      'taints'           => [],
      'kubeletExtraArgs' => $kubelet_extra_args,
    },
  }

  if $control_plane {
    if $certificate_key {
      $control_plane_certificate_key = { 'certificateKey' => $certificate_key }
    }
    else {
      $control_plane_certificate_key = {}
    }

    $join_control_plane = {
      'controlPlane' => {
        'localAPIEndpoint' => {
          'advertiseAddress' => $apiserver_advertise_address,
          'bindPort'         => $apiserver_bind_port,
        },
      } + $control_plane_certificate_key,
    }
  }
  else {
    $join_control_plane = {}
  }

  $join_discovery = {
    'discovery' => {
      'bootstrapToken'    => {
        'apiServerEndpoint'        => "${apiserver_address}:${apiserver_port}",
        'token'                    => $token,
        'unsafeSkipCAVerification' => false,
        'caCertHashes'             => [$ca_cert_hash],
      },
      'timeout'           => '5m0s',
      'tlsBootstrapToken' => $token,
    },
  }

  $join_configuration = to_yaml($join_header + $join_base + $join_discovery + $join_control_plane)

  file { '/etc/kubernetes/kubeadm-join.conf':
    ensure  => file,
    content => $join_configuration,
    mode    => '0600',
  }
}
