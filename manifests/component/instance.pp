# @summary Install Kubernetes binary instance
#
# A description of what this defined type does
#
# @example
#   kubeinstall::component::instance { 'namevar': }
define kubeinstall::component::instance (
  Enum['kube-apiserver', 'kubectl', 'kube-controller-manager', 'kube-scheduler', 'kube-proxy', 'kubelet']
  $component = $name,
  Kubeinstall::VersionPrefix $kubernetes_version = $kubeinstall::kubernetes_version,
) {
  # it could be RPM package version
  $version_data = split($kubernetes_version, '[-]')
  $version = $version_data[0]

  $download_url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/${component}"

  $sha256_file = "${component}.sha256"
  $sha256_download_url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/${sha256_file}"

  $versioned = "${component}-${version}"
  $sha256_versioned = "${sha256_file}-${version}"

  exec { "install-${sha256_file}":
    command => "curl -L ${sha256_download_url} -o ${sha256_versioned}",
    creates => "/usr/local/bin/${sha256_versioned}",
    path    => '/bin:/usr/bin',
    cwd     => '/usr/local/bin',
  }

  exec { "install-${component}":
    command => "curl -L ${download_url} -o ${versioned}",
    creates => "/usr/local/bin/${versioned}",
    unless  => "echo \"$(cat ${sha256_versioned}) ${versioned}\" | sha256sum --check",
    path    => '/bin:/usr/bin',
    cwd     => '/usr/local/bin',
    require => Exec["install-${sha256_file}"],
  }

  file { "/usr/local/bin/${component}":
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => "file:///usr/local/bin/${versioned}",
    require => Exec["install-${component}"],
  }
}
