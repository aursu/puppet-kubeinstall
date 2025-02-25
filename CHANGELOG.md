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

## Release 0.18.6

**Features**

**Bugfixes**

* Added KUBECONFIG variable into `exec` resource for `helm`

**Known Issues**

## Release 0.18.7

**Features**

**Bugfixes**

* Updated fixtures

**Known Issues**

## Release 0.18.8

**Features**

* Added kubernetes versions 1.25-1.27

**Bugfixes**

**Known Issues**

## Release 0.19.0

**Features**

* Helm 3.11.3, Calico v3.25.1, ArgoCD 2.6.7

**Bugfixes**

**Known Issues**

## Release 0.19.3

**Features**

* Added ArgoCD CLI installatio into /usr/local/bin/argocd

**Bugfixes**

* Exclude package kubernetes-cni from update only for Kubernetes < 1.25.0
* ArgoCD service for NodePort renamed to argocd-server-static

**Known Issues**

## Release 0.19.4

**Features**

* PDK Upgrade to 2.7.1

**Bugfixes**

**Known Issues**

## Release 0.20.0

**Features**

* Added TopoLVM lvmd binary installation

**Bugfixes**

**Known Issues**

## Release 0.20.1

**Features**

**Bugfixes**

* Fixed puppet lint and rubocop errors

**Known Issues**

## Release 0.20.2

**Features**

* Added TopoLVM lvmd config and service

**Bugfixes**

**Known Issues**

## Release 0.20.3

**Features**

* Adjusted lvmd config manifest

**Bugfixes**

**Known Issues**

## Release 0.20.4

**Features**

* Added refreshed ensure flag for APT keys

**Bugfixes**

* CRIO: separate version flag for cri-o-runc package

**Known Issues**

## Release 0.20.5

**Features**

* CRIO: added support for Ubuntu Apt versions

**Bugfixes**

**Known Issues**

## Release 0.20.6

**Features**

* K8S: refreshed ensure flag for APT keys

**Bugfixes**

**Known Issues**

## Release 0.21.0

**Features**

**Bugfixes**

* Added fix for removed container-runtime kubelet option
* Updated kubeadm init and join configuration

**Known Issues**

## Release 0.22.0

**Features**

* Added TopoLVM scheduler configuration setup
* Added kube-scheduler configuration management

**Bugfixes**

**Known Issues**

## Release 0.22.1

**Features**

**Bugfixes**

* No duplicate entries for TopoLVM inside kube-scheduler config

**Known Issues**

## Release 0.22.7

**Features**

**Bugfixes**

* Removed ConfigMap as kube-scheduler volume
* Added command to create TopoLVM scheduler diectory recursively
* Replace existing volumes with defined in Puppet
* BugFix: incorrect creationTimestamp type

**Known Issues**

## Release 0.23.0

**Features**

* Added Calico operator and custom resources

**Bugfixes**

**Known Issues**

## Release 0.23.1

**Features**

* Added xfs/ext4 utilities for nodes with lvmd daemon

**Bugfixes**

**Known Issues**

## Release 0.24.0

**Features**

* PDK upgrade to 3.0.0
* Added separate class for directory structure setup
* Added systemd daemon reload from bsys module
* Increased default Kubernetes version to 1.28.2

**Bugfixes**

**Known Issues**

## Release 0.25.1

**Features**

* Added Bolt plan `kubeinstall::setup`
* Added parameter `cert_dir`

**Bugfixes**

**Known Issues**

## Release 0.26.2

**Features**

* Added class `kubeinstall::kubectl::binary` for kubectl installation
* Added sha256sum check for kubectl

**Bugfixes**

**Known Issues**

## Release 0.27.0

**Features**

* Added kube-apiserver, kubectl, kube-controller-manager and kube-scheduler binaries installation

**Bugfixes**

**Known Issues**

## Release 0.28.0

**Features**

* Added 'ClusterRole' and 'ClusterRoleBinding' into kubeinstall::kubectl::apply

