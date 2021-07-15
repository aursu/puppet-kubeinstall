# @summary Create a StorageClass for local Volumes
#
# Create a StorageClass for local Volumes
#
# @example
#   include kubeinstall::resource::sc::local
class kubeinstall::resource::sc::local (
  String $class_name = 'local-storage',
)
{
  kubeinstall::resource::sc { $class_name:
    provisioner        => 'kubernetes.io/no-provisioner',
    volume_bindin_mode => 'WaitForFirstConsumer',
  }
}
