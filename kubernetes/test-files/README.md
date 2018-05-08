Test Containers/VMs
===================
This folder contains a few scripts that are helpful for testing the EDCOP environment.

netdiag-deployment.yaml: 
------------------------

The NetDiag Pod contains a few network test tools such as iperf. This is helpful to ensure inter-node communication is working
and that the CNIs have initialized correctly. To see the interpod throughput, you can run iperf between the two containers that
are deployed as part of the netdiag-deployment.yaml deployment.

POD1: `iperf -s`
POD2: `iperf -c <pod1 eth0 ip address>`

VM Testing:
-----------
Although support for VMs is still a "Preview" feature, we've included a few scripts that can be used for testing it.

small-size.yaml: Presets the size for a "small" type VM. Provides 1 CPU core, 256M memory.

large-size.yamlPresets the size for a "large" type VM. Provides 2 CPU cores, 16G memory.

vm.yaml: Deploys a cirros VM to a node.

windows-vm.yaml: Deploys a Windows VM (if available in the registry)

(NOTE: We are not authorized to distribute Windows VMs at this time. These may be downloaded from: https://cloudbase.it/windows-cloud-images/)
To import the VM image:
```
cat <<EOF | tee ./Dockerfile
FROM kubevirt/registry-disk-v1alpha
ADD windows_server_2012_r2_standard_eval_kvm_20170321.qcow2 /disk
EOF
docker build -t windows-2012r2:latest 
```
