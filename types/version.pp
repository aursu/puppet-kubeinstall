# https://kubernetes.io/releases/patch-releases/#detailed-release-history-for-active-branches
type Kubeinstall::Version = Variant[
  # EOL
  Pattern[/^1\.2[0-6]\.[0-9]$/],
  Pattern[/^(1\.2[06]\.1[0-5]|1\.25\.1[0-6]|1\.2[2-4]\.1[0-7]|1\.21\.1[0-4])$/],
  # Active
  Pattern[/^(1\.2[7-9]\.[0-9]|1\.27\.1[0-6]|1\.28\.1[0-4]|1\.29\.10|1\.30\.[0-6]|1\.31\.[0-2])$/]
]
