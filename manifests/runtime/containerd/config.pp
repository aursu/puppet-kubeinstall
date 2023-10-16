# @summary containerd configuation
#
# containerd configuation and directory stucture
#
# @example
#   include kubeinstall::runtime::containerd::config
class kubeinstall::runtime::containerd::config (
  Boolean $set_content = false,
  String $content = file('kubeinstall/containerd/config.toml'),
) {
  file { [
      '/var/lib/containerd',
      '/run/containerd',
      '/etc/containerd',
      # https://github.com/containerd/containerd/blob/main/docs/NRI.md
      '/etc/nri', '/etc/nri/conf.d',
      '/opt/nri', '/opt/nri/plugins',
    '/var/run/nri']:
      ensure => directory,
  }

  if $set_content {
    file { '/etc/containerd/config.toml':
      ensure  => file,
      content => $content,
      require => File['/etc/containerd'],
    }
  }
  else {
    # set default content for config.toml
    exec { 'containerd config default':
      command => 'containerd config default > /etc/containerd/config.toml',
      creates => '/etc/containerd/config.toml',
      path    => '/usr/local/bin:/usr/bin:/bin',
      require => File['/etc/containerd'],
    }
  }
}
