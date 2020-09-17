### [Writing a Deployment Spec](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#writing-a-deployment-spec)

As with all other Kubernetes configs, a Deployment needs `.apiVersion`, `.kind`,
and `.metadata` fields.

For general information about working with config files, see
[deploying applications](https://kubernetes.io/docs/tasks/run-application/run-stateless-application-deployment/),
configuring containers, and
[using kubectl to manage resources](https://kubernetes.io/docs/concepts/overview/working-with-objects/object-management/)
documents

A Deployment also needs a
[`.spec` section](https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status).

#### Pod Template

The `.spec.template` and `.spec.selector` are the only required field of the
`.spec`.

The `.spec.template` is a
[Pod template](https://kubernetes.io/docs/concepts/workloads/pods/#pod-templates).
It has exactly the same schema as a Pod , except it is nested and does not have
an `apiVersion` or `kind`.

In addition to required fields for a Pod, a Pod template in a Deployment must
specify appropriate labels and an appropriate restart policy. For labels, make
sure not to overlap with other controllers.

Only a `.spec.template.spec.restartPolicy` equal to `Always` is allowed, which
is the default if not specified.

#### Replicas

`.spec.replicas` is an optional field that specifies the number of desired Pods.
It defaults to 1.

#### Selector

`.spec.selector` is a required field that specifies a
[label selector](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
for the Pods targeted by this Deployment.

`.spec.selector` must match `.spec.template.metadata.labels`, or it will be
rejected by the API.

In API version `apps/v1`, `.spec.selector` and `.metadata.labels` do not
default to `.spec.template.metadata.labels` if not set. So they must be set
explicitly. Also note that `.spec.selector` is immutable after creation of the
Deployment in `apps/v1`.

A Deployment may terminate Pods whose labels match the selector if their
template is different from `.spec.template` or if the total number of such Pods
exceeds `.spec.replicas`. It brings up new Pods with `.spec.template` if the
number of Pods is less than the desired number.

You should not create other Pods whose labels match this selector, either
directly, by creating another Deployment, or by creating another controller
such as a `ReplicaSet` or a `ReplicationController`. If you do so, the first
Deployment thinks that it created these other Pods. Kubernetes does not stop
you from doing this.

If you have multiple controllers that have overlapping selectors, the
controllers will fight with each other and won't behave correctly.

#### Strategy

`.spec.strategy` specifies the strategy used to replace old Pods by new ones.
`.spec.strategy.type` can be "Recreate" or "RollingUpdate". "RollingUpdate" is
the default value.