**Bugfixes**

**Known Issues**

## Release 0.29.4

**Features**

* Added containerd Kubernetes runtime installation

**Bugfixes**

* Bugfix: containerd plan name
* Bugfix: wrong type name for nerdctl installation
* Bugfix: sha256 checksum check for nerdctl
* Bugfix: containerd components archive extract

**Known Issues**

## Release 0.30.3

**Features**

* Added CNI plugins `bridge` and `loopback` configuration
* Added `containerd` service management
* Added `crictl` installation
* Enabled default config.toml setup for containerd

**Bugfixes**

* Added `containerd` service refresh on configuration changes
* Bugfix: use network configurations instead plugin configurations

**Known Issues**

## Release 0.31.1

**Features**

* Added 'kubelet' and 'kube-proxy' Kubernetes components installation

**Bugfixes**

* Bugfix: removed duplicate file resource

**Known Issues**

## Release 0.32.1

**Features**

* Adjusted components' versions

**Bugfixes**

* Bugfix: added flag to allow default namespace

**Known Issues**

## Release 0.33.0

**Features**

**Bugfixes**

* Bugfix: corrected cri-o installation on Ubuntu when version is not set

**Known Issues**

## Release 0.34.1

**Features**

**Bugfixes**

* Bugfix: corrected /etc/containers/policy.json on CentOS 8 Stream

**Known Issues**

## Release 0.35.5

**Features**

* Updated packages repos for Kubenetes project and package version for Ubuntu
* Added version check for Argo CD

**Bugfixes**

* Corrected versions for Argo CD and Calico
* Updated keyring path to /etc/apt/trusted.gpg.d

**Known Issues**

## Release 0.36.2

**Features**

* Introduced calico opeator version (current is: 1.30.9)
* Updated containerd and runc default versions

**Bugfixes**

* Corrected `path` property for each exec with kubectl in `command` or `unless`
* Removed hostname from `onlyif` condition `kubectl get nodes` (kubelet could be not installed on
  control plain) 

**Known Issues**

## Release 0.37.0

**Features**

* Added ability to remove label from node

**Bugfixes**

* Bugfix: change include to contain for calicactl

**Known Issues**

## Release 0.38.4

**Features**

* Added ability to setup differet kubeconfig for ArgoCD installation
* Updated default ArgoCD version to 2.9.3
* Added port 80 into static ArgoCD servicee

**Bugfixes**

* Added separate NodePort port for HTTP service port

**Known Issues**

## Release 0.38.5

**Features**

* Added auto-refresh for repo upon changes

**Bugfixes**

**Known Issues**

## Release 0.39.1

**Features**

* Components and versions upgrade

**Bugfixes**

**Known Issues**

## Release 0.39.3

**Features**

* Allow cri-o version be different then kubernetes version

**Bugfixes**

**Known Issues**

## Release 0.39.4

**Features**

* Upgraded default versions of components

**Bugfixes**

* Added support of Kubernetes 1.29.x for TopoLVM scheduler config

**Known Issues**

## Release 0.40.0

**Features**

* Added PVC resource definition for Persistence volume claims
* Upgraded default versions of components

**Bugfixes**

**Known Issues**

## Release 0.40.1

**Features**

* Added claimRef into PV resource definition

**Bugfixes**

* Fixed unit tests to match new versions of components

**Known Issues**

## Release 0.41.1

**Features**

* Replaced `selector` parameter with `match_expressions` and `match_labels`
* Added exported PVC resources collector into `kubeinstall::cluster`

**Bugfixes**

**Known Issues**

## Release 0.43.4

**Features**

* Upgraded default versions of components
* Upgraded cri-o repos
* Removed CentOS 8 Stream support
* Rolled back devel:kubic:libcontainers:stable
* dependencies update

**Bugfixes**

* cri-o installation bugfix for packages hosted on pkgs.k8s.io
* fixed gpg key file name for devel:kubic:libcontainers:stable

**Known Issues**
