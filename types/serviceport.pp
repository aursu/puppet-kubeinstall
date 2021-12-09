type Kubeinstall::ServicePort = Struct[{
  port        => Kubeinstall::Port,
  name        => Optional[Kubeinstall::DNSLabel],
  nodePort    => Optional[Kubeinstall::Port],
  # If this is not specified, the value of the 'port' field is used (an identity map).
  targetPort  => Optional[Variant[Kubeinstall::Port, Kubeinstall::IANASvcName]],
  protocol    => Optional[Enum['TCP', 'UDP', 'SCTP']],
  appProtocol => Optional[Kubeinstall::Label],
}]
