# @summary The Service Kubernetes Resource
#
# The Service Kubernetes Resource
#
# @param metadata
#   Standard object's metadata.
#   Available fields are annotations, labels, and namespace
#
# @example
#   kubeinstall::resource::svc { 'namevar': }
define kubeinstall::resource::svc (
  Kubeinstall::DNSName
          $object_name         = $name,
  String  $namespace           = 'default',
  Kubeinstall::Metadata
          $metadata            = {},
) {
  $object_header  = {
                      'apiVersion' => 'v1',
                      'kind'       => 'Service',
                    }

  if $namespace == 'default' {
    $namespace_metadata = {}
  }
  else {
    $namespace_metadata = {
      'namespace' => $namespace,
    }
  }

  $metadata_content = {
                        'metadata' => {
                          'name' => $object_name,
                        } +
                        $namespace_metadata +
                        $metadata,
                      }
}
