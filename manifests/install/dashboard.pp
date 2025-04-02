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
  String $version = $kubeinstall::params::dashboard_version,
) inherits kubeinstall::params {
  if versioncmp($version, '7.0.0') >= 0 {
    kubeinstall::helm::repo { 'kubernetes-dashboard':
      url => 'https://kubernetes.github.io/dashboard/',
    }

    kubeinstall::helm::chart { 'kubernetes-dashboard/kubernetes-dashboard':
      chart_version    => $version,
      release_name     => 'kubernetes-dashboard',
      namespace        => 'kubernetes-dashboard',
      create_namespace => true,
    }
  }
  else {
    # https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
    # https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
    exec { 'dashboard-install':
      command     => "kubectl apply -f ${dashboard_configuration}",
      path        => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
      environment => [
        'KUBECONFIG=/etc/kubernetes/admin.conf',
      ],
      onlyif      => "kubectl get nodes ${node_name}",
      unless      => 'kubectl -n kubernetes-dashboard get service kubernetes-dashboard',
    }
  }
}
