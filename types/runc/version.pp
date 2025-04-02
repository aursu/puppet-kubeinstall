type Kubeinstall::Runc::Version = Variant[
  Pattern[/^1\.[12]\.[0-9]+$/],
  Enum['installed', 'present', 'absent', 'latest'],
]
