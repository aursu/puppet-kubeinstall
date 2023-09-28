# @summary Set of compatibility fixes
#
# Set of compatibility fixes
#
# @param kubernetes_version
#   Kubernetes version 
#
# @example
#   include kubeinstall::install::compat
class kubeinstall::install::compat (
  Kubeinstall::VersionPrefix $kubernetes_version = $kubeinstall::kubernetes_version,
) {
  # kubelet drop-in file for systemd 1.27 fix
  # See https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/kubelet-integration/#the-kubelet-drop-in-file-for-systemd
  # kubelet[1840248]: E0605 16:33:59.912446 1840248 run.go:74] "command failed" err="failed to parse kubelet flag: unknown flag: --container-runtime"
  if versioncmp($kubernetes_version, '1.27.0') >= 0 {
    exec { 'kubelet-flag-container-runtime':
      command => 'sed -i -e s/--container-runtime=remote//g -e s/--container-runtime=docker//g /var/lib/kubelet/kubeadm-flags.env',
      onlyif  => [
        'test -f /var/lib/kubelet/kubeadm-flags.env',
        'grep -q -- --container-runtime= /var/lib/kubelet/kubeadm-flags.env',
      ],
      path    => '/usr/bin:/bin:/usr/sbin:/sbin',
    }
  }
}
