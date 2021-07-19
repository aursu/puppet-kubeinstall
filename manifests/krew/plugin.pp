# @summary Install krew plugin
#
# Install krew plugin into /root/.krew/bin
#
# @example
#   kubeinstall::krew::plugin { 'namevar': }
define kubeinstall::krew::plugin (
  String $plugin = $name,
)
{
  exec { "kubectl krew info ${plugin}":
    path        => '/root/.krew/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    environment => [
      'KUBECONFIG=/etc/kubernetes/admin.conf',
    ],
    onlyif      => "kubectl krew info ${plugin}",
    unless      => "kubectl krew list | grep ${plugin}",
  }
}
