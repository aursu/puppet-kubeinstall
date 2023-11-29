# @summary Install krew plugin
#
# Install krew plugin into /root/.krew/bin
#
# @example
#   kubeinstall::krew::plugin { 'namevar': }
define kubeinstall::krew::plugin (
  String $plugin = $name,
  Stdlib::Unixpath $kubeconfig = '/etc/kubernetes/admin.conf',
) {
  exec { "kubectl krew install ${plugin}":
    path        => '/root/.krew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    environment => [
      "KUBECONFIG=${kubeconfig}",
    ],
    onlyif      => "kubectl krew info ${plugin}",
    unless      => "kubectl krew list | grep ${plugin}",
  }
}
