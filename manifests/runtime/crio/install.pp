# @summary CRI-O packages installation
#
# CRI-O packages installation
#
# @example
#   include kubeinstall::runtime::crio::install
class kubeinstall::runtime::crio::install (
  String  $crio_version = $kubeinstall::crio_version,
)
{
  include kubeinstall::repos::crio
  include kubeinstall::systemctl::daemon_reload

  package { 'cri-o':
    ensure  => $crio_version,
    notify  => Class['kubeinstall::systemctl::daemon_reload'],
    require => Class['kubeinstall::repos::crio'],
  }

  if $facts['os']['family'] == 'Debian' {
    package { 'cri-o-runc':
      ensure => $crio_version,
      before => Package['cri-o']
    }

    # try to fix repository update scheduled after package installation
    Class['apt::update'] -> Package['cri-o-runc']
  }
}
