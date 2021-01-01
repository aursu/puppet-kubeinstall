# @summary Helm client installation
#
# Helm client installation
#
# @example
#   include kubeinstall::install::helm
class kubeinstall::install::helm (
  String  $version         = $kubeinstall::helm_version,
  Stdlib::HTTPUrl
          $archive_baseurl = 'https://get.helm.sh',
  Stdlib::Unixpath
          $install_path    = '/usr/local/bin',
  Boolean $client_only     = true,
)
{
  # https://forge.puppet.com/modules/puppetlabs/helm
  class { 'helm':
    version         => $version,
    archive_baseurl => $archive_baseurl,
    install_path    => $install_path,
    client_only     => $client_only,
    path            => [ $install_path ],
  }
}
