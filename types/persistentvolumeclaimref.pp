# contains enough information to let you locate the PersistentVolumeClaim
# referenced object inside the same namespace
type Kubeinstall::PersistentVolumeClaimRef = Struct[{
    name => String,
    kind => Enum['PersistentVolumeClaim'],
    Optional[apiGroup] => Enum['core'],
    Optional[namespace] => String,
}]
