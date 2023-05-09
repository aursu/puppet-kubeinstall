# @summary Install git tool
#
# Install git tool (required by krew)
#
# @example
#   include kubeinstall::system::git
class kubeinstall::system::git (
  Boolean $manage = $kubeinstall::manage_git,
) {
  # git package could be controlled in different place of role/profile
  # therefore make it possible to disable it here
  if $manage {
    package { 'git':
      ensure => 'present'
    }
  }
}
