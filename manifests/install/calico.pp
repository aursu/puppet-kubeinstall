# @summary Install Project Calico CNI service
#
# Install Project Calico CNI service
#
# @param operator
#   Whether to install Tigera Calico operator
#
# @param api_server_name
#   Calico API server APIServer resource name
#   See https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.APIServer
#
# @param installation_name
#   Calico installation configuration Installation resource name
#   See https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.Installation
#
# @param installation_registry
#   Registry is the default Docker registry used for component Docker images.
#
# @param block_size
#   BlockSize specifies the CIDR prefex length to use when allocating per-node
#   IP blocks from the main IP pool CIDR.
#   See: https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.IPPool
#
# @param cidr
#   CIDR contains the address range for the IP Pool in classless inter-domain routing format.
#
# @param encapsulation
#   Encapsulation specifies the encapsulation type that will be used with the IP Pool
#
# @param nat_outgoing
#   NATOutgoing specifies if NAT will be enabled or disabled for outgoing traffic. 
#
# @example
#   include kubeinstall::install::calico
class kubeinstall::install::calico (
  String $version = $kubeinstall::calico_version,
  Stdlib::Fqdn $node_name = $kubeinstall::node_name,
  Optional[Integer] $mtu = $kubeinstall::calico_mtu,
  Boolean $calicoctl = $kubeinstall::install_calicoctl,
  Boolean $operator  = $kubeinstall::install_calico_operator,
  String  $operator_version = $kubeinstall::calico_operator_version,
  String $api_server_name = 'default',
  String $installation_name = 'default',
  Pattern[/\/$/] $installation_registry = 'quay.io/',
  Integer $block_size = 26,
  Stdlib::IP::Address $cidr = $kubeinstall::pod_network_cidr,
  Kubeinstall::Calico::EncapsulationType $encapsulation = 'VXLANCrossSubnet',
  Enum['Enabled', 'Disabled'] $nat_outgoing = 'Enabled',
  Stdlib::Unixpath $kubeconfig = '/etc/kubernetes/admin.conf',
  Array[Stdlib::IP::Address] $ip_autodetection_cidrs = [],
) {
  # https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises#install-calico-with-kubernetes-api-datastore-50-nodes-or-less
  # https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network
  if $operator {
    # https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart
    exec { 'calico-operator-install':
      command     => "kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${version}/manifests/tigera-operator.yaml",
      path        => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
      environment => [
        "KUBECONFIG=${kubeconfig}",
      ],
      # https://kubernetes.io/docs/concepts/architecture/nodes/
      onlyif      => 'kubectl get nodes',
      unless      => "kubectl -n tigera-operator get deployment.apps/tigera-operator -o jsonpath='{.spec.template.spec.containers[?(@.name == \"tigera-operator\")].image}' | grep v${operator_version}",
    }

    if $ip_autodetection_cidrs[0] {
      $node_v4_address_autodetection_cidrs = {
        'nodeAddressAutodetectionV4' => {
          'cidrs' => $ip_autodetection_cidrs,
        },
      }
    }
    else {
      $node_v4_address_autodetection_cidrs = {}
    }

    $apiserver_header = {
      'apiVersion' => 'operator.tigera.io/v1',
      'kind'       => 'APIServer',
      'metadata'   => {
        'name' => $api_server_name,
      },
    }

    $apiserver_base = {
      'spec' => {},
    }

    $installation_header = {
      'apiVersion' => 'operator.tigera.io/v1',
      'kind'       => 'Installation',
      'metadata'   => {
        'name' => $installation_name,
      },
    }

    $installation_base = {
      'spec' => {
        'registry' => $installation_registry,
        'calicoNetwork' => {
          'ipPools' => [
            {
              'blockSize'     => $block_size,
              'cidr'          => $cidr,
              'encapsulation' => $encapsulation,
              'natOutgoing'   => $nat_outgoing,
              'nodeSelector'  => 'all()',
            },
          ],
        } + $node_v4_address_autodetection_cidrs,
      },
    }

    $apiserver_configuration = to_yaml($apiserver_header + $apiserver_base)
    $installation_configuration = to_yaml($installation_header + $installation_base)
    $manifest = '/etc/kubernetes/calico-custom-resources.yaml'

    file { $manifest:
      ensure  => file,
      content => join([$installation_configuration, $apiserver_configuration], ''),
      mode    => '0600',
    }

    exec { 'calico-install':
      command     => "kubectl create -f ${manifest}",
      path        => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
      environment => [
        "KUBECONFIG=${kubeconfig}",
      ],
      onlyif      => "test -f ${manifest}",
      unless      => "kubectl get -n calico-system daemonset.apps/calico-node -o jsonpath='{.spec.template.spec.containers[?(@.name == \"calico-node\")].image}' | grep v${version}",
      subscribe   => File[$manifest],
      require     => Exec['calico-operator-install'],
    }
  }
  else {
    exec { 'calico-install':
      command     => "kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v${version}/manifests/calico.yaml",
      path        => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
      environment => [
        "KUBECONFIG=${kubeconfig}",
      ],
      onlyif      => 'kubectl get nodes',
      unless      => 'kubectl -n kube-system get daemonset.apps/calico-node',
    }
  }

  # MTU
  # https://docs.projectcalico.org/networking/mtu#determine-mtu-size
  if $mtu {
    class { 'kubeinstall::calico::veth_mtu':
      mtu     => $mtu,
      require => Exec['calico-install'],
    }
  }

  file { '/etc/calico':
    ensure => directory,
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
  }

  if $calicoctl {
    contain kubeinstall::calico::calicoctl
  }
}
