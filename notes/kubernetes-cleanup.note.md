# Kubernetes node teardown

Manual sequence to fully decommission a node that was joined to a cluster with
`kubeadm` and CRI-O, so it can be re-provisioned from scratch (e.g. before
re-running Puppet's `kubeinstall` bootstrap).

## 1. Unwind kubeadm state

```bash
kubeadm reset
```

Reverses `kubeadm init`/`kubeadm join`: drains local kubelet config, stops
static pods, removes `/etc/kubernetes/manifests`, PKI, and the kubeconfig
files it generated. Does **not** touch CNI, container runtime, or packages —
those are cleaned up separately below.

## 2. Stop the container runtime

```bash
systemctl stop crio
```

Stops the CRI-O service so its storage (images, containers, mounts) is no
longer in use and can be removed safely in step 4.

## 3. Remove the installed packages

```bash
dpkg -P cri-o cri-o-runc cri-tools kubeadm kubectl kubelet
```

`dpkg -P` (purge) removes each package **and** its config files (unlike
plain `-r`, which leaves conffiles behind). Covers the CRI-O runtime + its
runc shim, the `crictl`/`critest` CLI tools, and the three kubeadm-managed
Kubernetes binaries.

## 4. Wipe remaining state directories

```bash
rm -rf /etc/kubernetes /var/lib/kubelet /etc/crio /var/lib/crio /etc/topolvm /etc/kubectl /etc/cni \
    /etc/calico /etc/docker /var/lib/containers /var/lib/argocd /var/lib/calico /var/lib/cni /var/lib/compose \
    /var/lib/docker /var/lib/etcd /var/lib/kube-proxy
```

Purge doesn't remove data directories that aren't tracked as package
conffiles, so these are deleted explicitly:

| Path | Left behind by |
|---|---|
| `/etc/kubernetes` | kubeadm config, PKI, admin kubeconfig (kubeadm reset misses some files) |
| `/var/lib/kubelet` | kubelet's pod/volume state |
| `/etc/crio`, `/var/lib/crio` | CRI-O config and image/container storage |
| `/etc/topolvm` | TopoLVM CSI driver config |
| `/etc/kubectl` | local kubectl config used by this host |
| `/etc/cni`, `/var/lib/cni` | CNI plugin config and runtime state |
| `/etc/calico`, `/var/lib/calico` | Calico CNI config and datastore state |
| `/etc/docker`, `/var/lib/docker` | Docker config/data (present if Docker was ever installed alongside CRI-O) |
| `/var/lib/containers` | shared container storage (podman/CRI-O image layers) |
| `/var/lib/argocd` | ArgoCD agent state, if this node ran one |
| `/var/lib/compose` | leftover docker-compose project state |
| `/var/lib/etcd` | etcd data dir — **only safe to remove on a control-plane node that is being fully decommissioned**, this is the cluster's datastore |
| `/var/lib/kube-proxy` | kube-proxy's iptables/ipvs state cache |

⚠️ Destructive — this permanently deletes cluster and runtime state on the
node. Confirm the node is actually being decommissioned (not just having its
kubelet restarted) before running step 4, and double-check `/var/lib/etcd`
isn't the last surviving copy of cluster data.
