# @summary Install bash completion package
#
# Install bash completion package
#
# @example
#   include kubeinstall::system::completion
class kubeinstall::system::completion {
  package { 'bash-completion':
    ensure => 'present',
  }
}
