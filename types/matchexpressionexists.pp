type Kubeinstall::MatchExpressionExists = Struct[{
    key      => String,
    operator => Enum['Exists', 'DoesNotExist'],
    Optional[values]   => Array[String, 0, 0],
}]
