# @summary CRI-O packages installation
#
# CRI-O packages installation
#
# @param crio_version
#   CRI-O version to install (or installed, latest)
#
# @param crio_runc_version
#   CRI-O runc version (could be also installed, latest, absent)
#
# @example
#   include kubeinstall::runtime::crio::install
class kubeinstall::runtime::crio::install (
  String $crio_version = $kubeinstall::crio_version,
  String $crio_runc_version = $kubeinstall::crio_runc_version,
) {
  include kubeinstall::repos::crio
  include kubeinstall::systemctl::daemon_reload

  package { 'cri-o':
    ensure  => $crio_version,
    notify  => Class['kubeinstall::systemctl::daemon_reload'],
    require => Class['kubeinstall::repos::crio'],
  }

  if $facts['os']['family'] == 'Debian' {
    package { 'cri-o-runc':
      ensure => $crio_runc_version,
      before => Package['cri-o'],
    }

    # fix sequence of repository update and package installation
    Class['apt::update'] -> Package['cri-o-runc']
  }
}
