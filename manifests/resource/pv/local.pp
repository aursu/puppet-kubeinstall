# @summary Local persistent storage volume
#
# Local persistent storage volume
#
# @example
#   kubeinstall::resource::pv::local { 'namevar': }
define kubeinstall::resource::pv::local (
  String  $volume_storage,
  String  $path,
  Stdlib::Fqdn
          $hostname,
  Optional[String]
          $storage_class_name = undef,
) {
  kubeinstall::resource::pv { $title:
    volume_storage     => $volume_storage,
    local_path         => $path,
    match_expressions  => [
      {
        key      => 'kubernetes.io/hostname',
        operator => 'In',
        values   => [ $hostname ],
      }
    ],
    storage_class_name => $storage_class_name,
  }
}
