# @summary Resource for exporting Kubernetes token discovery configuration to PuppetDB
#
# This resource facilitates the distribution of Kubernetes join credentials across cluster nodes
# by exporting them into PuppetDB. It defines both the `kubeadm join` command for worker nodes
# and `kubeadm join --control-plane` for control plane nodes.
#
# **Important:**  
# This resource should **not be imported directly**, as doing so will attempt to run both
# the worker and control plane join commands. This results in unpredictable behavior.
# Instead, import only one of the exported `Exec` resources:
#
# - `kubeadm-join` for joining a worker node
# - `kubeadm-join-control-plane` for joining a control plane node
#
# @param ca_cert_hash [Kubeinstall::CACertHash]
#   The hash of the root certificate authority (CA) used for discovery token validation.
#
# @param token [Kubeinstall::Token]
#   The bootstrap token used for joining the cluster. Defaults to the resource title.
#
# @param apiserver_address [Kubeinstall::Address]
#   The IP or hostname of the API server. Defaults to `$kubeinstall::apiserver_advertise_address`.
#
# @param apiserver_port [Integer]
#   The port on which the API server is listening. Defaults to `$kubeinstall::apiserver_bind_port`.
#
# @param cluster_name [String]
#   The name of the cluster. Used for tagging the exported resources.
#
# @param certificate_key [Optional[Kubeinstall::CertificateKey]]
#   Optional 32-byte key used to encrypt control plane certificates when uploading
#   them as a Kubernetes Secret. Required for joining control plane nodes using
#   `--control-plane`. See:
#
# @example Basic usage for exporting join credentials
#   kubeinstall::token_discovery { 'o9o8vw.fe02deotcm0dv8z5': }
#
# @see https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/
# @see https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
#
# @note
#   Always ensure that bootstrap tokens have limited lifetimes and permissions.
#   Use RBAC and network policies to minimize security exposure.
define kubeinstall::token_discovery (
  Kubeinstall::CACertHash $ca_cert_hash,
  Kubeinstall::Token $token = $name,
  Kubeinstall::Address $apiserver_address = $kubeinstall::apiserver_advertise_address,
  Integer $apiserver_port = $kubeinstall::apiserver_bind_port,
  String  $cluster_name = $kubeinstall::cluster_name,
  Optional[Kubeinstall::CertificateKey] $certificate_key = undef,
) {
  exec { 'kubeadm-join':
    command => "kubeadm join --token ${token} ${apiserver_address}:${apiserver_port} --discovery-token-ca-cert-hash ${ca_cert_hash}",
    path    => '/usr/bin:/bin:/sbin:/usr/sbin',
    creates => '/etc/kubernetes/kubelet.conf',
    tag     => $cluster_name,
  }

  if $certificate_key {
    exec { 'kubeadm-join-control-plane':
      command => "kubeadm join --token ${token} ${apiserver_address}:${apiserver_port} --discovery-token-ca-cert-hash ${ca_cert_hash} --control-plane --certificate-key ${certificate_key}", # lint:ignore:140chars
      path    => '/usr/bin:/bin:/sbin:/usr/sbin',
      creates => '/etc/kubernetes/kubelet.conf',
      tag     => [$cluster_name, 'joined_controller'],
    }
  }
}
