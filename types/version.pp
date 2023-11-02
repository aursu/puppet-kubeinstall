# https://kubernetes.io/docs/setup/release/version-skew-policy/
type Kubeinstall::Version = Variant[
  Pattern[/^1\.2[0-8]\.[0-9]+$/],
]
