# @summary Install Kubernetes dashboard
#
# Install Kubernetes dashboard
#
# @example
#   include kubeinstall::install::dashboard
class kubeinstall::install::dashboard (
  Variant[
    Stdlib::HTTPUrl,
    Stdlib::Unixpath
  ] $dashboard_configuration = $kubeinstall::dashboard_configuration,
  Stdlib::Fqdn $node_name = $kubeinstall::node_name,
) {
  # https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
  # https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
  exec { 'dashboard-install':
    command     => "kubectl apply -f ${dashboard_configuration}",
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    environment => [
      'KUBECONFIG=/etc/kubernetes/admin.conf',
    ],
    onlyif      => "kubectl get nodes ${node_name}",
    unless      => 'kubectl -n kubernetes-dashboard get service kubernetes-dashboard',
  }
}
