# @summary Setup Kubernetes directory structure
#
# Setup Kubernetes directory structure
#
# @example
#   include kubeinstall::directory_structure
class kubeinstall::directory_structure (
  Stdlib::Unixpath $manifests_directory = $kubeinstall::manifests_directory,
) inherits kubeinstall::params {
  # https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
  file { '/root/.kube':
    ensure => directory,
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
  }

  file { [
      '/etc/kubernetes',
      '/etc/kubernetes/manifests',
      # https://kubernetes.io/docs/setup/best-practices/certificates/
      '/etc/kubernetes/pki',
      # https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/
      '/etc/cni', '/etc/cni/net.d',
      # https://github.com/cncf-tags/container-device-interface
      '/etc/cdi', '/var/run/cdi',
      $kubeinstall::params::cni_plugins_dir_path, $kubeinstall::params::cni_plugins_dir,
      $manifests_directory, "${manifests_directory}/manifests",
      # kubelet root directory and certificate directory
      '/var/lib/kubelet', '/var/lib/kubelet/pki',
    '/var/lib/kube-proxy'].unique: # lint:ignore:unquoted_resource_title
      ensure => directory,
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
  }

  file {
    default:
      ensure => directory,
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
      ;
    # RBAC roles binding objects directory
    "${manifests_directory}/manifests/clusterrolebindings": ;
    # RBAC roles objects directory
    "${manifests_directory}/manifests/clusterroles": ;
    # persistent volumes objects directory
    "${manifests_directory}/manifests/persistentvolumes": ;
    # directory of persistent volume claim objects
    "${manifests_directory}/manifests/persistentvolumeclaims": ;
    # secret objects directory
    "${manifests_directory}/manifests/secrets":
      mode => '0710',
      ;
    # services objects directory
    # https://kubernetes.io/docs/concepts/services-networking/service/
    "${manifests_directory}/manifests/services": ;
    # storage classes objects directory
    "${manifests_directory}/manifests/storageclasses": ;
  }
}
