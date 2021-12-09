# The IP protocol for this port. Supports "TCP", "UDP", and "SCTP". Default is TCP.
function kubeinstall::service_port_protocol(Kubeinstall::ServicePort $port) >> Hash {
  if $port['protocol'] {
    { 'protocol' => $port['protocol'] }
  }
  else {
    { 'protocol' => 'TCP' }
  }
}
