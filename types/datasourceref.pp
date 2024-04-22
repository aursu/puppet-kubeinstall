type Kubeinstall::DataSourceRef = Variant[
  Kubeinstall::PersistentVolumeClaimRef,
  Struct[{
      name => String,
      kind => String,
      apiGroup => String[1],
      Optional[namespace] => String,
  }]
]
