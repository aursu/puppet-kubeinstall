# @summary kube-scheduler configuration setup
#
# kube-scheduler configuration setup
#
# @param topolvm_scheduler
#   Whether to manage TopoLVM scheduler setup
#
# @param topolvm_config_map
#   Name of the ConfigMap object inside `kube-system` namespace where
#   sub-path `scheduler-config.yaml` contains TopoLVM scheduler config
#
# @example
#   include kubeinstall::install::kube_scheduler
class kubeinstall::install::kube_scheduler (
  Boolean $topolvm_scheduler = $kubeinstall::topolvm_scheduler,
) {
  $topolvm_arg = '--config=/var/lib/scheduler/scheduler-config.yaml'

  if $facts['kube_scheduler'] and $facts['kube_scheduler']['kind'] == 'Pod' {
    $_config = $facts['kube_scheduler']
    $_spec = $_config['spec']
    $_container = $_spec['containers'][0]
    $_command = $_container['command']

    if $topolvm_scheduler {
      include kubeinstall::topolvm::scheduler

      $filter_topolvm_command = $_command.filter |$arg| { $arg == $topolvm_arg }

      if $filter_topolvm_command[0] {
        $topolvm_volumes = []
        $topolvm_mounts = []
        $topolvm_command = []
      }
      else {
        # Configure kube-scheduler for existing clusters
        # https://github.com/topolvm/topolvm/tree/main/deploy#for-existing-clusters
        $topolvm_volumes = [
          {
            'hostPath' => {
              'path' => $kubeinstall::topolvm::scheduler::path,
              'type' => 'FileOrCreate',
            },
            'name' => 'topolvm-config',
          },
        ]
        $topolvm_mounts = [
          {
            'mountPath' => '/var/lib/scheduler',
            'name' => 'topolvm-config',
            'readOnly' => true,
          },
        ]
        $topolvm_command = [$topolvm_arg]
      }
    }
    else {
      $topolvm_volumes = []
      $topolvm_mounts = []
      $topolvm_command = []
    }

    # only if TopoLVM scheduler is managed by Puppet
    if $topolvm_scheduler {
      $container = $_container + {
        'command'      => $_command + $topolvm_command,
        'volumeMounts' => $_container['volumeMounts'] + $topolvm_mounts,
      }
      $spec = $_spec + {
        'containers' => [$container],
        'volumes'    => $_spec['volumes'] + $topolvm_volumes,
      }
      $config = $_config + {
        'spec' => $spec,
      }

      file { '/etc/kubernetes/manifests/kube-scheduler.yaml':
        ensure  => file,
        content => to_yaml($config),
      }
    }
  }
}
