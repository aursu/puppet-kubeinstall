# @summary Helm client installation
#
# Helm client installation
#
# @example
#   include kubeinstall::install::helm_binary
class kubeinstall::install::helm_binary (
  String  $version   = $kubeinstall::helm_version,
){
  $archive   = "helm-${version}-linux-amd64.tar.gz"
  $source    = "https://get.helm.sh/helm-v${version}-linux-amd64.tar.gz"

  archive { $archive:
    path            => "/tmp/${archive}",
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

  file { ['/root/.config', '/root/.config/helm']:
    ensure => directory,
  }
}
