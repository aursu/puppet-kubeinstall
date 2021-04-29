# @summary CRI-O container runtime installation
#
# CRI-O container runtime installation
# see https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o
#
# @example
#   include kubeinstall::runtime::crio
class kubeinstall::runtime::crio {
  contain kubeinstall::runtime::crio::install
  contain kubeinstall::runtime::crio::service

  Class['kubeinstall::runtime::crio::install']
    -> Class['kubeinstall::runtime::crio::service']
}
