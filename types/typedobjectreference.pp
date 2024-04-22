type Kubeinstall::TypedObjectReference = Variant[
  Struct[{
      name => String,
      kind => Kubeinstall::CoreGroupKind,
      Optional[apiGroup] => Enum['core'],
      Optional[namespace] => String,
  }],
  Struct[{
      name => String,
      kind => String,
      apiGroup => String[1],
      Optional[namespace] => String,
  }]
]
