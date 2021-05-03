# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::install::node
class kubeinstall::install::node (
  Stdlib::Unixpath
          $manifests_directory = $kubeinstall::manifests_directory,
)
{
  include kubeinstall::system
  include kubeinstall::runtime

  contain kubeinstall::service

  file { '/root/.kube':
    ensure => directory,
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
  }

  file { [
    '/etc/kubernetes',
    '/etc/kubernetes/manifests',
    $manifests_directory,
    "${manifests_directory}/manifests"].unique: # lint:ignore:unquoted_resource_title
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  Class['kubeinstall::runtime'] -> Class['kubeinstall::service']
  Class['kubeinstall::system'] -> Class['kubeinstall::service']
}
