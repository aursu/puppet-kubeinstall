type Kubeinstall::CNIPlugins::Version = Variant[
  # 1.0.0, 1.0.1, 1.1.0, 1.1.1, 1.2.0, 1.3.0, 1.4.0, 1.4.1
  Pattern[/^1\.[0-4]\.[0-1]$/],
  Enum['installed', 'present', 'absent', 'latest'],
]
