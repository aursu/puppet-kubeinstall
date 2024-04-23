# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
# https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims
#
# @param storage
#   Request specific quantity of storage resource
#
# @param object_name
#   The name of a PersistentVolumeClaim object (must be a valid DNS subdomain name.)
#
# @param metadata
#   Standard object's metadata.
#   Available fields are annotations, labels, and namespace
#
# @param namespace
#   Namespace of the PersistentVolumeClaim object. The namespace defines the space within which
#   each name must be unique. The `namespace` field from the `metadata` parameter takes precedence
#   over this `namespace` parameter.
#
# @param access_modes
#   Contains the desired access modes the volume should have
#   https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes
#
# @param data_source
#   can be used to specify either:
#   - An existing VolumeSnapshot object (snapshot.storage.k8s.io/VolumeSnapshot)
#   - An existing PVC (PersistentVolumeClaim) If the provisioner or an external controller can
#     support the specified data source, it will create a new volume based on the contents of the
#     specified data source.
#   When the `AnyVolumeDataSource` feature gate is enabled, `dataSource` contents will be copied to
#   `dataSourceRef`, and `dataSourceRef` contents will be copied to `dataSource` when
#   `dataSourceRef.namespace` is not specified. If the namespace is specified, then `dataSourceRef`
#   will not be copied to dataSource.
#
# @param data_source_ref
#   specifies the object from which to populate the volume with data, if a non-empty volume is
#   desired. This may be any object from a non-empty API group (non core object) or a
#   `PersistentVolumeClaim` object. When this field is specified, volume binding will only succeed
#   if the type of the specified object matches some installed volume populator or dynamic
#   provisioner. This field will replace the functionality of the `dataSource` field and as such if
#   both fields are non-empty, they must have the same value. For backwards compatibility, when
#   namespace isn't specified in `dataSourceRef`, both fields (`dataSource` and `dataSourceRef`)
#   will be set to the same value automatically if one of them is empty and the other is non-empty.
#   When namespace is specified in `dataSourceRef`, `dataSource` isn't set to the same value and
#   must be empty. There are three important differences between `dataSource` and `dataSourceRef`:
#   - While `dataSource` only allows two specific types of objects, `dataSourceRef` allows any
#     non-core object, as well as `PersistentVolumeClaim` objects.
#   - While `dataSource` ignores disallowed values (dropping them), `dataSourceRef` preserves all
#     values, and generates an error if a disallowed value is specified.
#   - While `dataSource` only allows local objects, `dataSourceRef` allows objects in any
#     namespaces.
#   (Beta) Using this field requires the `AnyVolumeDataSource` feature gate to be enabled.
#   (Alpha) Using the namespace field of `dataSourceRef` requires the
#   `CrossNamespaceVolumeDataSource` feature gate to be enabled.
#
# @param selector
#   selector is a label query over volumes to consider for binding.
#   See https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector
#
# @param storage_class
#   The name of the StorageClass required by the claim.
#   A claim can request a particular class by specifying the name of a StorageClass using the
#   attribute `storageClassName`. Only PVs of the requested class, ones with the same
#   `storageClassName` as the PVC, can be bound to the PVC.
#   PVCs don't necessarily have to request a class. A PVC with its `storageClassName` set equal
#   to "" is always interpreted to be requesting a PV with no class, so it can only be bound to PVs
#   with no class (no annotation or one set equal to ""). A PVC with no `storageClassName` is not
#   quite the same and is treated differently by the cluster, depending on whether the
#   `DefaultStorageClass` admission plugin is turned on.
#
# @param volume_mode
#   `volumeMode` defines what type of volume is required by the claim. Value of Filesystem is
#   implied when not included in claim spec.
#
# @parma volume_name
#   `volumeName` is the binding reference to the `PersistentVolume` backing this claim.
#
# @example
#   kubeinstall::resource::pvc { 'namevar': }
define kubeinstall::resource::pvc (
  Kubeinstall::Quantity $volume_storage,
  Kubeinstall::DNSName $object_name = $name,
  Kubeinstall::Metadata $metadata = {},
  String $namespace  = 'default',
  # https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes
  Array[Kubeinstall::AccessMode] $access_modes = ['ReadWriteOnce'],
  # https://kubernetes.io/docs/concepts/storage/persistent-volumes/#volume-mode
  Kubeinstall::VolumeMode $volume_mode = 'Filesystem',
  Stdlib::Unixpath $manifests_directory = $kubeinstall::manifests_directory,
  Boolean $apply = false,
  Optional[Kubeinstall::DataSource] $data_source = undef,
  Optional[Kubeinstall::DataSourceRef] $data_source_ref = undef,
  Array[Kubeinstall::LabelSelectorRequirement] $match_expressions = [],
  Hash[String, String] $match_labels = {},
  Optional[String] $storage_class = undef,
  Optional[String] $volume_name = undef,
) {
  if $data_source_ref {
    if $data_source_ref['apiGroup'] == 'core' and $data_source_ref['kind'] != 'PersistentVolumeClaim' {
      fail("Error: 'dataSourceRef' objects in the core API group must have the 'PersistentVolumeClaim' kind only.")
    }

    if $data_source_ref['namespace'] and $data_source {
      fail("Error: If 'namespace' is specified in 'dataSourceRef', 'dataSource' must be empty.")
    }
  }

  $object_kind = 'PersistentVolumeClaim'

  unless $object_name =~ Kubeinstall::DNSSubdomain {
    fail("The name of a ${object_kind} object must be a valid DNS subdomain name.")
  }

  $object_header  = {
    'apiVersion' => 'v1',
    'kind'       => $object_kind,
  }

  if $namespace == 'default' {
    $namespace_metadata = {}
  }
  else {
    $namespace_metadata = {
      'namespace' => $namespace,
    }
  }

  $object_metadata = {
    'metadata' => {
      'name' => $object_name,
    } +
    $namespace_metadata +
    $metadata,
  }

  $spec_pvc = {
    'accessModes' => $access_modes,
    'volumeMode'  => $volume_mode,
  }

  $spec_resources = {
    'resources' => {
      'requests' => {
        'storage' => $volume_storage,
      },
    },
  }

  $spec_data_source = $data_source ? {
    Undef   => {},
    default => { 'dataSource' => $data_source },
  }

  $spec_data_source_ref = $data_source_ref ? {
    Undef   => {},
    default => { 'dataSourceRef' => $data_source_ref },
  }

  if $match_expressions[0] {
    $selector_expressions = { 'matchExpressions' => $match_expressions }
  }
  else {
    $selector_expressions = {}
  }

  if $match_labels.empty {
    $selector_labels = {}
  }
  else {
    $selector_labels = { 'matchLabels' => $match_labels }
  }

  if $selector_labels.empty and $selector_expressions.empty {
    $spec_selector = {}
  }
  else {
    $spec_selector = { 'selector' => $selector_expressions + $selector_labels }
  }

  $spec_class = $storage_class ? {
    Undef   => {},
    default => { 'storageClassName' => $storage_class },
  }

  $spec_volume = $volume_name ? {
    Undef   => {},
    default => { 'volumeName' => $volume_name },
  }

  $object_spec = {
    'spec' => $spec_pvc +
    $spec_resources +
    $spec_data_source +
    $spec_data_source_ref +
    $spec_selector +
    $spec_class +
    $spec_volume,
  }

  $object = to_yaml($object_header + $object_metadata + $object_spec)

  file { $object_name:
    ensure  => file,
    path    => "${manifests_directory}/manifests/persistentvolumeclaims/${object_name}.yaml",
    content => $object,
    mode    => '0600',
  }

  if $apply {
    kubeinstall::kubectl::apply { $object_name:
      kind      => $object_kind,
      subscribe => File[$object_name],
    }
  }
}
