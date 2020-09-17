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
* install Docker as CRI (see `kubeinstall::runtime::docker`)
* install Calico as CNI (see `kubeinstall::install::calico`)
* install Kubernetes Dashboard UI on controller (see `kubeinstall::install::dashboard`)

### Setup Requirements **OPTIONAL**

It requires non-published on Puppet Forge module `aursu::dockerinstall` which is set
of different Docker related features

Puppetfile setup:

```
mod 'dockerinstall',
  :git => 'https://github.com/aursu/puppet-dockerinstall.git',
  :tag => 'v0.6.4'
```

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

In order to setup settings it iss possible to use Hiera:

```
kubeinstall::cluster_name: projectname
kubeinstall::control_plane_endpoint: kube.intern.domain.tld
```

## Reference

See REFERENCE.md for reference

## Limitations

## Development


## Release Notes/Contributors/Etc. **Optional**

