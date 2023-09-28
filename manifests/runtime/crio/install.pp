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
  Variant[
    Enum['installed', 'latest'],
    Pattern[/^1\.[0-9]+\.[0-9]+(~[0-9]+)?$/]
  ] $crio_version = $kubeinstall::crio_version,
  String $crio_runc_version = $kubeinstall::crio_runc_version,
) {
  include kubeinstall::repos::crio
  include bsys::systemctl::daemon_reload

  $osname = $facts['os']['name']
  $version_data  = split($crio_version, '[~]')

  if $osname == 'Ubuntu' {
    if $version_data[1] {
      $os_crio_version = $crio_version
    }
    else {
      $os_crio_version = "${crio_version}~0"
    }
  }
  else {
    $os_crio_version = $crio_version
  }

  package { 'cri-o':
    ensure  => $os_crio_version,
    notify  => Class['bsys::systemctl::daemon_reload'],
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
