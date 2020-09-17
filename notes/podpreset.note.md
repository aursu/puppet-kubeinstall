### [Pod Presets](https://kubernetes.io/docs/concepts/workloads/pods/podpreset/)

PodPresets are objects for injecting certain information into pods at creation
time. The information can include secrets, volumes, volume mounts, and
environment variables.

#### Enable PodPreset in your cluster

In order to use Pod presets in your cluster you must ensure the following:

1. You have enabled the API type `settings.k8s.io/v1alpha1/podpreset`. For
example, this can be done by including `settings.k8s.io/v1alpha1=true` in the
`--runtime-config` option for the API server. In minikube add this flag
`--extra-config=apiserver.runtime-config=settings.k8s.io/v1alpha1=true` while
starting the cluster.

2. You have enabled the admission controller named `PodPreset`. One way to
doing this is to include `PodPreset` in the `--enable-admission-plugins` option
value specified for the API server. For example, if you use Minikube, add this
flag:

```
--extra-config=apiserver.enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota,PodPreset
```

while starting your cluster.

#### What's next

See [Injecting data into a Pod using PodPreset](https://kubernetes.io/docs/tasks/inject-data-application/podpreset/)

For more information about the background, see the
[design proposal for PodPreset](https://git.k8s.io/community/contributors/design-proposals/service-catalog/pod-preset.md).


