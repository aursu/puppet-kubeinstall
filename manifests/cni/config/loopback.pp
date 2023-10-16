# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::cni::config::loopback
class kubeinstall::cni::config::loopback {
  $config_loopback = {
    'type' => 'loopback',
  }

  $object_header = {
    'cniVersion' => '1.0.0',
    'name' => 'loopback',
  }

  $object_content = { 'plugins' => [$config_loopback] }

  $object = to_json($object_header + $object_content)

  file { '/etc/cni/net.d/200-loopback.conf':
    ensure  => file,
    content => $object,
  }
}
