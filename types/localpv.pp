type Kubeinstall::LocalPV = Struct[{
    path               => Stdlib::Unixpath,
    volume_storage     => Kubeinstall::Quantity,
    name               => Optional[Kubeinstall::DNSName],
    hostname           => Optional[Stdlib::Fqdn],
    storage_class_name => Optional[String],
    volume_mode        => Optional[Kubeinstall::VolumeMode],
}]
