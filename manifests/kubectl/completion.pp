# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::kubectl::completion
class kubeinstall::kubectl::completion {
  include kubeinstall::system::completion

  # bash autocompletion
  exec { 'kubectl completion bash':
    command => 'kubectl completion bash > /root/.kube/completion.bash.inc',
    creates => '/root/.kube/completion.bash.inc',
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
  }

  file { '/etc/profile.d/kubectl.sh':
    ensure => file,
    source => 'puppet:///modules/kubeinstall/kubectl/profile.d.sh',
  }
}
