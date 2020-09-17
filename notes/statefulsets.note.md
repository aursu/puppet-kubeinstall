### [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

```
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx # has to match .spec.template.metadata.labels
  serviceName: "nginx"
  replicas: 3 # by default is 1
  template:
    metadata:
      labels:
        app: nginx # has to match .spec.selector.matchLabels
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "my-storage-class"
      resources:
        requests:
          storage: 1Gi
```

StatefulSet is the workload API object used to manage stateful applications.

Manages the deployment and scaling of a set of Pods, and provides guarantees
about the ordering and uniqueness of these Pods.

Like a Deployment, a StatefulSet manages Pods that are based on an identical
container spec. Unlike a Deployment, a StatefulSet maintains a sticky identity
for each of their Pods. These pods are created from the same spec, but are not
interchangeable: each has a persistent identifier that it maintains across any
rescheduling.

If you want to use storage volumes to provide persistence for your workload, you
can use a StatefulSet as part of the solution. Although individual Pods in a
StatefulSet are susceptible to failure, the persistent Pod identifiers make it
easier to match existing volumes to the new Pods that replace any that have
failed.

#### Using StatefulSets

StatefulSets are valuable for applications that require one or more of the
following.

* Stable, unique network identifiers.
* Stable, persistent storage.
* Ordered, graceful deployment and scaling.
* Ordered, automated rolling updates.

In the above, stable is synonymous with persistence across Pod (re)scheduling.
If an application doesn't require any stable identifiers or ordered deployment,
deletion, or scaling, you should deploy your application using a workload
object that provides a set of stateless replicas. `Deployment` or `ReplicaSet`
may be better suited to your stateless needs.

#### Limitations

* The storage for a given Pod must either be provisioned by a
[PersistentVolume Provisioner](https://github.com/kubernetes/examples/tree/master/staging/persistent-volume-provisioning/README.md)
based on the requested `storage class`, or pre-provisioned by an admin.

* Deleting and/or scaling a StatefulSet down will not delete the volumes
associated with the StatefulSet. This is done to ensure data safety, which is
generally more valuable than an automatic purge of all related StatefulSet
resources.

* StatefulSets currently require a
[Headless Service](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services)
to be responsible for the network identity of the Pods. You are responsible for
creating this Service.

* StatefulSets do not provide any guarantees on the termination of pods when a
StatefulSet is deleted. To achieve ordered and graceful termination of the pods
in the StatefulSet, it is possible to scale the StatefulSet down to 0 prior to
deletion.

* When using Rolling Updates with the default Pod Management Policy
(OrderedReady), it's possible to get into a broken state that requires manual
intervention to repair.

#### Pod Identity

StatefulSet Pods have a unique identity that is comprised of an ordinal, a
stable network identity, and stable storage. The identity sticks to the Pod,
regardless of which node it's (re)scheduled on.

##### Ordinal Index

For a StatefulSet with N replicas, each Pod in the StatefulSet will be assigned
an integer ordinal, from 0 up through N-1, that is unique over the Set.

#### Stable Network ID

Each Pod in a StatefulSet derives its hostname from the name of the StatefulSet
and the ordinal of the Pod. The pattern for the constructed hostname is
`$(statefulset name)-$(ordinal)`. The example above will create three Pods
named `web-0,web-1,web-2`. A StatefulSet can use a Headless Service to control
the domain of its Pods. The domain managed by this Service takes the form:
`$(service name).$(namespace).svc.cluster.local`, where "cluster.local" is the
cluster domain. As each Pod is created, it gets a matching DNS subdomain,
taking the form: `$(podname).$(governing service domain)`, where the governing
service is defined by the `serviceName` field on the StatefulSet.

Depending on how DNS is configured in your cluster, you may not be able to look
up the DNS name for a newly-run Pod immediately. This behavior can occur when
other clients in the cluster have already sent queries for the hostname of the
Pod before it was created. Negative caching (normal in DNS) means that the
results of previous failed lookups are remembered and reused, even after the
Pod is running, for at least a few seconds.

If you need to discover Pods promptly after they are created, you have a few
options:

* Query the Kubernetes API directly (for example, using a watch) rather than
relying on DNS lookups.

* Decrease the time of caching in your Kubernetes DNS provider (tpyically this
means editing the config map for CoreDNS, which currently caches for 30 seconds).

Here are some examples of choices for Cluster Domain, Service name, StatefulSet
name, and how that affects the DNS names for the StatefulSet's Pods.

```
Cluster Domain    Service     StatefulSet      StatefulSet              Pod DNS                  Pod Hostname
                 (ns/name)     (ns/name)         Domain

cluster.local    default/      default/      nginx.default         web-{0..N-1}.nginx            web-{0..N-1}
                  nginx    	    web          .svc.cluster.local    .default.svc.cluster.local

cluster.local	foo/nginx	   foo/web	     nginx.foo             web-{0..N-1}.nginx            web-{0..N-1}
                                             .svc.cluster.local    .foo.svc.cluster.local

kube.local	    foo/nginx	   foo/web	     nginx.foo             web-{0..N-1}.nginx            web-{0..N-1}
                                             .svc.kube.local       .foo.svc.kube.local
```

Note: Cluster Domain will be set to `cluster.local` unless otherwise configured.

#### Pod Name Label

When the StatefulSet Controller creates a Pod, it adds a label,
`statefulset.kubernetes.io/pod-name`, that is set to the name of the Pod. This
label allows you to attach a Service to a specific Pod in the StatefulSet.

#### Pod Management Policies

StatefulSet allows you to relax its ordering guarantees while preserving its uniqueness and identity guarantees via its `.spec.podManagementPolicy` field.

##### `OrderedReady` Pod Management

`OrderedReady` pod management is the default for StatefulSets.

##### `Parallel` Pod Management

`Parallel` pod management tells the StatefulSet controller to launch or
terminate all Pods in parallel, and to not wait for Pods to become Running and
Ready or completely terminated prior to launching or terminating another Pod.
This option only affects the behavior for scaling operations. Updates are not
affected.

* Follow an example of [deploying a stateful application](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/).
* Follow an example of [deploying Cassandra with Stateful Sets](https://kubernetes.io/docs/tutorials/stateful-application/cassandra/).
* Follow an example of [running a replicated stateful application](https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/).






