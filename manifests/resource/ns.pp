# @summary Create Kubernetes Namespace
#
# Create Kubernetes Namespace
# see https://kubernetes.io/docs/tasks/administer-cluster/namespaces/
#
# @example
#   kubeinstall::resource::ns { 'namevar': }
define kubeinstall::resource::ns (
  Kubeinstall::DNSName $namespace_name = $name,
  Stdlib::Unixpath $kubeconfig = '/etc/kubernetes/admin.conf',
) {
  unless $namespace_name =~ Kubeinstall::DNSSubdomain {
    fail('The name of a Namespace object must be a valid DNS subdomain name.')
  }

  exec { "kubectl create namespace ${namespace_name}":
    path        => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    environment => [
      "KUBECONFIG=${kubeconfig}",
    ],
    unless      => "kubectl get namespace ${namespace_name}",
  }
}
