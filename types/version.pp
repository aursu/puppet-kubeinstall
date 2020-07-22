type Kubeinstall::Version = Variant[
    Enum['present', 'installed', 'absent'],
    Pattern[/^1\.1[6-8]\./],  # https://kubernetes.io/docs/setup/release/version-skew-policy/
]
