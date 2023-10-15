type Kubeinstall::NerdCTL::Version = Variant[
  Pattern[/^1\.[0-6]\.[0-9]+$/],
  Enum['installed', 'present', 'absent', 'latest'],
]
