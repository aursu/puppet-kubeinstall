# https://kubernetes.io/docs/concepts/overview/working-with-objects/names#dns-subdomain-names
# contain no more than 253 characters
# contain only lowercase alphanumeric characters, '-' or '.'
# start with an alphanumeric character
# end with an alphanumeric character
type Kubeinstall::DNSSubdomain = Pattern[/^[a-z0-9]([.a-z0-9-]{0,251}[a-z0-9])?$/]
