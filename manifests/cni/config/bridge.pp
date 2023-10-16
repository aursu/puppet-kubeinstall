# @summary A short summary of the purpose of this class
#
# A description of what this class does
# https://www.cni.dev/plugins/current/main/bridge/
# https://www.tigera.io/learn/guides/kubernetes-networking/kubernetes-cni/
#
# @example
#   include kubeinstall::cni::config::bridge
class kubeinstall::cni::config::bridge (
  Stdlib::IP::Address $ipv4_subnet = '10.85.0.0/16',
  Optional[Stdlib::IP::Address] $ipv6_subnet = undef,
) {
  $ipv6_subnet_ranges = $ipv6_subnet ? {
    Stdlib::IP::Address => [[{ 'subnet' => $ipv6_subnet }]],
    default => [],
  }

  $config_bridge = {
    'type'        => 'bridge',
    'bridge'      => 'cni0',
    'isGateway'   => true,
    'ipMasq'      => true,
    'promiscMode' => true,
    'ipam'        => {
      'type'   => 'host-local',
      'routes' => [
        { 'dst' => '0.0.0.0/0' },
        { 'dst' => '::/0' },
      ],
      'ranges' => [
        [{ 'subnet' => $ipv4_subnet }],
      ] + $ipv6_subnet_ranges,
    },
  }

  $object_header = {
    'cniVersion' => '1.0.0',
    'name' => 'bridge',
  }

  $object_content = { 'plugins' => [$config_bridge] }
  $object = $object_header + $object_content

  file { '/etc/cni/net.d/100-bridge.conflist':
    ensure  => file,
    content => to_json_pretty($object, true, { indent => '    ', space => ' ' }),
  }

  file { '/etc/cni/net.d/100-bridge.conf': ensure => absent }
}
