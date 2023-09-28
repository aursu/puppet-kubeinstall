# @summary Setup Kubernetes directory structure
#
# Setup Kubernetes directory structure
#
# @example
#   include kubeinstall::directory_structure
class kubeinstall::directory_structure (
  Stdlib::Unixpath $manifests_directory = $kubeinstall::manifests_directory,
) {
  # https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
  file { ['/root/.kube', '/var/lib/kubelet']:
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
      '/opt/cni', '/opt/cni/bin',
      $manifests_directory,
    "${manifests_directory}/manifests"].unique: # lint:ignore:unquoted_resource_title
      ensure => directory,
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
  }
}
