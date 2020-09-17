### [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)

`Pods` are the smallest deployable units of computing that you can create and
manage in Kubernetes.

A `Pod` (as in a pod of whales or pea pod) is a group of one or more containers,
with shared storage/network resources, and a specification for how to run the
containers. A Pod's contents are always co-located and co-scheduled, and run in
a shared context. A Pod models an application-specific "logical host": it
contains one or more application containers which are relatively tightly
coupled. In non-cloud contexts, applications executed on the same physical or
virtual machine are analogous to cloud applications executed on the same
logical host.

As well as application containers, a Pod can contain
[init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
that run during Pod startup. You can also inject
[ephemeral containers](https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/)
for debugging if your cluster offers this.

#### Using Pods

Usually you don't need to create Pods directly, even singleton Pods. Instead,
create them using workload resources such as `Deployment` or `Job` . If your
Pods need to track state, consider the `StatefulSet` resource.

Each Pod is meant to run a single instance of a given application. If you want
to scale your application horizontally (to provide more overall resources by
running more instances), you should use multiple Pods, one for each instance.
In Kubernetes, this is typically referred to as `replication`. Replicated Pods
are usually created and managed as a group by a workload resource and its
controller .

#### Working with Pods

##### Pods and controllers

You can use workload resources to create and manage multiple Pods for you. A
controller for the resource handles replication and rollout and automatic
healing in case of Pod failure. For example, if a Node fails, a controller
notices that Pods on that Node have stopped working and creates a replacement
Pod. The scheduler places the replacement Pod onto a healthy Node.

Here are some examples of workload resources that manage one or more Pods:

* [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* StatefulSet
* [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

##### Pod templates

Controllers for workload resources create Pods from a pod template and manage
those Pods on your behalf.

PodTemplates are specifications for creating Pods, and are included in workload
resources such as Deployments,
[Jobs](https://kubernetes.io/docs/concepts/jobs/run-to-completion-finite-workloads/),
and DaemonSets.

Modifying the pod template or switching to a new pod template has no effect on
the Pods that already exist. Pods do not receive template updates directly.
Instead, a new Pod is created to match the revised pod template.
