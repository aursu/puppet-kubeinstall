# https://kubernetes.io/docs/setup/release/version-skew-policy/
type Kubeinstall::Version = Variant[
  Pattern[/^1\.2[0-9]\.[0-9]+$/],
]
