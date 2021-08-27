# @summary Add cleanup script
#
# Add cleanup script into /root/bin/kube-cleanup.sh
#
# @example
#   include kubeinstall::install::cleanup
class kubeinstall::install::cleanup {
  exec { '/root/bin-3059f76':
    command => 'mkdir -p /root/bin',
    path    => '/usr/bin:/bin',
    creates => '/root/bin',
  }

  file { '/root/bin/kube-cleanup.sh':
    ensure => file,
    source => 'puppet:///modules/kubeinstall/kube-cleanup.sh',
    owner  => 'root',
    mode   => '0700',
  }
}
