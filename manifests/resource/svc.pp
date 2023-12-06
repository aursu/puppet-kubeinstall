# @summary The Service Kubernetes Resource
#
# The Service Kubernetes Resource
#
# @param metadata
#   Standard object's metadata.
#   Available fields are annotations, labels, and namespace
#
# @param type
#   type determines how the Service is exposed.
#
# @param selector
#   Route service traffic to pods with label keys and values matching this
#   selector. If empty or not present, the service is assumed to have an
#   external process managing its endpoints, which Kubernetes will not modify.
#
# @param cluster_ip
#   clusterIP is the IP address of the service and is usually assigned randomly.
#   If an address is specified manually, is in-range (as per system configuration),
#   and is not in use, it will be allocated to the service; otherwise creation of
#   the service will fail. This field may not be changed through updates unless
#   the type field is also being changed to ExternalName (which requires this
#   field to be blank) or the type field is being changed from ExternalName (in
#   which case this field may optionally be specified, as describe above). Valid
#   values are "None", empty string (""), or a valid IP address. Setting this
#   to "None" makes a "headless service" (no virtual IP), which is useful when
#   direct endpoint connections are preferred and proxying is not required.
#   Only applies to types ClusterIP, NodePort, and LoadBalancer. If this field
#   is specified when creating a Service of type ExternalName, creation will
#   fail. This field will be wiped when updating a Service to type ExternalName.
#   More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies
#
# @example
#   kubeinstall::resource::svc { 'namevar': }
define kubeinstall::resource::svc (
  Array[Kubeinstall::ServicePort, 1] $ports,
  Kubeinstall::DNSName $object_name = $name,
  String $namespace = 'default',
  Kubeinstall::Metadata $metadata = {},
  Kubeinstall::ServiceType $type = 'ClusterIP',
  Hash[
    Kubeinstall::Label,
    Variant[Enum[''], Kubeinstall::DNSLabel]
  ] $selector = {},
  Stdlib::Unixpath $manifests_directory = $kubeinstall::manifests_directory,
  Boolean $apply = false,
  Optional[Kubeinstall::ClusterIP] $cluster_ip = undef,
  Stdlib::Unixpath $kubeconfig = '/etc/kubernetes/admin.conf',
) {
  $object_header  = {
    'apiVersion' => 'v1',
    'kind'       => 'Service',
  }

  if $namespace == 'default' {
    $namespace_metadata = {}
  }
  else {
    $namespace_metadata = {
      'namespace' => $namespace,
    }
  }

  $metadata_content = {
    'metadata' => {
      'name' => $object_name,
    } +
    $namespace_metadata +
    $metadata,
  }

  if empty($selector) or $type == 'ExternalName' {
    $spec_selector = {}
  }
  else {
    $spec_selector = { 'selector' => $selector }
  }

  if $cluster_ip and $type in ['ClusterIP', 'NodePort', 'LoadBalancer'] {
    $spec_cluster_ip = { 'clusterIP' => $cluster_ip }
  }
  else {
    $spec_cluster_ip = {}
  }

  $object_spec = {
    'spec' => { 'type' => $type } +
    $spec_selector +
    $spec_cluster_ip + { 'ports' => kubeinstall::service_ports($ports, { 'type' => $type, 'cluster_ip' => $cluster_ip }) },
  }

  $object = to_yaml($object_header + $metadata_content + $object_spec)

  file { $object_name:
    ensure  => file,
    path    => "${manifests_directory}/manifests/services/${object_name}.yaml",
    content => $object,
    mode    => '0600',
  }

  if $apply {
    kubeinstall::kubectl::apply { $object_name:
      kind       => 'Service',
      kubeconfig => $kubeconfig,
#      unless     => "kubectl get -n ${namespace} service/${object_name}",
      subscribe  => File[$object_name],
    }
  }
}
