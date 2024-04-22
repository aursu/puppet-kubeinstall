type Kubeinstall::TypedLocalObjectReference = Variant[
  Struct[{
      name => String,
      kind => Kubeinstall::CoreGroupKind,
      Optional[apiGroup] => Enum['core'],
  }],
  Struct[{
      name => String,
      kind => String,
      apiGroup => String[1],
  }]
]
