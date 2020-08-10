# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::kubeadm::config
#
# @param cri_socket
#   CRISocket is used to retrieve container runtime info. This information will
#   be annotated to the Node API object, for later re-use
class kubeinstall::kubeadm::config (
  Optional[Kubeinstall::Token]
          $bootstrap_token             = undef,
  String[2]
          $token_ttl                   = '24h0m0s',
  Kubeinstall::Address
          $apiserver_advertise_address = $kubeinstall::apiserver_advertise_address,
  Integer $apiserver_bind_port         = $kubeinstall::apiserver_bind_port,
  Stdlib::Fqdn
          $node_name                   = $kubeinstall::node_name,
  Stdlib::Unixpath
          $cri_socket                  = $kubeinstall::cri_socket,
  String  $cluster_name                = $kubeinstall::cluster_name,
  Kubeinstall::Version
          $kubernetes_version          = $kubeinstall::kubernetes_version,
  Stdlib::Fqdn
          $service_dns_domain          = $kubeinstall::service_dns_domain,
  Stdlib::IP::Address
          $service_cidr                = $kubeinstall::service_cidr,
  Optional[Kubeinstall::Address]
          $control_plane_endpoint      = $kubeinstall::control_plane_endpoint,
)
{
  unless $token_ttl =~ Kubeinstall::TokenTTL {
    fail("parameter 'token_ttl' expects a match for Pattern[/^([0-9]+h)?([0-5]?[0-9]m)?([0-5]?[0-9]s)?$/], got '${token_ttl}'")
  }

  # it could be RPM package version
  $version_data = split($kubernetes_version, '[-]')
  $version = $version_data[0]

  # https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2
  $init_header  = {
    'apiVersion' => 'kubeadm.k8s.io/v1beta2',
    'kind' => 'InitConfiguration'
  }

  if $bootstrap_token {
    $bootstrap_tokens = {
      'bootstrapTokens' => [
        {
          'groups' => ['system:bootstrappers:kubeadm:default-node-token'],
          'token'  => $bootstrap_token,
          'ttl'    => $token_ttl,
          'usages' => ['signing', 'authentication'],
        }
      ],
    }
  }
  else {
    $bootstrap_tokens = {}
  }

  $init_base = {
    'localAPIEndpoint' => {
      'advertiseAddress' => $apiserver_advertise_address,
      'bindPort'         => $apiserver_bind_port,
    },
    'nodeRegistration' => {
      'criSocket' => $cri_socket,
      'name'      => $node_name,
      'taints'    => [
        {
          'effect' => 'NoSchedule',
          'key'    => 'node-role.kubernetes.io/master',
        }
      ]
    }
  }

  $cluster_header = {
    'apiVersion' => 'kubeadm.k8s.io/v1beta2',
    'kind'       => 'ClusterConfiguration'
  }

  $cluster_base = {
    'apiServer'         => {
      'timeoutForControlPlane' => '4m0s',
    },
    'certificatesDir'   => '/etc/kubernetes/pki',
    'clusterName'       => $cluster_name,
    'controllerManager' => {},
    'dns'               => {
      'type' => 'CoreDNS',
    },
    'etcd'              => {
      'local' => {
        'dataDir' => '/var/lib/etcd',
      },
    },
    'imageRepository'   => 'k8s.gcr.io',
    'kubernetesVersion' => "v${version}",
    'networking'        => {
      'dnsDomain' => $service_dns_domain,
      'serviceSubnet' => $service_cidr,
    },
    'scheduler'         => {},
  }

  if $control_plane_endpoint {
    $cluster_control_plane_endpoint = {
      'controlPlaneEndpoint' => $control_plane_endpoint,
    }
  }
  else {
    $cluster_control_plane_endpoint = {}
  }

  $init_configuration = to_yaml($init_header + $bootstrap_tokens + $init_base)
  $cluster_configuration = to_yaml($cluster_header + $cluster_base + $cluster_control_plane_endpoint)

  file { '/etc/kubernetes/kubeadm-init.conf':
    ensure  => file,
    content => join([$init_configuration, $cluster_configuration], ''),
    mode    => '0600',
  }
}
