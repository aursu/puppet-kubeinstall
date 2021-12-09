# @summary Apply Kubernetes manifest
#
# Apply Kubernetes manifest
#
# @example
#   kubeinstall::kubectl::apply { 'namevar': }
define kubeinstall::kubectl::apply (
  Enum['PersistentVolume', 'StorageClass', 'Secret', 'Service']
          $kind,
  String  $resource            = $name,
  String  $namespace           = 'default',
  Stdlib::Unixpath
          $manifests_directory = $kubeinstall::manifests_directory,
  Optional[
    Variant[
      String,
      Array[String]
    ]
  ]       $unless              = undef,
) {
  if $namespace == 'default' {
    $apply_command = 'kubectl apply'
  }
  else {
    $apply_command = "kubectl apply --namespace ${namespace}"
  }

  $subpath = $kind ? {
    'PersistentVolume' => 'persistentvolumes',
    'StorageClass'     => 'storageclasses',
    'Secret'           => 'secrets',
    'Service'          => 'services',
  }

  $manifest = "${manifests_directory}/manifests/${subpath}/${resource}.yaml"

  exec { "${apply_command} -f ${manifest}":
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    environment => [
      'KUBECONFIG=/etc/kubernetes/admin.conf',
    ],
    refreshonly => true,
    onlyif      => "test -f ${manifest}",
    unless      => $unless,
  }
}
