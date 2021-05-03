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
  Kubeinstall::Metadata
          $metadata           = {},
  Hash[String, String]
          $labels             = {},
  Optional[String]
          $storage_class_name = undef,
) {
  if empty($labels) {
    $metadata_labels = {}
  }
  else {
    $metadata_labels = { 'labels' => $labels }
  }

  kubeinstall::resource::pv { $name:
    metadata           => $metadata + $metadata_labels,
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
