# EDCOP
The Expandable Defensive Cyber Operations Platform

## Overview
---
The EDCOP is a platform to deploy virtual network defense tools on.

## Setup Build Environment
This procedure assumes that you have already installed a CentOS 7.4 Minimal installation and have at least 10GB of space available.
---

#### Install an initial set of packages and EDCOP Repo
```shell
sudo yum --disablerepo=* --enablerepo=base --enablerepo=extras install net-tools mlocate vim git epel-release wget patch rpm-build gcc openssl-devel checkpolicy selinux-policy-devel kernel-devel doxygen python-six libcap-ng-devel isomd5sum syslinux gcc createrepo mkisofs yum-utils golang

sudo rpm -ivh http://repos.sealingtech.org/edcop/edcop-repo-1-0.noarch.rpm
```

#### Setup GIT and clone repo

```shell
git config --global user.name "User Name"
git config --global user.email "email.address@sealingtech.org"
git clone https://github.com/sealingtech/EDCOP
```

#### Mount CentOS ISO
The Offline Build scripts pull the required packages from the CentOS install disk. This should be mounted in a location expected by the c7-media repo that is built into CentOS 7.

```shell
mkdir -p /media/cdrom
sudo mount /dev/cdrom /media/cdrom
```


## Building Packages
---

Most of the packages required to create the install disk are available in the EDCOP repo at http://repos.sealingtech.org/edcop/1.0. However, if you would like to build these packages yourself, these procedures will help.

If you prefer to get the RPMs from the repo, you can install that repo and download the packages via:

```shell
rpm -ivh http://repos.sealingtech.org/edcop/edcop-repo-1-0.noarch.rpm
yumdownloader --resolve --disablerepo=\* --enablerepo=c7-media --enablerepo=edcop <packages>
```

Packages for building:
*openvswitch RPM
*openvswitch-devel RPM
*dpdk-stable RPM
*dpdk-stable-devel RPM
*edcop-cni Plugins (multus, SR-IOV, OVS, flannel, etc)




The following sections will walk trhough building the DPDK and Openvswitch RPM packages.

#### Install Build Dependencies
---

```shell
yum install net-tools mlocate vim git epel-release wget patch rpm-build gcc openssl-devel checkpolicy selinux-policy-devel htop kernel-devel doxygen python-six libcap-ng-devel isomd5sum syslinux gcc createrepo mkisofs yum-utils
```

#### Building DPDK Packages
---
The following script will download DPDK 16.11, build the required RPMs and install to your local build system. The DPDK RPMs must be installed before building OpenvSwitch.

```shell
mkdir -p ~/rpmbuild/SOURCES
wget -O dpdk-stable-16.11.1.tar.xz http://fast.dpdk.org/rel/dpdk-16.11.1.tar.xz
tar xf dpdk-stable-16.11.1.tar.xz
patch dpdk-stable-16.11.1/pkg/dpdk.spec dpdk_stech_5-5-2017.patch
cp ./dpdk-stable-16.11.1.tar.xz ~/rpmbuild/SOURCES/
rpmbuild -bb dpdk-stable-16.11.1/pkg/dpdk.spec
cp ~/rpmbuild/RPMS/x86_64/dpdk-stable-*.rpm .
yum localinstall ./dpdk-stable-16.11.1-1.x86_64.rpm ./dpdk-stable-devel-16.11.1-1.x86_64.rpm
ldconfig
```


#### Building OpenvSwitch Packages
---
The following script will build OpenvSwitch 2.7.0 RPMs.

```shell
wget http://openvswitch.org/releases/openvswitch-2.7.0.tar.gz
tar xf openvswitch-2.7.0.tar.gz
patch openvswitch-2.7.0/rhel/openvswitch.spec openvswitch_stech_5-5-2017.patch
cp ./openvswitch-2.7.0.tar.gz ~/rpmbuild/SOURCES/
rpmbuild -bb openvswitch-2.7.0/rhel/openvswitch.spec
cp ~/rpmbuild/RPMS/x86_64/openvswitch-*.rpm .
```


#### BUILDING CNI PLUGINS and RPM

##### Build Multus
---
git clone https://github.com/Intel-Corp/multus-cni.git
cd ./multus-cni
./build.sh

##### Build SR-IOV Plugin
---
git clone https://github.com/Intel-Corp/sriov-cni.git
cd ./sriov-cni
./build.sh

##### Build Standard CNI Plugin Set
---
git clone https://github.com/containernetworking/plugins.git
cd ./plugins
./build.sh

##### Build OVS-CNI
---
mkdir -p ~/go/src/github.com/John-Lin/
cd ~/go/src/github.com/John-Lin/
git clone https://github.com/John-Lin/ovs-cni.git
cd ./ovs-cni
go get -u github.com/kardianos/govendor
govendor sync
/home/admin/go/bin/govendor sync
./build.sh
