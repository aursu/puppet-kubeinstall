# @summary Install git tool
#
# Install git tool (required by krew)
#
# @example
#   include kubeinstall::system::git
class kubeinstall::system::git {
  package { 'git':
    ensure => 'present'
  }
}
