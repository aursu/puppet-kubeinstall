# @summary containerd service management
#
# containerd systemd unit setup, service enable and run
#
# @example
#   include kubeinstall::runtime::containerd::service
class kubeinstall::runtime::containerd::service {
  include bsys::systemctl::daemon_reload

  include kubeinstall::runtime::containerd::install
  include kubeinstall::runtime::containerd::config
  include kubeinstall::runtime::containerd::runc
  include kubeinstall::cni::plugins
  include kubeinstall::cni::config::bridge
  include kubeinstall::cni::config::loopback

  file { '/etc/systemd/system/containerd.service':
    ensure  => file,
    content => file('kubeinstall/containerd/containerd.service'),
    notify  => Class['bsys::systemctl::daemon_reload'],
  }

  service { 'containerd':
    ensure  => running,
    enable  => true,
    require => File['/etc/systemd/system/containerd.service'],
  }

  Class['kubeinstall::runtime::containerd::install'] -> Class['kubeinstall::runtime::containerd::config']
  Class['kubeinstall::runtime::containerd::config'] ~> Service['containerd']
  Class['kubeinstall::runtime::containerd::runc'] -> Service['containerd']
  Class['kubeinstall::cni::plugins'] -> Service['containerd']
  Class['kubeinstall::cni::config::bridge'] ~> Service['containerd']
  Class['kubeinstall::cni::config::loopback'] ~> Service['containerd']
}
