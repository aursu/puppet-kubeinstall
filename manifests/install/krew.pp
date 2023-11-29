# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::install::krew
class kubeinstall::install::krew (
  String $version = $kubeinstall::krew_version,
) {
  include kubeinstall::system::git

  if versioncmp($version, '0.4.2') >= 0 {
    $archive   = 'krew-linux_amd64.tar.gz'
  }
  else {
    $archive   = 'krew.tar.gz'
  }
  $source    = "https://github.com/kubernetes-sigs/krew/releases/download/v${version}/${archive}"

  file { '/usr/local/krew':
    ensure => directory,
  }

  archive { $archive:
    path         => "/tmp/${archive}",
    source       => $source,
    extract      => true,
    extract_path => '/usr/local/krew',
    cleanup      => true,
    creates      => '/usr/local/krew/krew-linux_amd64',
    require      => File['/usr/local/krew'],
  }

  if $::facts['kernel'] == 'Linux' and $::facts['os']['architecture'] in ['x86_64', 'amd64'] {
    exec { '/usr/local/krew/krew-linux_amd64 install krew':
      path        => '/root/.krew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
      environment => [
        'KUBECONFIG=/etc/kubernetes/admin.conf',
      ],
      onlyif      => 'test -x /usr/local/krew/krew-linux_amd64',
      unless      => 'kubectl krew version',
      require     => Archive[$archive],
    }

    file { '/etc/profile.d/krew.sh':
      ensure => file,
      source => 'puppet:///modules/kubeinstall/krew/profile.d.sh',
    }
  }
}
