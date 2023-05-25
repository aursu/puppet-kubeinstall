# @summary TopoLVM lvmd installation
#
# TopoLVM lvmd installation as a systemd service
#
# @example
#   include kubeinstall::topolvm::lvmd
class kubeinstall::topolvm::lvmd (
  String $version = $kubeinstall::lvmd_version,
) {
  $archive      = "lvmd-${version}.tar.gz"
  $source       = "https://github.com/topolvm/topolvm/releases/download/v${version}/lvmd-${version}.tar.gz"

  file { '/opt/sbin':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  archive { $archive:
    path         => "/tmp/${archive}",
    source       => $source,
    extract      => true,
    extract_path => '/opt/sbin',
    cleanup      => true,
    creates      => '/opt/sbin/lvmd',
    require      => File['/opt/sbin'],
  }

  file { '/opt/sbin/lvmd':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Archive[$archive],
  }
}
