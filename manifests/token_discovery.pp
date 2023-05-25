# @summary Token discovery resource
#
# Resource to export into PuppetDB for distributing
# k8s join credentials among cluster nodes
#
# @example
#   kubeinstall::token_discovery { 'o9o8vw.fe02deotcm0dv8z5': }
define kubeinstall::token_discovery (
  Kubeinstall::CACertHash $ca_cert_hash,
  Kubeinstall::Token $token = $name,
  Kubeinstall::Address $apiserver_address = $kubeinstall::apiserver_advertise_address,
  Integer $apiserver_port = $kubeinstall::apiserver_bind_port,
  String  $cluster_name = $kubeinstall::cluster_name,
) {
  exec { 'kubeadm-join':
    command => "kubeadm join --token ${token} ${apiserver_address}:${apiserver_port} --discovery-token-ca-cert-hash ${ca_cert_hash}",
    path    => '/usr/bin:/bin:/sbin:/usr/sbin',
    creates => '/etc/kubernetes/kubelet.conf',
    tag     => $cluster_name,
  }
}
