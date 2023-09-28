# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::install::node
class kubeinstall::install::node (
  Stdlib::Unixpath $manifests_directory = $kubeinstall::manifests_directory,
) {
  include kubeinstall::system
  contain kubeinstall::runtime

  contain kubeinstall::install
  contain kubeinstall::service
  include kubeinstall::kubectl::completion
  include kubeinstall::install::compat

  include kubeinstall::directory_structure

  Class['kubeinstall::install'] -> Class['kubeinstall::install::compat']
  Class['kubeinstall::install::compat'] ~> Class['kubeinstall::service']
  Class['kubeinstall::runtime'] -> Class['kubeinstall::service']
  Class['kubeinstall::system'] -> Class['kubeinstall::service']
  Class['kubeinstall::directory_structure'] -> Class['kubeinstall::kubectl::completion']
  Class['kubeinstall::install'] -> Class['kubeinstall::kubectl::completion']
}
