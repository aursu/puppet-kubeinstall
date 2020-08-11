# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @param web_ui_dashboard
#   Whether to install Web UI on controller node or not
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
  String  $calico_cni_version,
  Boolean $join_control_plane,
  Optional[Kubeinstall::Token]
          $join_token,
  Optional[Kubeinstall::CACertHash]
          $join_ca_cert_hash,
  Optional[Kubeinstall::Address]
          $join_apiserver_address,
  Integer $join_apiserver_port,
  Boolean $web_ui_dashboard,
  Optional[Kubeinstall::Address]
          $control_plane_endpoint      = undef,
  Optional[Integer]
          $docker_mtu                  = undef,
  String  $cluster_name                = 'kubernetes',
  Stdlib::Fqdn
          $node_name                   = $facts['networking']['fqdn'],
  String  $apiserver_advertise_address = $facts['networking']['ip'],
  Integer $apiserver_bind_port         = $kubeinstall::params::apiserver_bind_port,
  String  $cri_socket                  = $kubeinstall::params::cri_socket,
  Stdlib::Fqdn
          $service_dns_domain          = $kubeinstall::params::service_dns_domain,
  Stdlib::IP::Address
          $service_cidr                = $kubeinstall::params::service_cidr,
  Variant[
    Stdlib::HTTPUrl,
    Stdlib::Unixpath
  ]       $dashboard_configuration     = $kubeinstall::params::dashboard_configuration,
) inherits kubeinstall::params
{
}
