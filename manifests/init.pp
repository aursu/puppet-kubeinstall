# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @param web_ui_dashboard
#   Whether to install Web UI on controller node or not
#
# @param manifests_directory
#   Directory where to store static manifests
#
# @example
#   include kubeinstall
class kubeinstall (
  Kubeinstall::Version
          $kubernetes_version,
  Kubeinstall::Runtime
          $container_runtime,
  String  $dockerd_version,
  String  $containerd_version,
  String  $crio_version,
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
  Kubeinstall::CgroupDriver
          $cgroup_driver,
  Integer $join_apiserver_port,
  Boolean $web_ui_dashboard,
  Optional[Kubeinstall::Address]
          $control_plane_endpoint,
  Optional[Integer]
          $docker_mtu,
  Optional[String]
          $network_bridge_ip,
  Optional[Integer]
          $calico_mtu,
  String  $cluster_name,
  Boolean $install_calicoctl,
  String  $calicoctl_version,
  String  $helm_version,
  String  $krew_version,
  Stdlib::Fqdn
          $node_name                   = $facts['networking']['fqdn'],
  String  $apiserver_advertise_address = $facts['networking']['ip'],
  Integer $apiserver_bind_port         = $kubeinstall::params::apiserver_bind_port,
  Stdlib::Unixpath
          $cri_socket                  = $container_runtime ? {
                                            'docker' => $kubeinstall::params::docker_socket,
                                            default => $kubeinstall::params::crio_socket,
                                          },
  Stdlib::Fqdn
          $service_dns_domain          = $kubeinstall::params::service_dns_domain,
  Stdlib::IP::Address
          $service_cidr                = $kubeinstall::params::service_cidr,
  String  $service_node_port_range     = $kubeinstall::params::service_node_port_range,
  Variant[
    Stdlib::HTTPUrl,
    Stdlib::Unixpath
  ]       $dashboard_configuration     = $kubeinstall::params::dashboard_configuration,
  Stdlib::Unixpath
          $manifests_directory         = $kubeinstall::params::manifests_directory,
) inherits kubeinstall::params
{
  # https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-octavia-ingress-controller.md
  # https://kubernetes.io/docs/concepts/storage/storage-classes/#openstack-cinder

  $version_data  = split($kubernetes_version, '[.]')
  $major_version = $version_data[0]
  $minor_version = $version_data[1]

  # kubernetes_release is Kubernetes version for minor release (Kube X.Y)
  $kubernetes_release = "${major_version}.${minor_version}"
}
