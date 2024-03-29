# @summary TopoLVM scheduler setup
#
# Define TopoLVM scheduler setup
#
# @param path
#   TopoLVM scheduler path to store scheduler configuration file
#
# @param manage_path
#   Whether to manage TopoLVM scheduler path
#
# @param manage_config
#   Whether to manage TopoLVM scheduler configuration file
#
# @param config_file
#   <MODULE NAME>/<FILE> reference to TopoLVM configuration file or
#   absolut path to a file from anywhere on disk
#
# @param config_content
#   TopoLVM configuration file content. Will be in use if specified.
#
# @example
#   include kubeinstall::topolvm::scheduler
class kubeinstall::topolvm::scheduler (
  Boolean $manage_path   = true,
  Stdlib::Unixpath $path = $kubeinstall::params::topolvm_scheduler_path,
  Boolean $manage_config = true,
  String  $config_file   = $kubeinstall::globals::topolvm_scheduler_config,
  Optional[String] $config_content = undef,
) inherits kubeinstall::globals {
  if $manage_path {
    exec { "mkdir -p ${path}":
      path    => '/usr/bin:/bin',
      creates => $path,
      before  => File[$path],
    }

    file { $path:
      ensure  => directory,
      purge   => false,
      recurse => true,
    }
  }

  if $manage_config {
    if $config_content {
      $content = $config_content
    }
    else {
      $content = file($config_file)
    }

    file { "${path}/scheduler-config.yaml":
      ensure  => file,
      content => $content,
    }
  }
}
