# The name of this port within the service. This must be a DNS_LABEL. All ports
# within a ServiceSpec must have unique names. When considering the endpoints for
# a Service, this must match the 'name' field in the EndpointPort. Optional if
# only one ServicePort is defined on this service.
function kubeinstall::service_port_name(
  Array[Kubeinstall::ServicePort] $ports,
  Kubeinstall::ServicePort $port) >> Hash {
  $port_name         = $port['name']
  $ports_names       = $ports.filter |$p| { $p['name'] }
  $port_name_overall = $ports_names.filter |$n| { $n['name'] == $port_name }

  if $ports.length == 1 {
    if $port_name {
      { 'name' => $port_name }
    }
    else {
      {}
    }
  }
  else {
    if $port_name {
      if $port_name_overall.length == 1 {
        { 'name' => $port_name }
      }
      else {
        fail('All ports within a ServiceSpec must have unique names')
      }
    }
    else {
      fail('Optional if only one ServicePort is defined on this service')
    }
  }
}
