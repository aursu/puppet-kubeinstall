type Kubeinstall::MatchExpressionNum = Struct[{
    key      => String,
    operator => Enum['Gt', 'Lt'],
    values   => Array[Pattern[/^[0-9]+$/], 1, 1],
}]
