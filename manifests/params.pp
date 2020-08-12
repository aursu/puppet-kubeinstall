# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::params
class kubeinstall::params {
  $apiserver_bind_port     = 6443
  $cri_socket              = '/var/run/dockershim.sock'
  $service_dns_domain      = 'cluster.local'
  $service_cidr            = '10.96.0.0/12'
  $dashboard_configuration = 'https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml'
  $calicoctl_version       = 'v3.15.1'
}
