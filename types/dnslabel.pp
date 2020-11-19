# https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-label-names
# contain at most 63 characters
# contain only lowercase alphanumeric characters or '-'
# start with an alphanumeric character
# end with an alphanumeric character

type Kubeinstall::DNSLabel = Pattern[/^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$/]
