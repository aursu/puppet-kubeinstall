# @summary TopoLVM lvmd installation
#
# TopoLVM lvmd installation as a systemd service
#
# @param version
#   TopoLVM lvmd version
#
# @param socket_name
#   Unix domain socket endpoint of gRPC
#
# @example
#   include kubeinstall::topolvm::lvmd
class kubeinstall::topolvm::lvmd (
  String $version = $kubeinstall::lvmd_version,
  Array[Kubeinstall::TopoLVMDeviceClass] $device_classes = [],
  Stdlib::Unixpath $socket_name = '/run/topolvm/lvmd.sock',
) {
  $archive      = "lvmd-${version}.tar.gz"
  $source       = "https://github.com/topolvm/topolvm/releases/download/v${version}/lvmd-${version}.tar.gz"

  file { ['/opt/sbin', '/etc/topolvm']:
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

  $device_classes_config = $device_classes.map |$dev_class| {
    {
      'name'         => $dev_class['name'],
      'volume-group' => $dev_class['volumeGroup'],
    } +
    ($dev_class['spareGB'] ? {
        Integer => { 'spare-gb' => $dev_class['spareGB'] },
        default => {},
    }) +
    ($dev_class['isDefault'] ? {
        Boolean => { 'default' => $dev_class['isDefault'] },
        default => {},
    }) +
    ($dev_class['stripeSize'] ? {
        String => { 'stripe-size' => $dev_class['stripeSize'] },
        default => {},
    }) +
    ($dev_class['lvCreateOptions'] ? {
        Array[String, 1] => { 'lvcreate-options' => $dev_class['lvCreateOptions'] },
        default => {},
    }) +
    ($dev_class['type'] ? {
        'thin' => {
          'thin-pool' => {
            'name'                => $dev_class['thinPool']['name'],
            'overprovision-ratio' => $dev_class['thinPool']['overprovisionRatio'],
          },
        },
        default => {},
    }) +
    ($dev_class - ['thinPool', 'lvCreateOptions', 'stripeSize', 'isDefault', 'spareGB', 'volumeGroup'])
  }

  $config = {
    'socket-name'    => $socket_name,
    'device-classes' => $device_classes_config,
  }

  file { '/etc/topolvm/lvmd.yaml':
    ensure  => file,
    content => to_yaml($config),
    mode    => '0644',
  }
}
