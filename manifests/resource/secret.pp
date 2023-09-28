# @summary Kubernetes Secrets object
#
# Kubernetes Secrets let you store and manage sensitive information
# https://kubernetes.io/docs/concepts/configuration/secret/
#
# @example
#   kubeinstall::resource::secret { 'namevar': }
#
# @param metadata
#   Standard object's metadata.
#   Available fields are annotations, labels, and namespace
#
# @param data
#   Data contains the secret data. Each key must consist of alphanumeric
#   characters, '-', '_' or '.'. The serialized form of the secret data is a
#   base64 encoded string, representing the arbitrary (possibly non-string)
#   data value here
#
# @param raw_data
#   Same as parameter `data` but values should be in raw form and will be
#   serialized in there
#
# @param string_data
#   stringData allows specifying non-binary secret data in string form. It is
#   provided as a write-only convenience method. All keys and values are merged
#   into the data field on write, overwriting any existing values. It is never
#   output when reading from the API.
#
define kubeinstall::resource::secret (
  Kubeinstall::DNSName $object_name = $name,
  String $namespace  = 'default',
  Kubeinstall::Metadata $metadata = {},
  Enum[
    'Opaque',                              # arbitrary user-defined data
    'kubernetes.io/service-account-token', # service account token
    'kubernetes.io/dockercfg',             # serialized ~/.dockercfg file
    'kubernetes.io/dockerconfigjson',      # serialized ~/.docker/config.json file
    'kubernetes.io/basic-auth',            # credentials for basic authentication
    'kubernetes.io/ssh-auth',              # credentials for SSH authentication
    'kubernetes.io/tls',                   # data for a TLS client or server
    'bootstrap.kubernetes.io/token'        # bootstrap token data
  ]       $type                = 'Opaque',
  Hash[
    Kubeinstall::Name,
    Stdlib::Base64
  ] $data = {},
  Hash[Kubeinstall::Name, String] $raw_data = {},
  Hash[Kubeinstall::Name, String] $string_data = {},
  Stdlib::Unixpath $manifests_directory = $kubeinstall::manifests_directory,
  Boolean $apply = false,
) {
  unless $object_name =~ Kubeinstall::DNSSubdomain {
    fail('The name of a Secret object must be a valid DNS subdomain name.')
  }

  $data_base64 = Hash(
    $raw_data.map |$key, $value| {
      [$key, String(Binary($value, '%s'))]
    }
  )

  $object_header  = {
    'apiVersion' => 'v1',
    'kind'       => 'Secret',
  }

  $combined_data = $data_base64 + $data

  if empty($combined_data) {
    $data_content = {}
  }
  else {
    $data_content = { 'data' => $combined_data }
  }

  if empty($string_data) {
    $string_data_content = {}
  }
  else {
    $string_data_content = { 'stringData' => $string_data }
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

  $object_content = {
    'type' => $type,
  } +
  $data_content +
  $string_data_content

  $object = to_yaml($object_header + $metadata_content + $object_content)

  file { $object_name:
    ensure  => file,
    path    => "${manifests_directory}/manifests/secrets/${object_name}.yaml",
    content => $object,
    mode    => '0600',
  }

  if $apply {
    kubeinstall::kubectl::apply { $object_name:
      kind      => 'Secret',
      subscribe => File[$object_name],
    }
  }
}
