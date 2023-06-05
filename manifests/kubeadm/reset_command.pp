# @summary kubeadm reset command
#
# kubeadm reset command
#
# @example
#   include kubeinstall::kubeadm::reset_command
class kubeinstall::kubeadm::reset_command (
  Integer $verbosity_level = 4,
  Optional[Stdlib::Unixpath] $cri_socket = $kubeinstall::cri_socket,
) {
  # /var/run/crio/crio.sock
  if $cri_socket {
    $cri_socket_flag = " --cri-socket=${cri_socket}"
  }
  else {
    $cri_socket_flag = ''
  }

  exec { 'kubeadm-reset':
    command     => "kubeadm reset -f --v=${verbosity_level}${cri_socket_flag}",
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    onlyif      => [
      'test -f /etc/kubernetes/kubelet.conf',
      'test -f /var/lib/kubelet/config.yaml',
    ],
    refreshonly => true,
  }
}
