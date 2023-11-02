# @summary Install Argo CD
#
# Install Argo CD
# https://argoproj.github.io/argo-cd/getting_started/#1-install-argo-cd
#
# @example
#   include kubeinstall::install::argocd
class kubeinstall::install::argocd (
  String $version = $kubeinstall::argocd_version,
  String $namespace = 'argocd',
  Boolean $ha = false,
  Boolean $expose = false,
  Kubeinstall::DNSName $service_name = 'argocd-server-static',
  Kubeinstall::Port $service_port = 30200,
  Stdlib::Unixpath $manifests_directory = $kubeinstall::manifests_directory,
) {
  include kubeinstall::directory_structure

  # ArgoCD namespace
  kubeinstall::resource::ns { $namespace: }

  if $ha {
    # https://argoproj.github.io/argo-cd/operator-manual/high_availability/
    $remote_manifest = "https://raw.githubusercontent.com/argoproj/argo-cd/${version}/manifests/ha/install.yaml"
  }
  else {
    $remote_manifest = "https://raw.githubusercontent.com/argoproj/argo-cd/${version}/manifests/install.yaml"
  }

  exec { 'argocd-install':
    command     => "kubectl apply -n ${namespace} -f ${remote_manifest}",
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    environment => [
      'KUBECONFIG=/etc/kubernetes/admin.conf',
    ],
    unless      => "kubectl get -n argocd deployment.apps/argocd-server -o jsonpath='{.spec.template.spec.containers[?(@.name == \"argocd-server\")].image}' | grep ${version}",
    require     => Kubeinstall::Resource::Ns[$namespace],
  }

  if $expose {
    kubeinstall::resource::svc { $service_name:
      namespace => $namespace,
      metadata  => {
        labels => {
          'app.kubernetes.io/component' => 'server',
          'app.kubernetes.io/name'      => $service_name,
          'app.kubernetes.io/part-of'   => 'argocd',
        },
      },
      type      => 'NodePort',
      ports     => [
        {
          name       => 'https',
          port       => 443,
          protocol   => 'TCP',
          nodePort   => $service_port,
          targetPort => 8080
        },
      ],
      selector  => {
        'app.kubernetes.io/name' => 'argocd-server',
      },
      apply     => true,
      require   => Exec['argocd-install'],
    }
  }
}
