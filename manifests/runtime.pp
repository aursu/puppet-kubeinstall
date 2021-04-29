# @summary Kubernetes CRI setup
#
# Kubernetes CRI setup
#
# @example
#   include kubeinstall::runtime
class kubeinstall::runtime (
  Kubeinstall::Runtime
          $container_runtime  = $kubeinstall::container_runtime,
  # While using CRI-O - decomission Docker
  Boolean $docker_decomission = true,
)
{
  case $container_runtime {
    'cri-o': {
      include kubeinstall::runtime::crio

      if $docker_decomission {
        include kubeinstall::service::stop
        include dockerinstall::profile::decomission

        # stop kubelet if CRI-O package has been changed (installed/upgraded)
        # then perform Docker decomission (if required)
        # then install CRI-O runtime
        Class['kubeinstall::runtime::crio::install']
          ~> Class['kubeinstall::service::stop']
          -> Class['dockerinstall::profile::decomission']
          -> Class['kubeinstall::runtime::crio::service']
      }
    }
    default: {
      include kubeinstall::runtime::docker
    }
  }
}
