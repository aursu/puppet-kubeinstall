# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::kubectl::binary
class kubeinstall::kubectl::binary (
  Kubeinstall::VersionPrefix $kubernetes_version = $kubeinstall::kubernetes_version,
) {
  # it could be RPM package version
  $version_data = split($kubernetes_version, '[-]')
  $version = $version_data[0]

  $download_url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubectl"

  exec { 'install-kubectl-sha256':
    command => "curl -L ${download_url}.sha256 -o kubectl.sha256-${version}",
    creates => "/usr/local/bin/kubectl.sha256-${version}",
    path    => '/bin:/usr/bin',
    cwd     => '/usr/local/bin',
  }

  exec { 'install-kubectl':
    command => "curl -L ${download_url} -o kubectl-${version}",
    creates => "/usr/local/bin/kubectl-${version}",
    unless  => "echo \"$(cat kubectl.sha256-${version})  kubectl-${version}\" | sha256sum --check",
    path    => '/bin:/usr/bin',
    cwd     => '/usr/local/bin',
    require => Exec['install-kubectl-sha256'],
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
