type Kubeinstall::ClaimObjectReference = Struct[{
    name       => String,
    namespace  => String,
    Optional[apiVersion] => Enum['v1'],
    Optional[kind] => Enum['PersistentVolumeClaim'],
    Optional[fieldPath] => String,
}]
