### [Controllers](https://kubernetes.io/docs/concepts/architecture/controller/)

#### Controller pattern

A controller tracks at least one Kubernetes resource type. These objects have a
`spec` field that represents the desired state. See
[Understanding Kubernetes Object](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/#kubernetes-objects)

##### Control via API server

The Job controller does not run any Pods or containers itself. Instead, the Job
controller tells the API server to create or remove Pods

##### Direct control

#### Desired versus current state

#### Design

#### Ways of running controllers

Kubernetes comes with a set of built-in controllers that run inside the
`kube-controller-manager`