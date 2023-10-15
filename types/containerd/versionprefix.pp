type Kubeinstall::Containerd::VersionPrefix = Variant[
  Pattern[/^1\.[0-7]\.[0-9]+/],
  Enum['installed', 'present', 'absent', 'latest'],
]
