# @summary ArgoCD CLI installation
#
# ArgoCD CLI installation
#
# @example
#   include kubeinstall::install::argocd::cli
class kubeinstall::install::argocd::cli (
  String $version = $kubeinstall::argocd_version,
) {
  $source = "https://github.com/argoproj/argo-cd/releases/download/${version}/argocd-linux-amd64"

  file { '/var/lib/argocd':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }

  if $facts['kernel'] == 'Linux' and $facts['os']['architecture'] in ['x86_64', 'amd64'] {
    exec { 'argocd-cli-install':
      command  => "curl -sSL ${source} -o argocd-${version}",
      path     => '/usr/bin:/bin:/usr/sbin:/sbin',
      cwd      => '/var/lib/argocd',
      creates  => "/var/lib/argocd/argocd-${version}",
      requires => File['/var/lib/argocd'],
    }

    file { '/usr/local/bin/argocd':
      ensure   => file,
      owner    => 'root',
      group    => 'root',
      mode     => '0750',
      source   => "file:///var/lib/argocd/argocd-${version}",
      requires => Exec['argocd-cli-install'],
    }
  }
}
