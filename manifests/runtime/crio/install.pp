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
  Kubeinstall::Release $kubernetes_release = $kubeinstall::kubernetes_release,
  Variant[
    Enum['installed', 'latest'],
    Pattern[/^1\.[0-9]+\.[0-9]+(~[0-9]+)?$/]
  ] $crio_version = $kubeinstall::crio_version,
  String $crio_runc_version = $kubeinstall::crio_runc_version,
) {
  include bsys::params
  include kubeinstall::repos::crio
  include bsys::systemctl::daemon_reload

  if $crio_version in ['installed', 'latest'] {
    $os_crio_version = $crio_version
    $criorel = $kubernetes_release
    $crio_release = "${criorel}.0"
  }
  else {
    if $bsys::params::osname == 'Ubuntu' {
      if versioncmp($crio_version, '1.28.2') >= 0 {
        # there is slightly different build version since 1.28.2 hosted on pkgs.k8s.io
        $version_data  = split($crio_version, '[-]')
        if $version_data[1] {
          $os_crio_version = $crio_version
        }
        else {
          $os_crio_version = "${crio_version}-1.1"
        }
      } else {
        # valid for repositories from devel:kubic:libcontainers:stable:cri-o
        $version_data  = split($crio_version, '[~]')
        if $version_data[1] {
          $os_crio_version = $crio_version
        }
        else {
          $os_crio_version = "${crio_version}~0"
        }
      }
    }
    else {
      $os_crio_version = $crio_version
    }
    $crio_release = $crio_version
  }

  package { 'cri-o':
    ensure  => $os_crio_version,
    notify  => Class['bsys::systemctl::daemon_reload'],
    require => Class['kubeinstall::repos::crio'],
  }

  case $bsys::params::osfam {
    'Debian': {
      if versioncmp($crio_release, '1.28.2') < 0 {
        package { 'cri-o-runc':
          ensure => $crio_runc_version,
          before => Package['cri-o'],
        }

        # fix sequence of repository update and package installation
        Class['apt::update'] -> Package['cri-o-runc']
      }
    }
    'RedHat': {
      # if $bsys::params::osmaj == '8' and $bsys::params::centos_stream {
      #   file {
      #     '/etc/containers':
      #       ensure => directory,
      #       ;
      #     '/etc/containers/policy.json':
      #       ensure  => file,
      #       content => file('kubeinstall/cri-o/policy.json'),
      #       require => Package['cri-o'],
      #       ;
      #   }
      # }
    }
    default: {}
  }
}
