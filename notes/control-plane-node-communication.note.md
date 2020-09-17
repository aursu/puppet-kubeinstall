### [Control Plane-Node Communication](https://kubernetes.io/docs/concepts/architecture/control-plane-node-communication/)

#### Node to Control Plane

#### Control Plane to node

1. apiserver to kubelet
2. apiserver to nodes, pods, and service

  * SSH tunnels
  * Konnectivity service: [Set up Konnectivity service](https://kubernetes.io/docs/tasks/extend-kubernetes/setup-konnectivity/)
