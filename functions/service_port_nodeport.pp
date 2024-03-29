# The port on each node on which this service is exposed when type is NodePort or
# LoadBalancer. Usually assigned by the system. If a value is specified, in-range,
# and not in use it will be used, otherwise the operation will fail. If not
# specified, a port will be allocated if this Service requires one. If this field
# is specified when creating a Service which does not need it, creation will fail.
# This field will be wiped when updating a Service to no longer need it (e.g.
# changing type from NodePort to ClusterIP). More info:
# https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
function kubeinstall::service_port_nodeport(Kubeinstall::ServicePort $port, Kubeinstall::ServiceType $type) >> Hash {
  if $port['nodePort'] and $type in ['NodePort', 'LoadBalancer'] {
    { 'nodePort' => $port['nodePort'] }
  }
  else {
    {}
  }
}
