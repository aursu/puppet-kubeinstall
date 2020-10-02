type Kubeinstall::MatchExpression = Variant[
  Kubeinstall::MatchExpressionIn,
  Kubeinstall::MatchExpressionExists,
  Kubeinstall::MatchExpressionNum,
]
