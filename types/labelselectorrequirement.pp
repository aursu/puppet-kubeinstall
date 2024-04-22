# https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#labelselectorrequirement-v1-meta
#
type Kubeinstall::LabelSelectorRequirement = Variant[
  Kubeinstall::MatchExpressionIn,
  Kubeinstall::MatchExpressionExists
]
