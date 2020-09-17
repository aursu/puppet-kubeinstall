# @summary Helm client installation
#
# Helm client installation
#
# @example
#   include kubeinstall::install::helm
class kubeinstall::install::helm (
  String  $version   = $kubeinstall::helm_version,
  String  $archive   = "helm-${version}-linux-amd64.tar.gz",
  Stdlib::HTTPUrl
          $source    = "https://get.helm.sh/helm-${version}s-linux-amd64.tar.gz"
){
  archive { $archive:
    path            => "/${archive}",
    source          => $source,
    extract         => true,
    extract_command => 'tar xfz %s --strip-components=1 -C /usr/local/bin/ linux-amd64/helm',
    extract_path    => '/usr/local/bin',
    cleanup         => true,
    creates         => '/usr/local/bin/helm',
  }

  file { '/usr/local/bin/helm':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Archive[$archive],
  }
}
