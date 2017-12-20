# EDCOP CNI Plugins
This directory is used to hold CNI plugins required for the EDCOP RPM.

*Standard CNI Plugins
*Multus
*SRIOV
*OVS-CNI

The necessary plugins must be built outside of this source-code and placed in this directory.

## Instructions for building the plugins

Build Multus
-------------
git clone https://github.com/Intel-Corp/multus-cni.git
cd ./multus-cni
./build.sh

Build SR-IOV Plugin
-------------------
git clone https://github.com/Intel-Corp/sriov-cni.git
cd ./sriov-cni
./build.sh

Build Standard CNI Plugin Set
-----------------------------
git clone https://github.com/containernetworking/plugins.git
cd ./plugins
./build.sh

Build OVS-CNI
-------------
mkdir -p ~/go/src/github.com/John-Lin/
cd ~/go/src/github.com/John-Lin/
git clone https://github.com/John-Lin/ovs-cni.git
cd ./ovs-cni
go get -u github.com/kardianos/govendor
govendor sync
/home/admin/go/bin/govendor sync
./build.sh

