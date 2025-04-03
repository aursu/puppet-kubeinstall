# Uploading Control Plane Certificates to the Cluster

By adding the flag `--upload-certs` to `kubeadm init`, you can temporarily upload the control plane certificates to a Secret in the cluster.  
**Please note:** This Secret will expire automatically after 2 hours.

The certificates are encrypted using a 32-byte key that can be specified using `--certificate-key`.  
The same key can be used to download the certificates when additional control plane nodes are joining, by passing `--control-plane` and `--certificate-key` to `kubeadm join`.

## Re-uploading Certificates After Expiration

The following phase command can be used to re-upload the certificates after expiration:

```bash
kubeadm init phase upload-certs --upload-certs --config=SOME_YAML_FILE
```

> **Note:**  
> A predefined `certificateKey` can be provided in `InitConfiguration` when passing the configuration file with `--config`.

If a predefined certificate key is not passed to `kubeadm init` and `kubeadm init phase upload-certs`, a new key will be generated automatically.

The following command can be used to generate a new key on demand:

```bash
kubeadm certs certificate-key
```
