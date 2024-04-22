# @summary Create a PersistentVolume object
#
# Create a PersistentVolume object
# https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#persistentvolume-v1-core
# https://kubernetes.io/docs/reference/kubernetes-api/config-and-storage-resources/persistent-volume-v1/
#
# @example
#   kubeinstall::resource::pv { 'namevar': }
#
# @param local_path
#   The full path to the volume on the node. It can be either a directory or
#   block device (disk, partition, ...)
#
# @param match_expressions
#   A list of node selector requirements by node's labels
#   correspond to nodeAffinity.required.nodeSelectorTerms.matchExpressions
#   see https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#nodeselectorterm-v1-core
#
# @param match_fields
#   A list of node selector requirements by node's fields
#   correspond to nodeAffinity.required.nodeSelectorTerms.matchFields
#
define kubeinstall::resource::pv (
  Kubeinstall::Quantity $volume_storage,
  Kubeinstall::DNSName $volume_name = $name,
  Kubeinstall::Metadata $metadata = {},
  # https://kubernetes.io/docs/concepts/storage/persistent-volumes/#volume-mode
  Kubeinstall::VolumeMode $volume_mode = 'Filesystem',
  # https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes
  Array[Kubeinstall::AccessMode] $access_modes = ['ReadWriteOnce'],
  # https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming
  Enum['Delete', 'Retain', 'Recycle'] $reclaim_policy = 'Delete',
  Kubeinstall::NodeSelectorTerms $match_expressions = [],
  Kubeinstall::NodeSelectorTerms $match_fields = [],
  Stdlib::Unixpath $manifests_directory = $kubeinstall::manifests_directory,
  Boolean $apply = false,
  Optional[String] $storage_class_name = undef,
  Optional[Stdlib::Unixpath] $local_path = undef,
) {
  unless $volume_name =~ Kubeinstall::DNSSubdomain {
    fail('The name of a PersistentVolume object must be a valid DNS subdomain name.')
  }

  $pv_header  = {
    'apiVersion' => 'v1',
    'kind' => 'PersistentVolume',
  }

  $pv_metadata = {
    'metadata' => {
      'name' => $volume_name,
    } +
    $metadata,
  }

  $spec_pv = {
    'capacity'    => {
      'storage' => $volume_storage,
    },
    'volumeMode'                    => $volume_mode,
    'accessModes'                   => $access_modes,
    'persistentVolumeReclaimPolicy' => $reclaim_policy,
  }

  $spec_storage_class = $storage_class_name ? {
    String  => { 'storageClassName' => $storage_class_name },
    default => {}
  }

  # local volume source
  # https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#localvolumesource-v1-core
  $spec_local = $local_path ? {
    String  => { 'local' => { 'path' => $local_path } },
    default => {}
  }

  if $match_expressions[0] or $match_fields[0] {
    $node_selector_match_expressions = $match_expressions[0] ? {
      Hash    => [{ 'matchExpressions' => $match_expressions }],
      default => [],
    }

    $node_selector_match_fields = $match_fields[0] ? {
      Hash    => [{ 'matchFields' => $match_fields }],
      default => [],
    }

    $spec_affinity = {
      'nodeAffinity' => {
        'required' => {
          'nodeSelectorTerms' => $node_selector_match_expressions + $node_selector_match_fields,
        },
      },
    }
  }
  else {
    $spec_affinity = {}
  }

  $pv_spec = {
    'spec' => $spec_pv +
    $spec_storage_class +
    $spec_local +
    $spec_affinity,
  }

  $pv_object = to_yaml($pv_header + $pv_metadata + $pv_spec)

  file { $volume_name:
    ensure  => file,
    path    => "${manifests_directory}/manifests/persistentvolumes/${volume_name}.yaml",
    content => $pv_object,
    mode    => '0600',
  }

  if $apply {
    kubeinstall::kubectl::apply { $volume_name:
      kind      => 'PersistentVolume',
      subscribe => File[$volume_name],
    }
  }
}
