type Kubeinstall::LabelSelector = Variant[
  Struct[{
      matchExpressions => Array[Kubeinstall::LabelSelectorRequirement],
      matchLabels      => Hash[String, String],
  }],
  Struct[{
      matchExpressions => Array[Kubeinstall::LabelSelectorRequirement],
  }],
  Struct[{
      matchLabels => Hash[String, String, 1],
  }],
]
