# @summary Added autocompletion for Helm
#
# Added autocompletion for Helm
#
# @example
#   include kubeinstall::helm::completion
class kubeinstall::helm::completion {
  include kubeinstall::install::helm_binary
  include kubeinstall::system::completion

  # bash autocompletion
  exec { 'helm completion bash':
    command => 'helm completion bash > /root/.config/helm/completion.bash.inc',
    creates => '/root/.config/helm/completion.bash.inc',
    path    => '/usr/local/bin:/usr/bin:/bin',
    require => Class['kubeinstall::install::helm_binary'],
  }

  file { '/etc/profile.d/helm.sh':
    ensure => file,
    source => 'puppet:///modules/kubeinstall/helm/profile.d.sh',
  }
}
