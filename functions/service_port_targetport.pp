# Number or name of the port to access on the pods targeted by the service.
# Number must be in the range 1 to 65535. Name must be an IANA_SVC_NAME. If
# this is a string, it will be looked up as a named port in the target Pod's
# container ports. If this is not specified, the value of the 'port' field is
# used (an identity map). This field is ignored for services with clusterIP=None,
# and should be omitted or set equal to the 'port' field. More info:
# https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service
function kubeinstall::service_port_targetport(Kubeinstall::ServicePort $port, Optional[Kubeinstall::ClusterIP] $cluster_ip = undef) >> Hash {
  if $port['targetPort'] {
    $target_port = $port['targetPort']
  }
  else {
    $target_port = $port['port']
  }

  if $cluster_ip {
    if $cluster_ip == 'None' {
      {}
    }
    else {
      { 'targetPort' => $target_port }
    }
  }
  else {
    { 'targetPort' => $target_port }
  }
}
