# EDCOP
The Expandable Defensive Cyber Operations Platform
---
**NOTE:**  This is still in the prototype phase.  While the tools work, there are some growing pains as well as known and possibly unknown defects.  

EDCOP is a bootable ISO based on Centos 7.  EDCOP will install all the necessary components required for deploying EDCOP-Tools from a repository. (Source for the open-source tools available seperately here: https://github.com/sealingtech/EDCOP-TOOLS).


## Overview
---
The EDCOP is a scalable cluster to deploy virtual network defense tools on. It is designed to install a kubernetes cluster that is purpose-built to deploy and manager tools for Defensive Cyber Operations (DCO), although it could be used for any NFVi or standared application. 

![EDCOP Architecture](https://github.com/sealingtech/EDCOP/raw/master/docs/images/stacked_platform_concept.png)

## Quickstart
---
For the more adventurous, you can [download the latest release installation ISO](https://github.com/sealingtech/EDCOP/releases/download/0.9.1/EDCOP-0.9.1.iso), and give it a try (we'd love the feedback).

To build the ISO, simply clone the repo and run `make iso` (requires docker on the host system and ~10GB free space). Validated on Mac, CentOS, and Ubuntu.

```shell
git clone https://github.com/sealingtech/EDCOP.git
make iso
```
This will create the docker build container and build the installer ISO from online.

If successful, you should have a file called "EDCOP-dev.iso" in your folder.

The system is installed with the following default UN/PW:

**Default Username:** root

**Default Password:** open.local.box

## Installation
Deploying EDCOP first involves booting the ISO and running the install setup on the master node.  Once this is complete, minions can be automatically built over the network through PXE services.

### Hardware Pre-Requisites
The EDCOP installer has been tested on both physical and VMs, however it expects a minimum amount of resources on both the Master server and Minions. At this time, the **Master and Minion must have the same hardware specs**.

| Resource                 | Minimum Spec  |
| ------------------------ |:-------------:|
| CPU                      | 4 cores       |
| Memory                   | 8 GB          |
| Harddrive 1 (OS)         | 80 GB         |
| Harddrive 2 (Data)       | 300 GB        |
| Network Interfaces       | 2 NICs        |



After booting from the install disk, you'll be asked a series of questions to set the Network and Storage:

![Install Prompt](https://github.com/sealingtech/EDCOP/raw/master/docs/images/installation_prompt.png)

### Network Settings:

+ **Enter hostname (entire FQDN):**

   EDCOP requires a FQDN and corresponding DNS entry (e.g. "edcop.example.com" or "dev.edcop.io"). After installation, you must access the Admin panel with the FQDN (not IP address).

+ **TEAM the network interfaces on Master? (Y/N):**

   For large clusters, it's recommended to team multiple interfaces (if testing in VMs, recommend answering **_N_**). Answering **_Y_** will use LACP to team the provided interfaces, which must be configured on the switch as well. The new interface will be called "team0".

+ **Enter CLUSTER Interface:**

   If you answer **_N_** to the teaming, you must enter an interface to communicate with the rest of the cluster.

+ **Would you like to set the CLUSTER interface for DHCP? (Y/N)**

   You can set the CLUSTER interface for DHCP, however remember that this required a corresponding DNS entry. If answering _**N**_ you'll be prompted for IP Address, Netmask, Gateway, and DNS. 

+ **Enter PXE-Server Interface:**

   EDCOP installs a PXEboot server on the Master server that allows for auto-installing the minions. The PXE-interface should be on a separate network/vlan. This network should have no DHCP servers on it (the master will start a DHCP server for PXE).
   
+ **Enter PXE-Server IP Address:**

   Since this is on closed network, any IP address should work (e.g. 10.50.50.10)
   
+ **Enter PXE-Server Netmask:**

   Ensure a large enough network to cover all minions/nodes to be installed.
   
+ **Enter last octet of DHCP starting IP:**

   Enter only the last octet for the DHCP server, for example _**100**_

+ **Enter last octet of DHCP ending IP:**

   Enter only the last octet for the DHCP server, for example entering _**150**_ will give you 51 IP addresses for the PXEboot server

### Storage Settings:

At this time, EDCOP allows for an OS disk and a DATA disk. The installation will show the device-id (e.g. sda or sdb) and the corresponding size. Follow the instructions to select which disk is for the OS and which is for the DATA (such as ElasticSearch event storage)

## Using EDCOP

The system is installed with the following default UN/PW:

**Default Username:** root

**Default Password:** open.local.box

After installation, EDCOP runs a service called "EDCOP-firstboot" to finish installing kubernetes, calico, multus, and the other internal cluster components. For normal operations, this requires internet access (a completely offline installer is in development). The service will attempt to ping 8.8.8.8 to verify internet connectivity. If no connectivity is found, the service will fail.

You can validate the service is running with: `systemctl status EDCOP-firstboot`

Once the service has finished installing everything, the follwing URLs can be accessed:

| URL                         | Role                         |
| --------------------------- |:----------------------------:|
| https://\<fqdn\>/admin        | Cockpit Admin Panel        |
| https://\<fqdn\>/kubernetes-ui|Kubernetes Dashboard        |
| https://\<fqdn\>/loadbalancer |Traefik Ingress Loadbalancer|
| https://apps.\<fqdn\>         |Kubeapps DCO deployment UI  |

EDCOP uses [Cockpit ](https://github.com/cockpit-project/cockpit) for server/cluster administration. Login with the UN/PW shown above. 

## Building all required packages
---
The Makefile and Dockerfile pull the necessary RPM packages from both CentOS and EDCOP repos. If you want to build/update the RPMs yourself, you can use the steps outlined in build-packages.md.

