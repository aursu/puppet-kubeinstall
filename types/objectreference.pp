type Kubeinstall::ObjectReference = Struct[{
    name       => String,
    apiVersion => String,
    kind       => String,
    namespace  => String,
    Optional[fieldPath] => String,
}]
