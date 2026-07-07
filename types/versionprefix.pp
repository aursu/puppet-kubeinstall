# https://kubernetes.io/releases/patch-releases/#detailed-release-history-for-active-branches
type Kubeinstall::VersionPrefix = Variant[
  # EOL
  Pattern[/^1\.(2[0-9]|30)\.[0-9]/],
  Pattern[/^(1\.2[068]\.1[0-5]|1\.2[57]\.1[0-6]|1\.2[2-4]\.1[0-7]|1\.(2[19]|30)\.1[0-4])/],
  Pattern[/^(1\.3[12]\.[0-9]|1\.31\.1[0-4]|1\.32\.1[0-3])/],
  # Active
  Pattern[/^(1\.3[34]\.[1-9]|1\.33\.1[0-3]|1\.35\.[1-6]|1\.36\.[12])/]
]
