# The access modes are:
#
# ReadWriteOnce
#
# the volume can be mounted as read-write by a single node. ReadWriteOnce
# access mode still can allow multiple pods to access the volume when the pods
# are running on the same node. For single pod access, please see
# ReadWriteOncePod.
#
# ReadOnlyMany
#
# the volume can be mounted as read-only by many nodes.
#
# ReadWriteMany
#
# the volume can be mounted as read-write by many nodes.
#
# ReadWriteOncePod
#
# the volume can be mounted as read-write by a single Pod. Use ReadWriteOncePod access mode if you want to ensure that only one pod across the whole cluster can read that PVC or write to it.
#
# https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes
# 
type Kubeinstall::AccessMode = Enum['ReadWriteOnce', 'ReadOnlyMany', 'ReadWriteMany', 'ReadWriteOncePod']
