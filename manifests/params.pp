# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::params
class kubeinstall::params {
  $apiserver_bind_port     = 6443
  # https://kubernetes.io/docs/tasks/administer-cluster/migrating-from-dockershim/
  $docker_socket           = '/var/run/dockershim.sock'
  $crio_socket             = '/var/run/crio/crio.sock'
  $service_dns_domain      = 'cluster.local'
  $service_cidr            = '10.96.0.0/12'
  $service_node_port_range = '30000-32767'
  $dashboard_configuration = 'https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml'
  # directory where to store static manifests under folder 'manifests'
  $manifests_directory     = '/etc/kubectl'

  # Puppet > 6
  if 'distro' in $facts['os'] {
    # centos stream
    $centos_stream = $facts['os']['release']['major'] ? {
      '6' => false,
      '7' => false,
      default => $facts['os']['distro']['id'] ? {
        'CentOSStream' => true,
        default        => false,
      },
    }
  }
  else {
    $centos_stream = $facts['os']['release']['full'] ? {
      # for CentOS Stream 8 it is just '8' but for CentOS Linux 8 it is 8.x.x
      '8'     => true,
      default => false,
    }
  }

  $helm_configs_path = '/root/.config/helm'
  $helm_charts_path  = "${helm_configs_path}/charts"
}
