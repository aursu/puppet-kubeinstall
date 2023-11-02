# @summary Installing calicoctl as a binary on a single host
#
# Installing calicoctl as a binary on a single host
# https://docs.projectcalico.org/getting-started/clis/calicoctl/install#installing-calicoctl-as-a-binary-on-a-single-host
#
# @example
#   include kubeinstall::calico::calicoctl
class kubeinstall::calico::calicoctl (
  String $version = $kubeinstall::calico_version,
) {
  $download_url = "https://github.com/projectcalico/calico/releases/download/v${version}/calicoctl-linux-amd64"

  exec { 'install-calicoctl':
    command => "curl -L ${download_url} -o calicoctl-linux-amd64-v${version}",
    creates => "/usr/local/bin/calicoctl-linux-amd64-v${version}",
    path    => '/bin:/usr/bin',
    cwd     => '/usr/local/bin',
  }

  file { '/usr/local/bin/calicoctl':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    source  => "file:///usr/local/bin/calicoctl-linux-amd64-v${version}",
    require => Exec['install-calicoctl'],
  }

  # https://godoc.org/github.com/projectcalico/libcalico-go/lib/apiconfig#CalicoAPIConfig
  $calicoctl_config = {
    'apiVersion' => 'projectcalico.org/v3',
    'kind'       => 'CalicoAPIConfig',
    'metadata' => {},
    'spec' => {
      'datastoreType' => 'kubernetes',
      'kubeconfig'    => '/etc/kubernetes/admin.conf',
    },
  }

  file { '/etc/calico/calicoctl.cfg':
    ensure  => file,
    content => to_yaml($calicoctl_config),
    mode    => '0600',
  }
}
