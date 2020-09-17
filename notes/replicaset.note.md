### [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)

A ReplicaSet is linked to its Pods via the Pods'
[`metadata.ownerReferences`](https://kubernetes.io/docs/concepts/workloads/controllers/garbage-collection/#owners-and-dependents)
field, which specifies what resource the current object is owned by. All Pods
acquired by a ReplicaSet have their owning ReplicaSet's identifying information
within their ownerReferences field. It's through this link that the ReplicaSet
knows of the state of the Pods it is maintaining and plans accordingly.

#### [Writing a ReplicaSet manifest](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#writing-a-replicaset-manifest)

As with all other Kubernetes API objects, a ReplicaSet needs the `apiVersion`,
`kind`, and `metadata` fields. For ReplicaSets, the kind is always just
ReplicaSet. In Kubernetes 1.9 the API version `apps/v1` on the ReplicaSet kind
is the current version and is enabled by default. The API version `apps/v1beta2`
is deprecated.

The name of a ReplicaSet object must be a valid [DNS subdomain name](#dns-subdomain-name).

A ReplicaSet also needs a [.spec section](https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status).

#### Pod Selector

The `.spec.selector` field is a
[label selector](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/).
These are the labels used to identify potential Pods to acquire.

In the ReplicaSet, `.spec.template.metadata.labels` must match `spec.selector`,
or it will be rejected by the API.

Note: For 2 ReplicaSets specifying the same `.spec.selector` but different
`.spec.template.metadata.labels` and `.spec.template.spec` fields, each
ReplicaSet ignores the Pods created by the other ReplicaSet.

#### [ReplicaSet as a Horizontal Pod Autoscaler Target](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#replicaset-as-a-horizontal-pod-autoscaler-target)

A ReplicaSet can also be a target for
[Horizontal Pod Autoscalers (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/).
That is, a ReplicaSet can be auto-scaled by an HPA.


#### [DNS Subdomain Names](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-subdomain-names)

Most resource types require a name that can be used as a DNS subdomain name as
defined in [RFC 1123](https://tools.ietf.org/html/rfc1123). This means the name must:

* contain no more than 253 characters
* contain only lowercase alphanumeric characters, '-' or '.'
* start with an alphanumeric character
* end with an alphanumeric character
