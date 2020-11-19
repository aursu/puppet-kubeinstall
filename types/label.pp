# Labels are key/value pairs. Valid annotation keys have two segments: an
# optional prefix and name, separated by a slash (/). The name segment is
# required and must be 63 characters or less, beginning and ending with an
# alphanumeric character ([a-z0-9A-Z]) with dashes (-), underscores (_),
# dots (.), and alphanumerics between. The prefix is optional. If specified,
# the prefix must be a DNS subdomain: a series of DNS labels separated by
# dots (.), not longer than 253 characters in total, followed by a slash (/).
type Kubeinstall::Label =
  Pattern[/^([a-z0-9]([.a-z0-9-]{0,251}[a-z0-9])?\/)?[a-z0-9A-Z]([_.a-z0-9A-Z-]{0,61}[a-z0-9A-Z])?$/]
