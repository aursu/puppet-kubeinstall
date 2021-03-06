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
  contain kubeinstall::runtime::crio::service

  if $docker_decomission {
    include dockerinstall::profile::decomission
    # include kubeinstall::kubeadm::reset_command

    # stop kubelet if CRI-O package has been changed (installed/upgraded)
    # then perform Docker decomission (if required)
    # then install CRI-O runtime
    Class['dockerinstall::profile::decomission']
      -> Class['kubeinstall::runtime::crio::install']

    # Class['dockerinstall::profile::decomission']
    #   ~> Class['kubeinstall::kubeadm::reset_command']
    #   -> Class['kubeinstall::runtime::crio::install']
  }

  Class['kubeinstall::runtime::crio::install']
    -> Class['kubeinstall::runtime::crio::service']
}
