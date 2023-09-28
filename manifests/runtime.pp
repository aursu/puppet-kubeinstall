# @summary Kubernetes CRI setup
#
# Kubernetes CRI setup
#
# @example
#   include kubeinstall::runtime
class kubeinstall::runtime (
  Kubeinstall::Runtime $container_runtime  = $kubeinstall::container_runtime,
  # While using CRI-O - decomission Docker
  Boolean $docker_decomission = true,
) {
  case $container_runtime {
    'docker': {
      contain kubeinstall::runtime::docker
    }
    default: {
      class { 'kubeinstall::runtime::crio':
        docker_decomission => $docker_decomission,
      }
      contain kubeinstall::runtime::crio
    }
  }
}
