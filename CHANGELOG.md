# Changelog

All notable changes to this project will be documented in this file.

## Release 0.2.1

**Features**

* Added Helm client binary installation

**Bugfixes**

**Known Issues**

## Release 0.2.2

**Features**

* Added service_node_port_range parameter for kubeadm init command

**Bugfixes**

**Known Issues**

## Release 0.2.3

**Features**

* Added Docker default bridge network address setup (conform to daemon.json bip parameter)

**Bugfixes**

**Known Issues**

## Release 0.2.4

**Features**

* Added resource for Kubernetes Secret object

**Bugfixes**

**Known Issues**

## Release 0.3.0

**Features**

* Added CRI-O runtime installation

**Bugfixes**

**Known Issues**

## Release 0.3.1

**Features**

**Bugfixes**

* Switched to Puppet module puppetlabs/helm

**Known Issues**

## Release 0.3.2

**Features**

**Bugfixes**

* Bugfix: helm installation  URL

**Known Issues**

## Release 0.3.3

**Features**

**Bugfixes**

* Bugfix: helm installation exec path

**Known Issues**

## Release 0.3.4

**Features**

**Bugfixes**

* Removed Puppet module puppetlabs/helm (no support for Helm 3.0+)

**Known Issues**

## Release 0.3.5

**Features**

* Default version upgrade

**Bugfixes**

* Added containment for several calsses and resources

**Known Issues**

## Release 0.3.6

**Features**

**Bugfixes**

* Docker decomission before CRI-O setup

**Known Issues**

## Release 0.3.7

**Features**

* Added `kubeadm reset` during Docker decomission

**Bugfixes**

**Known Issues**

## Release 0.3.8

**Features**

**Bugfixes**

* Drop camptocamp/systemd dependency

**Known Issues**

## Release 0.4.0

**Features**

* Updated default versions of all components

**Bugfixes**

**Known Issues**

## Release 0.5.0

**Features**

* Added ability to define StorageClass resource file

**Bugfixes**

**Known Issues**

## Release 0.6.0

**Features**

* Added krew installation
* Added admin config setup
* Added bash completion

**Bugfixes**

**Known Issues**

## Release 0.6.1

**Features**

**Bugfixes**

* Added /usr/local/krew directory management

**Known Issues**

## Release 0.6.2

**Features**

**Bugfixes**

* Added PATH setup to include ~/.krew/bin

**Known Issues**

## Release 0.7.0

**Features**

* Added krew plugiin istallation resource
* Added kubernetes namespace resource (create)

**Bugfixes**

**Known Issues**

## Release 0.8.0

**Features**

* Added kubectl apply resoure

**Bugfixes**

**Known Issues**

## Release 0.9.0

**Features**

* Added ArgoCD installation

**Bugfixes**

**Known Issues**

## Release 0.9.1

**Features**

* Added IPv6 enable/disable feature

**Bugfixes**

* Corrected selinux management class

**Known Issues**

## Release 0.9.2

**Features**

* Added selinux modes
* Updated components

**Bugfixes**

**Known Issues**

## Release 0.10.0

**Features**

* Added CRI-O configuration file management with ability to manage selinux flag
* Updated fixtures and metadata

**Bugfixes**

* Bugfix: unit test for updated Docker components

**Known Issues**

## Release 0.10.1

**Features**

* Added kubeinstall::node::label to setup node labels
* Added ability to export node labels resources within cluster

**Bugfixes**

**Known Issues**

## Release 0.10.3

**Features**

**Bugfixes**

* Bugfix: added class kubeinstall::runtime::crio::config into CRI-O runtime
  manifest

**Known Issues**

## Release 0.11.0

**Features**

* Added kubeinstall::resource::svc to manage Service resource

**Bugfixes**

**Known Issues**

## Release 0.12.0

**Features**

* Added ArgoCD expose service (by default NodePort on port 30200)

**Bugfixes**

**Known Issues**

## Release 0.12.1

**Features**

* Added volume_mode parameter into local PV

**Bugfixes**

**Known Issues**

## Release 0.13.0

**Features**

* Updated kubernetes and components versions

**Bugfixes**

**Known Issues**

## Release 0.14.0

**Features**

* Added Ubuntu support

**Bugfixes**

**Known Issues**

## Release 0.14.1

**Features**

**Bugfixes**

* Bugfix: krew installation for versions 0.4.2 and greater
* Bugfix: Apt repositories fix for CRI-O
* Bugfix: Apt repository fix for K8S
* Bugfix: K8S installation for Ubuntu when version is not exact

**Known Issues**

## Release 0.15.0

**Features**

* Changed default cgroup driver to systemd

**Bugfixes**

**Known Issues**

## Release 0.15.1

**Features**

**Bugfixes**

* Bugfix: K8S installation for Ubuntu when version is not exact
* Bugfix: Krew installation on Ubuntu

**Known Issues**

## Release 0.16.0

**Features**

* Added ability to activate Cgroup v2

**Bugfixes**

**Known Issues**

## Release 0.16.1

**Features**

* Added task and plan kubeinstall::cgroup2

**Bugfixes**

**Known Issues**

## Release 0.16.5

**Features**

* Added kernel check into kubeinstall::cgroup2 task
* Added existing kernel parametrs check into kubeinstall::cgroup2 task
* Added verbosity to kubeinstall::cgroup2 plan
* Added check if reboot required in kubeinstall::cgroup2 task

**Bugfixes**

* Bugfix: resolve error uninitialized constant Puppet::Parameter::Boolean
* Bugfix: task metadata for task kubeinstall::cgroup2

**Known Issues**

## Release 0.16.7

**Features**

* Setup task output as JSON

**Bugfixes**

* Bugfix: handle reboot flag properly

**Known Issues**

## Release 0.16.8

**Features**

**Bugfixes**

* Bugfix: repository and package apply sequence

**Known Issues**

## Release 0.17.0

**Features**

* Added basic Helm repo and chart management
* Added Helm completion for bash

**Bugfixes**

**Known Issues**

## Release 0.17.1

**Features**

* Updated default versions of components

**Bugfixes**

**Known Issues**

## Release 0.17.2

**Features**

**Bugfixes**

* Added /root/.config directory setup

**Known Issues**

## Release 0.17.3

**Features**

* Updated default versions of components

**Bugfixes**

**Known Issues**

## Release 0.17.4

**Features**

**Bugfixes**

* Corrected URL to Calico installation manifest
* Corrected Yum repo for CentOS 7

**Known Issues**

## Release 0.18.0

**Features**

* Added ability to manage grubby
* Added cgroup2 support for CentOS
* Added fact `kernelentries`

**Bugfixes**

* Made Git optional

**Known Issues**

## Release 0.18.1

**Features**

* Set net.core.somaxconn to default value 4096

**Bugfixes**

**Known Issues**

## Release 0.18.2

**Features**

**Bugfixes**

* Exclude package kubernetes-cni from update
* Added --overwrite flag into label node command

**Known Issues**

## Release 0.18.3

**Features**

**Bugfixes**

* Exclude package kubernetes-cni from update
* Updated fixtures and dependencies

**Known Issues**

## Release 0.18.4

**Features**

* Added folder /root/.config/helm/charts for Helm charts configurations
* Versions  upgrade

**Bugfixes**

**Known Issues**

## Release 0.18.5

**Features**

* Defined configuration paths variables into parameters

**Bugfixes**

**Known Issues**