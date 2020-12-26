# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::service
class kubeinstall::service
{
  include kubeinstall::install

  # kubelet[26217]: F0722 16:24:01.751284   26217 server.go:199] failed to load
  # Kubelet config file /var/lib/kubelet/config.yaml, error failed to read kubelet
  # config file "/var/lib/kubelet/config.yaml", error: open /var/lib/kubelet/config.yaml: no such file or directory

  service { 'kubelet':
    ensure    => running,
    enable    => true,
    subscribe => Class['kubeinstall::install'],
  }
}
