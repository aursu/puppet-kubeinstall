# @summary Install etcdctl (along with etcd and etcdutl) using puppet-archive
#
# Downloads and extracts the etcd release archive, then links the tools into /usr/local/bin
#
# @example
#   include kubeinstall::etcd::etcdctl
class kubeinstall::etcd::etcdctl (
  String $version = $kubeinstall::etcd_version,
) {
  $archive_name = "etcd-v${version}-linux-amd64.tar.gz"
  $archive_url  = "https://storage.googleapis.com/etcd/v${version}/${archive_name}"
  $install_dir  = "/usr/local/etcd-${version}"

  file { $install_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  archive { $archive_name:
    path          => "/tmp/${archive_name}",
    source        => $archive_url,
    extract       => true,
    extract_path  => $install_dir,
    cleanup       => true,
    creates       => "${install_dir}/etcdctl",
    extract_flags => '--strip-components=1 -xzf',
    require       => File[$install_dir],
  }

  file { '/usr/local/bin/etcdctl':
    ensure => link,
    target => "${install_dir}/etcdctl",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/usr/local/bin/etcdutl':
    ensure => link,
    target => "${install_dir}/etcdutl",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}
