type Kubeinstall::CNIPlugins::Version = Variant[
  # https://github.com/containernetworking/plugins/releases
  # 1.3.0, 1.4.0, 1.4.1, 1.5.0, 1.5.1, 1.6.0, 1.6.1, 1.6.2
  Pattern[/^1\.[0-6]\.[0-2]$/],
  Enum['installed', 'present', 'absent', 'latest'],
]
