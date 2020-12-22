# https://kubernetes.io/docs/setup/release/version-skew-policy/
type Kubeinstall::Version = Variant[
  Pattern[/^1\.1[6-9]\.[0-9]+/],
  Pattern[/^1\.2[01]\.[0-9]+/],
]
