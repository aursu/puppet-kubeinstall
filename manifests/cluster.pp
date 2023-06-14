# @summary Cluster resources definition, export and import
#
# Cluster resources definition, export and import
#
# @example
#   include kubeinstall::cluster
#
# @param cluster_role
#   Role inside cluster - either 'worker' or 'controller'
#
class kubeinstall::cluster (
  Kubeinstall::Address $apiserver_address = $kubeinstall::apiserver_advertise_address,
  Integer $apiserver_port = $kubeinstall::apiserver_bind_port,
  String  $cluster_name = $kubeinstall::cluster_name,
  Optional[Kubeinstall::CACertHash] $ca_cert_hash = $facts['kubeadm_discovery_token_ca_cert_hash'],
  Optional[Enum['controller', 'worker']] $cluster_role = undef,
  Hash[Kubeinstall::DNSSubdomain, Kubeinstall::LocalPV] $local_persistent_volumes = {},
  Hash[String, String] $node_labels = {},
) {
  if $facts['kubeadm_token_list'] and $facts['kubeadm_token_list'][0] {
    $token_data = $facts['kubeadm_token_list'][0]
    $bootstrap_token = $token_data['token']
  }
  else {
    $bootstrap_token = undef
  }

  # https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/
  # https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#join-nodes
  # kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
  if $bootstrap_token and $ca_cert_hash {
    @@kubeinstall::token_discovery { $bootstrap_token:
      ca_cert_hash      => $ca_cert_hash,
      apiserver_address => $apiserver_address,
      apiserver_port    => $apiserver_port,
      cluster_name      => $cluster_name,
    }

    @@exec { 'kubeadm-join-control-plane':
      command => "kubeadm join --token ${bootstrap_token} ${apiserver_address}:${apiserver_port} --discovery-token-ca-cert-hash ${ca_cert_hash} --control-plane", # lint:ignore:140chars
      path    => '/usr/bin:/bin:/sbin:/usr/sbin',
      creates => '/etc/kubernetes/kubelet.conf',
      tag     => $cluster_name,
    }
  }

  # get controller join credentials for k8s cluster
  $token_discovery = kubeinstall::discovery_hosts(
    'Kubeinstall::Token_discovery',
    ['title', 'ca_cert_hash', 'apiserver_address', 'apiserver_port'],
    ['cluster_name', '==', $cluster_name],
  )

  # if not empty - use first in set credentials
  if $token_discovery[0] {
    [$join_token, $join_ca_cert_hash, $join_apiserver_address, $join_apiserver_port] = $token_discovery[0]
  }
  else {
    $join_token = undef
    $join_ca_cert_hash = undef
    $join_apiserver_address =  undef
    $join_apiserver_port = 6443
  }

  case $cluster_role {
    'controller': {
      # Local persistent volumes collect
      Kubeinstall::Resource::Pv::Local <<| tag == $cluster_name |>>
      Kubeinstall::Node::Label <<| tag == $cluster_name |>>
    }
    'worker': {
      $node_name = $facts['fqdn']

      # Local persistent volumes export
      $local_persistent_volumes.each |$volume, $volume_settings| {
        # default hostnname is puppet FQDN fact
        $hostname_param = $volume_settings['hostname'] ? {
          String  => {},
          default => { 'hostname' => $node_name },
        }

        @@kubeinstall::resource::pv::local { $volume:
          *   => $volume_settings + $hostname_param,
          tag => $cluster_name,
        }
      }

      # Node labels export
      $node_labels.each |$label_name, $label_value| {
        @@kubeinstall::node::label { "${node_name}/${label_name}":
          key       => $label_name,
          value     => $label_value,
          node_name => $node_name,
          tag       => $cluster_name,
        }
      }
    }
    default: {
    }
  }
}
