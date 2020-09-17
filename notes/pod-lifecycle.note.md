### [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)

#### Container probes

A [Probe](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#probe-v1-core)
is a diagnostic performed periodically by the kubelet on a Container. To
perform a diagnostic, the kubelet calls a
[Handler](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#handler-v1-core)
implemented by the container. There are three types of handlers:

* [ExecAction](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#execaction-v1-core):
Executes a specified command inside the container. The diagnostic is considered
successful if the command exits with a status code of 0.

* [TCPSocketAction](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#tcpsocketaction-v1-core):
Performs a TCP check against the Pod's IP address on a specified port. The
diagnostic is considered successful if the port is open.

* [HTTPGetAction](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#httpgetaction-v1-core):
Performs an HTTP GET request against the Pod's IP address on a specified port
and path. The diagnostic is considered successful if the response has a status
code greater than or equal to 200 and less than 400.

Each probe has one of three results:

* `Success`: The container passed the diagnostic.
* `Failure`: The container failed the diagnostic.
* `Unknown`: The diagnostic failed, so no action should be taken.

The kubelet can optionally perform and react to three kinds of probes on
running containers:

* `livenessProbe`: Indicates whether the container is running. If the liveness
probe fails, the kubelet kills the container, and the container is subjected to
its restart policy. If a Container does not provide a liveness probe, the
default state is `Success`.

* `readinessProbe`: Indicates whether the container is ready to respond to
requests. If the readiness probe fails, the endpoints controller removes the
Pod's IP address from the endpoints of all Services that match the Pod. The
default state of readiness before the initial delay is `Failure`. If a
Container does not provide a readiness probe, the default state is `Success`.

* `startupProbe`: Indicates whether the application within the container is
started. All other probes are disabled if a startup probe is provided, until it
succeeds. If the startup probe fails, the kubelet kills the container, and the
container is subjected to its restart policy. If a Container does not provide a
startup probe, the default state is `Success`.

For more information about how to set up a liveness, readiness, or startup
probe, see [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/).

##### When should you use a readiness probe?

If you'd like to start sending traffic to a Pod only when a probe succeeds,
specify a readiness probe. In this case, the readiness probe might be the same
as the liveness probe, but the existence of the readiness probe in the spec
means that the Pod will start without receiving any traffic and only start
receiving traffic after the probe starts succeeding. If your container needs to
work on loading large data, configuration files, or migrations during startup,
specify a readiness probe.

If you want your container to be able to take itself down for maintenance, you
can specify a readiness probe that checks an endpoint specific to readiness
that is different from the liveness probe.

##### When should you use a startup probe?

Startup probes are useful for Pods that have containers that take a long time
to come into service. Rather than set a long liveness interval, you can
configure a separate configuration for probing the container as it starts up,
allowing a time longer than the liveness interval would allow.

If your container usually starts in more than
`initialDelaySeconds` + `failureThreshold` × `periodSeconds`, you should
specify a startup probe that checks the same endpoint as the liveness probe.
The default for periodSeconds is 30s. You should then set its failureThreshold
high enough to allow the container to start, without changing the default
values of the liveness probe. This helps to protect against deadlocks.

