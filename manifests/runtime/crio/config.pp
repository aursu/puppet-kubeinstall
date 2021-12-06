# @summary CRI-O configuration file setup
#
# CRI-O configuration file setup
#
# @param selinux
#   If true, SELinux will be used for pod separation on the host.
#
# @example
#   include kubeinstall::runtime::crio::config
class kubeinstall::runtime::crio::config (
  Optional[Boolean]
          $selinux         = $kubeinstall::cri_selinux,
  Stdlib::Unixpath
          $path            = $kubeinstall::crio_config_path,
  String  $config_template = $kubeinstall::crio_config_template,
)
{
  if $selinux =~ Boolean {
    $config_selinux = { 'selinux' => $selinux }
  }
  else {
    $config_selinux = {}
  }
  # https://github.com/cri-o/cri-o/blob/master/docs/crio.conf.5.md
  file { $path:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content =>  epp($config_template,
                    $config_selinux
                ),
  }
}
