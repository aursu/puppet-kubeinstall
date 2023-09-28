# @summary Helm repository management
#
# Helm repository management
#
# @example
#   kubeinstall::helm::repo { 'namevar': }
define kubeinstall::helm::repo (
  Enum['present', 'absent'] $ensure = 'present',
  String  $repo_name = $name,
  Optional[Stdlib::HTTPUrl] $url = undef,
) {
  include kubeinstall::install::helm_binary

  if $ensure == 'present' {
    unless $url {
      fail('URL of chart repository must be provided')
    }

    exec { "helm repo add ${repo_name} ${url} --force-update":
      path   => '/usr/local/bin:/usr/bin:/bin',
      unless => "helm repo list -o json | grep -w ${repo_name} | grep ${url}",
    }
  }
  else {
    exec { "helm repo remove ${repo_name}":
      path   => '/usr/local/bin:/usr/bin:/bin',
      onlyif => "helm repo list -o json | grep -w ${repo_name}",
    }
  }
}
