# must be an IANA_SVC_NAME (at most 15 characters, matching regex [a-z0-9]([a-z0-9-]*[a-z0-9])*,
# it must contain at least one letter [a-z], and hyphens cannot be adjacent to other hyphens
type Kubeinstall::IANASvcName = Pattern[/^[a-z0-9]([a-z0-9-]{0,1}[a-z0-9]){0,7}$/]
