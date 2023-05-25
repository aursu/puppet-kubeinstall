# @summary The StorageClass Kubernetes Resource
#
# A StorageClass provides a way for administrators to describe the "classes"
# of storage they offer.
# https://kubernetes.io/docs/concepts/configuration/secret/
#
# @example
#   kubeinstall::resource::sc { 'namevar': }
#
# @param allow_volume_expansion
#   PersistentVolumes can be configured to be expandable. This feature when set
#   to true, allows the users to resize the volume by editing the corresponding
#   PVC object.
#   see https://kubernetes.io/docs/concepts/storage/storage-classes/#allow-volume-expansion
#
# @param allowed_topologies
#   Restrict the node topologies where volumes can be dynamically provisioned.
#   Each volume plugin defines its own supported topology specifications. An
#   empty TopologySelectorTerm list means there is no topology restriction.
#   This field is only honored by servers that enable the VolumeScheduling feature.
#   see https://kubernetes.io/docs/concepts/storage/storage-classes/#allowed-topologies
#
# @param mount_options
#   Dynamically provisioned PersistentVolumes of this storage class are created
#   with these mountOptions, e.g. ["ro", "soft"]. Not validated - mount of the
#   PVs will simply fail if one is invalid.
#   see https://kubernetes.io/docs/concepts/storage/storage-classes/#mount-options
#
# @param parameters
#   Parameters holds the parameters for the provisioner that should create
#   volumes of this storage class.
#
# @param provisioner
#   Provisioner indicates the type of the provisioner.
#   see https://kubernetes.io/docs/concepts/storage/storage-classes/#provisioner
#
# @param reclaim_policy
#   Dynamically provisioned PersistentVolumes of this storage class are created
#   with this reclaimPolicy. Defaults to Delete.
#   see https://kubernetes.io/docs/concepts/storage/storage-classes/#reclaim-policy
#
# @param volume_bindin_mode
#   VolumeBindingMode indicates how PersistentVolumeClaims should be
#   provisioned and bound. When unset, VolumeBindingImmediate is used. This
#   field is only honored by servers that enable the VolumeScheduling feature
#   see https://kubernetes.io/docs/concepts/storage/storage-classes/#volume-binding-mode
#
define kubeinstall::resource::sc (
  String  $provisioner,
  Kubeinstall::DNSName
          $object_name            = $name,
  Kubeinstall::Metadata
          $metadata               = {},
  Boolean $allow_volume_expansion = false,
  Array[Kubeinstall::TopologySelectorTerm]
          $allowed_topologies     = [],
  Array[String]
          $mount_options          = [],
  Hash[String, String]
          $parameters             = {},
  Enum['Delete', 'Retain']
          $reclaim_policy         = 'Delete',
  Enum['WaitForFirstConsumer', 'Immediate']
          $volume_bindin_mode     = 'Immediate',
  Stdlib::Unixpath
          $manifests_directory = $kubeinstall::manifests_directory,
  Boolean $apply                  = false,
) {
  $object_header  = {
                      'apiVersion' => 'storage.k8s.io/v1',
                      'kind'       => 'StorageClass',
                    }

  $metadata_content = {
                        'metadata' => {
                          'name' => $object_name,
                        } +
                        $metadata,
                      }

  $allowed_topologies_content = $allowed_topologies[0] ? {
    Kubeinstall::TopologySelectorTerm => { 'allowedTopologies' => $allowed_topologies },
    default                           => {},
  }

  $mount_options_content = $mount_options[0] ? {
    String  => { 'mountOptions' => $mount_options },
    default => {},
  }

  if empty($parameters) {
    $parameters_content = {}
  }
  else {
    $parameters_content = { 'parameters' => $parameters }
  }

  $object_content = {
                      'allowVolumeExpansion' => $allow_volume_expansion,
                      'provisioner'          => $provisioner,
                      'reclaimPolicy'        => $reclaim_policy,
                      'volumeBindingMode'    => $volume_bindin_mode,
                    } +
                    $allowed_topologies_content +
                    $mount_options_content +
                    $parameters_content

  $object = to_yaml($object_header + $metadata_content + $object_content)

  file { $object_name:
    ensure  => file,
    path    => "${manifests_directory}/manifests/storageclasses/${object_name}.yaml",
    content => $object,
    mode    => '0600',
  }

  if $apply {
    kubeinstall::kubectl::apply { $object_name:
      kind      => 'StorageClass',
      subscribe => File[$object_name],
    }
  }
}
