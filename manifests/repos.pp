# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include kubeinstall::repos
class kubeinstall::repos {
  if $facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'], '7') >= 0 {
    yumrepo { 'kubernetes':
      ensure        => 'present',
      baseurl       => 'https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64',
      descr         => 'Kubernetes',
      enabled       => '1',
      gpgcheck      => '1',
      gpgkey        => 'https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg',
      repo_gpgcheck => '1',
    }
  }
}
