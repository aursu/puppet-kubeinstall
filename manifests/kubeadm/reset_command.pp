# @summary kubeadm reset command
#
# kubeadm reset command
#
# @example
#   include kubeinstall::kubeadm::reset_command
class kubeinstall::kubeadm::reset_command (
  Integer $verbosity_level = 4,
)
{
  exec { 'kubeadm-reset':
    command     => "kubeadm reset -f --v=${verbosity_level}",
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    onlyif      => [
      'test -f /etc/kubernetes/kubelet.conf',
      'test -f /var/lib/kubelet/config.yaml',
    ],
    refreshonly => true,
  }
}
