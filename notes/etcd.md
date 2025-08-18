## make Etcd backup

```
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /root/etcd-backup.db
```

## Show list of Etcd members

```
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key member list
61169d3310e31917, started, k8s11-lv-lw-eu.host.cryengine.com, https://10.154.4.22:2380, https://10.154.4.22:2379, false
ad962d45b495b893, started, k8s1-lv-lw-eu.host.cryengine.com, https://10.154.4.12:2380, https://10.154.4.12:2379, false
```

## remove host

ETCDCTL_API=3 etcdctl   --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  member remove ad962d45b495b893
