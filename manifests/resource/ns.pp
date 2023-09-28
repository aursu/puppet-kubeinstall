# @summary Create Kubernetes Namespace
#
# Create Kubernetes Namespace
# see https://kubernetes.io/docs/tasks/administer-cluster/namespaces/
#
# @example
#   kubeinstall::resource::ns { 'namevar': }
define kubeinstall::resource::ns (
  Kubeinstall::DNSName $namespace_name = $name,
) {
  unless $namespace_name =~ Kubeinstall::DNSSubdomain {
    fail('The name of a Namespace object must be a valid DNS subdomain name.')
  }

  exec { "kubectl create namespace ${namespace_name}":
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    environment => [
      'KUBECONFIG=/etc/kubernetes/admin.conf',
    ],
    unless      => "kubectl get namespace ${namespace_name}",
  }
}
