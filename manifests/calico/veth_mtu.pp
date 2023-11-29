# @summary Configure Calico MTU
#
# Configure Calico MTU
# see # https://docs.projectcalico.org/networking/mtu#determine-mtu-size
#
# @example
#   include kubeinstall::calico::veth_mtu
class kubeinstall::calico::veth_mtu (
  Integer $mtu = $kubeinstall::calico_mtu,
  Stdlib::Unixpath $kubeconfig = '/etc/kubernetes/admin.conf',
) {
  unless $mtu == $facts['kubectl_calico_veth_mtu'] {
    $veth_mtu = {
      'data' => {
        'veth_mtu' => "${mtu}", # lint:ignore:only_variable_string
      },
    }
    $mtu_patch = to_json($veth_mtu)

    exec {
      default:
        path        => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
        environment => [
          "KUBECONFIG=${kubeconfig}",
        ],
        ;
      'patch-configmap-calico-config':
        command => "kubectl -n kube-system patch configmap/calico-config --type merge -p '${mtu_patch}'",
        onlyif  => 'kubectl -n kube-system get configmap/calico-config',
        notify  => Exec['restart-daemonset-calico-node'],
        ;
      'restart-daemonset-calico-node':
        command     => 'kubectl -n kube-system rollout restart daemonset calico-node',
        onlyif      => 'kubectl -n kube-system get daemonset calico-node',
        refreshonly => true,
        ;
    }
  }
}
