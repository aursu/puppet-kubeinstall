# @summary kube-scheduler configuration setup
#
# kube-scheduler configuration setup
#
# @param topolvm_scheduler
#   Whether to manage TopoLVM scheduler setup
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

    # creationTimestamp has value null, which Puppet converts to "", which in turn causes error in Kubernetes
    $meta =  $_config['metadata'] - ['creationTimestamp']

    if $topolvm_scheduler {
      include kubeinstall::topolvm::scheduler

      # Configure kube-scheduler for existing clusters
      # https://github.com/topolvm/topolvm/tree/main/deploy#for-existing-clusters
      $topolvm_volumes = [
        {
          'hostPath' => {
            'path' => $kubeinstall::topolvm::scheduler::path,
            'type' => 'Directory',
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

      # remove existing to add defined here
      $_command = $_container['command'].filter |$arg| { $arg != $topolvm_arg }
      $_volumes = $_spec['volumes'].filter |$vol| { $vol['name'] != 'topolvm-config' }
      $_mounts = $_container['volumeMounts'].filter |$mnt| { $mnt['name'] != 'topolvm-config' }
    }
    else {
      $topolvm_volumes = []
      $topolvm_mounts = []
      $topolvm_command = []

      # keep as is
      $_command = $_container['command']
      $_volumes = $_spec['volumes']
      $_mounts = $_container['volumeMounts']
    }

    # only if TopoLVM scheduler is managed by Puppet
    if $topolvm_scheduler {
      $container = $_container + {
        'command'      => $_command + $topolvm_command,
        'volumeMounts' => $_mounts + $topolvm_mounts,
      }
      $spec = $_spec + {
        'containers' => [$container],
        'volumes'    => $_volumes + $topolvm_volumes,
      }
      $config = $_config + {
        'metadata' => $meta,
        'spec'     => $spec,
      }

      file { '/etc/kubernetes/manifests/kube-scheduler.yaml':
        ensure  => file,
        content => to_yaml($config),
      }
    }
  }
}
