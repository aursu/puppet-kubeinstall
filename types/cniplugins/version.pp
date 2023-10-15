type Kubeinstall::CNIPlugins::Version = Variant[
  Pattern[/^1\.[0-3]\.[0-9]$/],
  Enum['installed', 'present', 'absent', 'latest'],
]
