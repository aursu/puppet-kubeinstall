# kubeinstall

Kubernetes cluster installation following kubernetes.io installation Guide

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with kubeinstall](#setup)
    * [What kubeinstall affects](#what-kubeinstall-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with kubeinstall](#beginning-with-kubeinstall)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

Module has ability to setup Kubernetes control plain host (included base
profile `kubeinstall::profile::controller`), Kubernetes worker host (using base
profile `kubeinstall::install::worker`)

It supports atomatic Kubernetes cluster setup using Puppet exported resources
via PuppetDB

## Setup

### What kubeinstall affects **OPTIONAL**

Module install Kubernetes components including `kubeadm` and its configuration
for proper Nodes bootstrap.

Also it by default:
* disable swap (see `kubeinstall::system::swap`),
* disable firewalld (see `kubeinstall::system::firewall::noop`),
* disable selinux (see `kubeinstall::system::selinux::noop`),
* set kernel settings for iptables (see `kubeinstall::system::sysctl::net_bridge`)
* install CRI-O as CRI (see `kubeinstall::runtime::crio`). Also Docker CRI is available
  via `kubeinstall::runtime::docker`
* install Calico as CNI (see `kubeinstall::install::calico`)
* install Kubernetes Dashboard UI on controller (see `kubeinstall::install::dashboard`)

### Setup Requirements **OPTIONAL**

`CentOS 7` operating system or similar.

### Beginning with kubeinstall

## Usage

In order to use kubeinstall and setup yoour controller node it is enough to
create such Puppet profile:

```
class profile::kubernetes::controller {
  class { 'kubeinstall::profile::kubernetes': }
  class { 'kubeinstall::profile::controller': }
}
```

and for worker node:

```
class profile::kubernetes::worker {
  class { 'kubeinstall::profile::kubernetes': }
  class { 'kubeinstall::profile::worker': }
}
```

In order to setup settings it is possible to use Hiera:

```
kubeinstall::cluster_name: projectname
kubeinstall::control_plane_endpoint: kube.intern.domain.tld
```

### Cluster features

Class `kubeinstall::cluster` is responsible for bootstrap token exchange between
controller and worker nodes (for worker bootstrap). For this PuppetDB is required
because exported resource (`kubeinstall::token_discovery`) and exported resources
collector (implemnted via custom function `kubeinstall::discovery_hosts`) are
in use.

Also there is a feature of exporting local PersistentVolume resources from worker
nodes into controller directory `/etc/kubectl/manifests/persistentvolumes`.
To activate it is required to setup properly flag `kubeinstall::cluster::cluster_role`
on both worker and controller hosts and provide all requirements to export PVs on
worker node.

## Reference

See REFERENCE.md for reference

## Limitations

## Development


## Release Notes/Contributors/Etc. **Optional**

