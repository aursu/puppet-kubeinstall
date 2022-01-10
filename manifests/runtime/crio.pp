# @summary CRI-O container runtime installation
#
# CRI-O container runtime installation
# see https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o
#
# @example
#   include kubeinstall::runtime::crio
class kubeinstall::runtime::crio (
  # While using CRI-O - decomission Docker
  Boolean $docker_decomission = true,
)
{
  contain kubeinstall::runtime::crio::install
  contain kubeinstall::runtime::crio::config
  contain kubeinstall::runtime::crio::service

  if $docker_decomission {
    include dockerinstall::profile::decomission

    # stop kubelet if CRI-O package has been changed (installed/upgraded)
    # then perform Docker decomission (if required)
    # then install CRI-O runtime
    Class['dockerinstall::profile::decomission']
      -> Class['kubeinstall::runtime::crio::install']
  }

  Class['kubeinstall::runtime::crio::install']
    -> Class['kubeinstall::runtime::crio::config']
    ~> Class['kubeinstall::runtime::crio::service']
}
