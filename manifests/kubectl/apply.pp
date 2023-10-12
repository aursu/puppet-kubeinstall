# @summary Apply Kubernetes manifest
#
# Apply Kubernetes manifest
#
# @example
#   kubeinstall::kubectl::apply { 'namevar': }
define kubeinstall::kubectl::apply (
  Enum['PersistentVolume', 'StorageClass', 'Secret', 'Service', 'ClusterRole', 'ClusterRoleBinding'] $kind,
  String $resource = $name,
  String $namespace = 'default',
  Stdlib::Unixpath $manifests_directory = $kubeinstall::manifests_directory,
  Optional[
    Variant[
      String,
      Array[String]
    ]
  ] $unless = undef,
  Optional[Stdlib::Unixpath] $kubeconfig = '/etc/kubernetes/admin.conf',
) {
  if $namespace == 'default' {
    $apply_command = 'kubectl apply'
  }
  else {
    $apply_command = "kubectl apply --namespace ${namespace}"
  }

  $subpath = $kind ? {
    'ClusterRole'        => 'clusterroles',
    'ClusterRoleBinding' => 'clusterrolebindings',
    'PersistentVolume'   => 'persistentvolumes',
    'StorageClass'       => 'storageclasses',
    'Secret'             => 'secrets',
    'Service'            => 'services',
  }

  $manifest = "${manifests_directory}/manifests/${subpath}/${resource}.yaml"

  exec { "${apply_command} -f ${manifest}":
    path        => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    environment => [
      "KUBECONFIG=${kubeconfig}",
    ],
    refreshonly => true,
    onlyif      => "test -f ${manifest}",
    unless      => $unless,
  }
}
