### [Container Environment](https://kubernetes.io/docs/concepts/containers/container-environment/)

##### Container information

The `hostname` of a Container is the name of the Pod in which the Container is
running. It is available through the `hostname` command or the `gethostname`
function call in libc.

The Pod name and namespace are available as environment variables through the
[downward API](https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/).

User defined environment variables from the Pod definition are also available
to the Container, as are any environment variables specified statically in the
Docker image.

##### Cluster information

A list of all services that were running when a Container was created is
available to that Container as environment variables.