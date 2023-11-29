# @summary install runc
#
# runc is a CLI tool for spawning and running containers on Linux according to the OCI
# specification.
#
# @example
#   include kubeinstall::runtime::containerd::runc
class kubeinstall::runtime::containerd::runc (
  Kubeinstall::Runc::Version $version = $kubeinstall::params::runc_version,
) inherits kubeinstall::params {
  # https://github.com/opencontainers/runc/releases/download/v1.1.9/runc.amd64
  if $version in ['installed', 'present', 'latest'] {
    $runc_version = $kubeinstall::params::runc_version
  }
  else {
    $runc_version = $version
  }

  file { ['/usr/local/runc', '/usr/local/runc/lib', '/usr/local/runc/sbin']:
    ensure => directory,
  }

  if $version == 'absent' {
    file { '/usr/local/sbin/runc':
      ensure  => absent,
    }
  }
  else {
    # All releases are signed by one of the keys listed in the runc.keyring file in the root of
    # https://github.com/opencontainers/runc repository.
    exec { 'install-runc.keyring':
      command => "curl -L https://raw.githubusercontent.com/opencontainers/runc/v${runc_version}/runc.keyring -O",
      creates => '/usr/local/runc/lib/runc.keyring',
      path    => '/bin:/usr/bin',
      cwd     => '/usr/local/runc/lib',
    }

    # root@localhost:~# gpg  --import runc.keyring 
    # gpg: /root/.gnupg/trustdb.gpg: trustdb created
    # gpg: key 9E18AA267DDB8DB4: public key "Aleksa Sarai <asarai@suse.com>" imported
    # gpg: key 34401015D1D2D386: public key "Aleksa Sarai <cyphar@cyphar.com>" imported
    # gpg: key 17DE5ECB75A1100E: public key "Kir Kolyshkin <kolyshkin@gmail.com>" imported
    # gpg: key 49524C6F9F638F1A: public key "Akihiro Suda <akihiro.suda.cz@hco.ntt.co.jp>" imported
    # gpg: Total number processed: 4
    # gpg:               imported: 4
    exec { 'import-runc.keyring':
      command => 'gpg --import runc.keyring',
      unless  => 'gpg -k 9E18AA267DDB8DB4',
      path    => '/bin:/usr/bin',
      cwd     => '/usr/local/runc/lib',
    }

    # Download the runc.<ARCH> binary from https://github.com/opencontainers/runc/releases, verify
    # its sha256sum, and install it as /usr/local/sbin/runc.
    $component = 'runc.amd64'
    $download_url = "https://github.com/opencontainers/runc/releases/download/v${runc_version}/${component}"

    $signature_file = "${component}.asc"
    $signature_download_url = "https://github.com/opencontainers/runc/releases/download/v${runc_version}/${signature_file}"

    $versioned = "${component}-${runc_version}"
    $signature_versioned = "${signature_file}-${runc_version}"

    exec { "install-${signature_file}":
      command => "curl -L ${signature_download_url} -o ${signature_versioned}",
      creates => "/usr/local/runc/lib/${signature_versioned}",
      path    => '/bin:/usr/bin',
      cwd     => '/usr/local/runc/lib',
    }

    exec { "install-${component}":
      command => "curl -L ${download_url} -o ${versioned}",
      creates => "/usr/local/runc/sbin/${versioned}",
      unless  => "gpg --verify /usr/local/runc/lib/${signature_versioned} ${versioned}",
      path    => '/bin:/usr/bin',
      cwd     => '/usr/local/runc/sbin',
      require => Exec["install-${signature_file}"],
    }

    file { '/usr/local/sbin/runc':
      ensure  => file,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source  => "file:///usr/local/runc/sbin/${versioned}",
      require => Exec["install-${component}"],
    }
  }
}
