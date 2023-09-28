# https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.21/#topologyselectorlabelrequirement-v1-core
type Kubeinstall::TopologySelectorLabelRequirement = Struct[{
    key    => String,
    values => Array[String],
}]
