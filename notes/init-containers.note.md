### [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)

#### Understanding init containers

A Pod can have multiple containers running apps within it, but it can also have
one or more init containers, which are run before the app containers are
started.

Init containers are exactly like regular containers, except:

* Init containers always run to completion.
* Each init container must complete successfully before the next one starts.

If a Pod's init container fails, Kubernetes repeatedly restarts the Pod until
the init container succeeds. However, if the Pod has a `restartPolicy` of Never,
Kubernetes does not restart the Pod.

To specify an init container for a Pod, add the `initContainers` field into the
Pod specification, as an array of objects of type
[Container](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#container-v1-core),
alongside the app containers array. The status of the init containers is
returned in `.status.initContainerStatuses` field as an array of the container
statuses (similar to the `.status.containerStatuses` field).

#### Using init containers

Because init containers have separate images from app containers, they have
some advantages for start-up related code:

* Init containers can contain utilities or custom code for setup that are not
present in an app image. For example, there is no need to make an image `FROM`
another image just to use a tool like sed, awk, python, or dig during setup.

* The application image builder and deployer roles can work independently
without the need to jointly build a single app image.

* Init containers can run with a different view of the filesystem than app
containers in the same Pod. Consequently, they can be given access to Secrets
that app containers cannot access.

* Because init containers run to completion before any app containers start,
init containers offer a mechanism to block or delay app container startup until
a set of preconditions are met. Once preconditions are met, all of the app
containers in a Pod can start in parallel.

* Init containers can securely run utilities or custom code that would
otherwise make an app container image less secure. By keeping unnecessary tools
separate you can limit the attack surface of your app container image.


