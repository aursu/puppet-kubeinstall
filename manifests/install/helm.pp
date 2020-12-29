# @summary Helm client installation
#
# Helm client installation
#
# @example
#   include kubeinstall::install::helm
class kubeinstall::install::helm (
  String  $version           = $kubeinstall::helm_version,
  Stdlib::Unixpath
          $helm_install_path = '/usr/local/bin',
  Boolean $helm_client_only  = true,
)
{
  # https://forge.puppet.com/modules/puppetlabs/helm
  class { 'helm':
    version      => $version,
    install_path => $helm_install_path,
    client_only  => $helm_client_only,
  }
}
