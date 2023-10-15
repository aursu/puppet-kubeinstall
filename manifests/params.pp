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
  $pod_network_cidr        = '172.16.0.0/16'
  $service_node_port_range = '30000-32767'
  $dashboard_configuration = 'https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml'
  # directory where to store static manifests under folder 'manifests'
  $manifests_directory     = '/etc/kubectl'

  $helm_configs_path = '/root/.config/helm'
  $helm_charts_path  = "${helm_configs_path}/charts"

  $topolvm_scheduler_path = '/var/lib/kubelet/plugins/topolvm.io/scheduler'

  $cert_dir = '/etc/kubernetes/pki'

  $containerd_version = '1.7.7'
  $runc_version = '1.1.9'
  $cni_plugins_version = '1.3.0'
  $nerdctl_version = '1.6.2'

  $cni_plugins_dir_path = '/opt/cni'
  $cni_plugins_dir = "${cni_plugins_dir_path}/bin"
}
