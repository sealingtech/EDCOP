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
For the more adventurous, you can download the latest release installation ISO, and give it a try (we'd love the feedback).

To build the ISO, simply clone the repo and run `make iso` (requires docker on the host system and ~10GB free space). Validated on Mac, CentOS, and Ubuntu.

```shell
git clone https://github.com/sealingtech/EDCOP.git
make iso
```
This will create the docker build container and build the installer ISO from online. 
If successful, you should have a file called "EDCOP-dev.iso" in your folder.

## Installation
Deploying EDCOP first involves booting the ISO and running the install setup on the master node.  Once this is complete, minions can be automatically built over the network through PXE services.

## Building all required packages
---
The Makefile and Dockerfile pull the necessary RPM packages from both CentOS and EDCOP repos. If you want to build/update the RPMs yourself, you can use the steps outlined in build-packages.md.

