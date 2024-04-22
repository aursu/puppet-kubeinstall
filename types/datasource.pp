type Kubeinstall::DataSource = Variant[
  Kubeinstall::PersistentVolumeClaimLocalRef,
  Struct[{
      name => String,
      kind => Enum['VolumeSnapshot'],
      apiGroup => Enum['snapshot.storage.k8s.io'],
  }]
]
