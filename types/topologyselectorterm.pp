# https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.21/#topologyselectorterm-v1-core
type Kubeinstall::TopologySelectorTerm = Struct[{
  matchLabelExpressions => Array[Kubeinstall::TopologySelectorLabelRequirement],
}]
