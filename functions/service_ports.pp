function kubeinstall::service_ports(
  Array[Kubeinstall::ServicePort] $ports,
  Struct[{
    type       => Kubeinstall::ServiceType,
    cluster_ip => Optional[Kubeinstall::ClusterIP],
  }] $options
) >> Array {
  $ports.map |$port| {
    kubeinstall::service_port_name($ports, $port) +
    { 'port' => $port['port'] } +
    kubeinstall::service_port_protocol($port) +
    kubeinstall::service_port_nodeport($port, $options['type']) +
    kubeinstall::service_port_targetport($port, $options['cluster_ip']) +
    kubeinstall::service_port_appprotocol($port)
  }
}
