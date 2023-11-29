# @summary Setup label for a node.
#
# Setup label for node with specified value.
#
# @example
#   kubeinstall::node::label { 'env': value => 'prod' }
#
define kubeinstall::node::label (
  String $value,
  String $key = $name,
  Stdlib::Host $node_name = $kubeinstall::node_name,
  Stdlib::Unixpath $kubeconfig = '/etc/kubernetes/admin.conf',
) {
  # kubectl label node kube-04.crylan.com env=test
  exec { "kubectl label node ${node_name} ${key}=${value} --overwrite":
    path        => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    environment => [
      "KUBECONFIG=${kubeconfig}",
    ],
    unless      => "kubectl get nodes --selector=${key}=${value},kubernetes.io/hostname=${node_name} | grep -w ${node_name}",
  }
  # kubectl get nodes -o jsonpath='{.metadata.labels.env}' kube-01.crylan.com
}
