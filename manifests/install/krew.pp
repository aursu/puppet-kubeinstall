# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::install::krew
class kubeinstall::install::krew (
  String  $version    = $kubeinstall::krew_version,
  Boolean $manage_git = true,
)
{
  # git package could be controlled in different place of role/profile
  # therefore make it possible to disable it here
  if $manage_git {
    include kubeinstall::system::git
  }

  $archive   = 'krew.tar.gz'
  $source    = "https://github.com/kubernetes-sigs/krew/releases/download/v${version}/krew.tar.gz"

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

  if $::facts['kernel'] == 'Linux' and $::facts['os']['architecture'] == 'x86_64' {
    exec { '/usr/local/krew/krew-linux_amd64 install krew':
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
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
