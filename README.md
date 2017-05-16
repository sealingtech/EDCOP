# EDCOP
The Expandable Defensive Cyber Operations Platform

## Overview
---
The EDCOP is a platform to deploy virtual network defense tools on.

## Build Requirements
---
EDCOP requires the following items to build:
*Centos 7.3 ISO (build 1611)
*openvswitch RPM
*openvswitch-devel RPM
*dpdk-stable RPM
*dpdk-stable-devel RPM

The following sections will walk trhough building the DPDK and Openvswitch RPM packages.

### Install Build Dependencies
---

```shell
yum install net-tools mlocate vim git epel-release wget patch rpm-build gcc openssl-devel checkpolicy selinux-policy-devel htop kernel-devel doxygen python-six libcap-ng-devel isomd5sum syslinux gcc createrepo mkisofs yum-utils
```

### Building DPDK Packages
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


### Building OpenvSwitch Packages
---
The following script will build OpenvSwitch 2.7.0 RPMs.

```shell
wget http://openvswitch.org/releases/openvswitch-2.7.0.tar.gz
tar xf openvswitch-2.7.0.tar.gz
patch openvswitch-2.7.0/rhel/openvswitch.spec openvswitch_stech_5-5-2017.patch
cp ./openvswitch-2.7.0.tar.gz ~/rpmbuild/SOURCES/
rpmbuild -bb openvswitch-2.7.0/rhel/openvswitch.spec
cp ~/rpmbuild/RPMS/x86_64/openvswitch-*.rpm .
yum localinstall ./openvswitch-2.7.0.x86_64.rpm ./openvswitch-devel-2.7.0.x86_64.rpm
```

Assuming everything worked, copy all RPMs to a central folder.

### Building the EDCOP ISO
---

Mount the CentOS 7.3 ISO in the '/mnt' directory:
```shell
mount ./CentOS-7-x86_64-DVD-1611.iso /mnt
```

Build the ISO environment
```shell
./configure-build-image.sh
```

Copy all of the openvswitch and dpdk RPMs into the packages directory
```shell
cp ./RPMs/*.rpm ~/build/isolinux/Packages/
```

Run the build script to create the ISO and place it in your current directory
```shell
./build-image.sh
```


