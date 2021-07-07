# @summary CRI-O repository setup
#
# CRI-O repository setup
#
# @example
#   include kubeinstall::repos::crio
class kubeinstall::repos::crio (
  Kubeinstall::Release
          $kuberel = $kubeinstall::kubernetes_release,
) inherits kubeinstall::params
{
  $osname = $facts['os']['name']
  $osmaj  = $facts['os']['release']['major']
  $centos_stream = $kubeinstall::params::centos_stream

  if $centos_stream {
    $os = "${osname}_${osmaj}_Stream"
  }
  else {
    $os = "${osname}_${osmaj}"
  }

  if $osname == 'CentOS' {
    yumrepo { 'devel_kubic_libcontainers_stable':
      ensure   => 'present',
      baseurl  => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${os}/",
      descr    => "Stable Releases of Upstream github.com/containers packages (${os})",
      enabled  => '1',
      gpgcheck => '1',
      gpgkey   => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/${os}/repodata/repomd.xml.key",
    }

    yumrepo { "devel_kubic_libcontainers_stable_cri-o_${kuberel}":
      ensure   => 'present',
      baseurl  => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${kuberel}/${os}/",
      descr    => "devel:kubic:libcontainers:stable:cri-o:${kuberel} (${os})",
      enabled  => '1',
      gpgcheck => '1',
      gpgkey   => "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${kuberel}/${os}/repodata/repomd.xml.key",
    }
  }
}
