# @summary Exclude package kubernetes-cni from update process
#
# Exclude package kubernetes-cni from update process
#
# @example
#   include kubeinstall::yum::exclude
class kubeinstall::yum::exclude (
  Boolean $manage = $kubeinstall::manage_yum_excludes,
  Kubeinstall::Version $kubernetes_version = $kubeinstall::kubernetes_version,
) {
  if $manage and versioncmp($kubernetes_version, '1.25.0') < 0 {
    yum::config { 'exclude':
      # it produce some strange conflict
      ensure => 'kubernetes-cni',
    }
  }
}
