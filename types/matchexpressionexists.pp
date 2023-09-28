type Kubeinstall::MatchExpressionExists = Struct[{
    key      => String,
    operator => Enum['Exists', 'DoesNotExist'],
    values   => Array[String, 0, 0],
}]
