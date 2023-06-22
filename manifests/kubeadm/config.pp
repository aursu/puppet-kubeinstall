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
#
# @param service_node_port_range
#   A port range to reserve for services with NodePort visibility.
#   Example: '30000-32767'. Inclusive at both ends of the range.
#
# @param topolvm_scheduler
#   Whether to manage TopoLVM scheduler setup
#
class kubeinstall::kubeadm::config (
  Optional[Kubeinstall::Token] $bootstrap_token = undef,
  String[2] $token_ttl = '24h0m0s',
  Kubeinstall::Address $apiserver_advertise_address = $kubeinstall::apiserver_advertise_address,
  Integer $apiserver_bind_port = $kubeinstall::apiserver_bind_port,
  Stdlib::Fqdn $node_name = $kubeinstall::node_name,
  Stdlib::Unixpath $cri_socket = $kubeinstall::cri_socket,
  String $cluster_name = $kubeinstall::cluster_name,
  Kubeinstall::Version $kubernetes_version = $kubeinstall::kubernetes_version,
  Stdlib::Fqdn $service_dns_domain = $kubeinstall::service_dns_domain,
  Stdlib::IP::Address $service_cidr = $kubeinstall::service_cidr,
  Stdlib::IP::Address $pod_network_cidr = $kubeinstall::pod_network_cidr,
  Kubeinstall::Range5X $service_node_port_range = $kubeinstall::service_node_port_range,
  Optional[Kubeinstall::Address] $control_plane_endpoint = $kubeinstall::control_plane_endpoint,
  Kubeinstall::CgroupDriver $cgroup_driver = $kubeinstall::cgroup_driver,
  Boolean $topolvm_scheduler = $kubeinstall::topolvm_scheduler,
) {
  unless $token_ttl =~ Kubeinstall::TokenTTL {
    fail("parameter 'token_ttl' expects a match for Pattern[/^([0-9]+h)?([0-5]?[0-9]m)?([0-5]?[0-9]s)?$/], got '${token_ttl}'")
  }

  [$svc_port_min, $svc_port_max] = split($service_node_port_range, '-')
  if $svc_port_min =~ Kubeinstall::Port and $svc_port_max =~ Kubeinstall::Port {
    if (0 + $svc_port_min) > (0 + $svc_port_max) {
      fail("parameter 'service_node_port_range' must be a valid port range (min < max)")
    }
  }
  else {
    fail("parameter 'service_node_port_range' must be a valid port range (min = 1, max = 65535)")
  }

  # it could be RPM package version
  $version_data = split($kubernetes_version, '[-]')
  $version = $version_data[0]

  # https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2
  $init_header  = {
    'apiVersion' => 'kubeadm.k8s.io/v1beta3',
    'kind' => 'InitConfiguration',
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

  $kubelet_extra_args = {
    # Flag --cgroup-driver has been deprecated, This parameter should be set via the config file specified by the Kubelet's --config flag
    # 'cgroup-driver' => $cgroup_driver,
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
        },
      ],
      'kubeletExtraArgs' => $kubelet_extra_args,
    },
  }

  $cluster_header = {
    'apiVersion' => 'kubeadm.k8s.io/v1beta3',
    'kind'       => 'ClusterConfiguration',
  }

  if $topolvm_scheduler {
    include kubeinstall::topolvm::scheduler

    # Configure kube-scheduler for new clusters
    # https://github.com/topolvm/topolvm/tree/main/deploy#for-new-clusters
    $cluster_scheduler = {
      'extraVolumes' => [
        {
          'name'      => 'config',
          'hostPath'  => $kubeinstall::topolvm::scheduler::path,
          'mountPath' => '/var/lib/scheduler',
          'readOnly'  => true,
        },
      ],
      'extraArgs'    => {
        'config' => '/var/lib/scheduler/scheduler-config.yaml',
      },
    }
  }
  else {
    $cluster_scheduler = {}
  }

  $cluster_base = {
    'apiServer'         => {
      'timeoutForControlPlane' => '4m0s',
      'extraArgs' => {
        'service-node-port-range' => $service_node_port_range,
      },
    },
    'certificatesDir'   => '/etc/kubernetes/pki',
    'clusterName'       => $cluster_name,
    'controllerManager' => {},
    # See https://kubernetes.io/docs/reference/config-api/kubeadm-config.v1beta3/
    # The "ClusterConfiguration.DNS.Type" field has been removed since CoreDNS is the only supported DNS server type by kubeadm
    'dns'               => {
      # 'type' => 'CoreDNS',
    },
    'etcd'              => {
      'local' => {
        'dataDir' => '/var/lib/etcd',
      },
    },
    # See https://kubernetes.io/blog/2023/03/10/image-registry-redirect/
    'imageRepository'   => 'registry.k8s.io',
    'kubernetesVersion' => "v${version}",
    'networking'        => {
      'dnsDomain'     => $service_dns_domain,
      'serviceSubnet' => $service_cidr,
      'podSubnet'     => $pod_network_cidr,
    },
    'scheduler'         => $cluster_scheduler,
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
