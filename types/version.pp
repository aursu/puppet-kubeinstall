# https://kubernetes.io/releases/patch-releases/#detailed-release-history-for-active-branches
type Kubeinstall::Version = Variant[
  # EOL
  Pattern[/^1\.(2[0-9]|30)\.[0-9]$/],
  Pattern[/^(1\.2[068]\.1[0-5]|1\.2[57]\.1[0-6]|1\.2[2-4]\.1[0-7]|1\.(2[19]|30)\.1[0-4])$/],

  # Active
  Pattern[/^(1\.31\.[0-9]|1\.31\.1[0-3]|1\.32\.[0-9]|1\.33\.[0-5]|1\.34\.[01])$/]
]
