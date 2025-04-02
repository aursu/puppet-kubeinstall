type Kubeinstall::NerdCTL::Version = Variant[
  # 1.2.1, 1.3.0, 1.3.1, 1.4.0, 1.5.0, 1.6.0-1.6.2, 1.7.0-1.7.5
  Pattern[/^1\.[0-7]\.[0-6]+$/],
  Pattern[/^2\.0\.[0-4]+$/],
  Enum['installed', 'present', 'absent', 'latest'],
]
