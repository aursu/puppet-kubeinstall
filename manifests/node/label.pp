# @summary Setup label for a node.
#
# Setup label for node with specified value.
#
# @example
#   kubeinstall::node::label { 'env': value => 'prod' }
#
define kubeinstall::node::label (
  String $key = $name,
  Optional[String] $value = undef,
  Stdlib::Host $node_name = $kubeinstall::node_name,
  Stdlib::Unixpath $kubeconfig = '/etc/kubernetes/admin.conf',
) {
  if $value {
    exec { "kubectl label node ${node_name} ${key}=${value} --overwrite":
      path        => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
      environment => [
        "KUBECONFIG=${kubeconfig}",
      ],
      unless      => "kubectl get nodes --selector=${key}=${value},kubernetes.io/hostname=${node_name} | grep -w ${node_name}",
    }
  }
  else {
    exec { "kubectl label node ${node_name} ${key}- --overwrite":
      path        => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
      environment => [
        "KUBECONFIG=${kubeconfig}",
      ],
      onlyif      => "kubectl get nodes --selector=${key},kubernetes.io/hostname=${node_name} | grep -w ${node_name}",
    }
  }
}
