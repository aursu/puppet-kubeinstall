# The application protocol for this port. This field follows standard Kubernetes
# label syntax. Un-prefixed names are reserved for IANA standard service names
# (as per RFC-6335 and http://www.iana.org/assignments/service-names). Non-
# standard protocols should use prefixed names such as mycompany.com/my-custom-protocol.
function kubeinstall::service_port_appprotocol(Kubeinstall::ServicePort $port) >> Hash {
  if $port['appProtocol'] {
    { 'appProtocol' => $port['appProtocol'] }
  }
  else {
    {}
  }
}
