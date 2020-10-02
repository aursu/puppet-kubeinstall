type Kubeinstall::MatchExpressionIn = Struct[{
  key      => String,
  operator => Enum['In', 'NotIn'],
  values   => Array[String, 1],
}]
