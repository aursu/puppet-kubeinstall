# https://kubernetes.io/releases/patch-releases/#detailed-release-history-for-active-branches
type Kubeinstall::Version = Variant[
  # EOL
  Pattern[/^1\.2[0-9]\.[0-9]$/],
  Pattern[/^(1\.2[068]\.1[0-5]|1\.2[57]\.1[0-6]|1\.2[2-4]\.1[0-7]|1\.2[19]\.1[0-4]|1\.29\.10)$/],

  # Active
  Pattern[/^(1\.30\.[0-9]|1\.30\.10|1\.31\.[0-6]|1\.32\.[0-2])$/]
]
