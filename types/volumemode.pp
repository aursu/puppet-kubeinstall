# Kubernetes supports two volumeModes of PersistentVolumes: Filesystem and Block.
#
# https://kubernetes.io/docs/concepts/storage/persistent-volumes/#volume-mode
# 
type Kubeinstall::VolumeMode = Enum['Filesystem', 'Block']
