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
  # 2.7.0 is the last version of dashboard with manifest installation method
  $dashboard_configuration = 'https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml'
  $dashboard_version        = '7.1.0'
  # directory where to store static manifests under folder 'manifests'
  $manifests_directory     = '/etc/kubectl'

  $helm_configs_path = '/root/.config/helm'
  $helm_charts_path  = "${helm_configs_path}/charts"

  $topolvm_scheduler_path = '/var/lib/kubelet/plugins/topolvm.io/scheduler'

  $cert_dir = '/etc/kubernetes/pki'

  # https://github.com/containerd/containerd/releases
  $containerd_version = '1.7.27'
  # https://github.com/opencontainers/runc/releases
  $runc_version = '1.2.6'
  # https://github.com/containernetworking/plugins/releases
  $cni_plugins_version = '1.6.2'
  # https://github.com/containerd/nerdctl/releases
  $nerdctl_version = '2.0.4'
  # https://github.com/kubernetes-sigs/cri-tools/releases
  $cri_tools_version = '1.32.0'

  $cni_plugins_dir_path = '/opt/cni'
  $cni_plugins_dir = "${cni_plugins_dir_path}/bin"
}
