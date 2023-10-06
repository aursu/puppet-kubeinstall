# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::kubectl::binary
class kubeinstall::kubectl::binary (
  Kubeinstall::VersionPrefix $version = $kubeinstall::kubernetes_version,
) {
  $download_url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubectl"

  exec { 'install-kubectl':
    command => "curl -L ${download_url} -o kubectl-${version}",
    creates => "/usr/local/bin/kubectl-${version}",
    path    => '/bin:/usr/bin',
    cwd     => '/usr/local/bin',
  }

  file { '/usr/local/bin/kubectl':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => "file:///usr/local/bin/kubectl-${version}",
    require => Exec['install-kubectl'],
  }
}
