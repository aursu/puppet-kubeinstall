# @summary containerd service management
#
# containerd systemd unit setup, service enable and run
#
# @example
#   include kubeinstall::runtime::containerd::service
class kubeinstall::runtime::containerd::service {
  include bsys::systemctl::daemon_reload

  file { '/etc/systemd/system/containerd.service':
    ensure  => file,
    content => file('kubeinstall/containerd.service'),
    notify  => Class['bsys::systemctl::daemon_reload'],
  }
}
