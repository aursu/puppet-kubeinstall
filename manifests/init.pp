# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall
class kubeinstall (
  Kubeinstall::Version
          $kubernetes_version,
  String  $dockerd_version,
  String  $containerd_version,
  Boolean $manage_kernel_modules,
  Boolean $manage_sysctl_settings,
  Boolean $disable_swap,
  Boolean $disable_firewall,
  Boolean $disable_selinux,
  String $calico_cni_version,
  Stdlib::Fqdn
          $node_name                   = $facts['networking']['fqdn'],
  String  $apiserver_advertise_address = $facts['networking']['ip'],
  Integer $apiserver_bind_port         = 6443,
  String  $cri_socket                  = '/var/run/dockershim.sock',
  String  $cluster_name                = 'kubernetes',
  Stdlib::Fqdn
          $service_dns_domain         = 'cluster.local',
  Stdlib::IP::Address
          $service_cidr               = '10.96.0.0/12',
  Optional[String]
          $control_plane_endpoint     = undef,
)
{
}
