# EDCOP
The Expandable Defensive Cyber Operations Platform
---
**NOTE:**  This is still in the prototype phase.  While the tools work, there are some growing pains as well as known and possibly unknown defects.  

EDCOP is a bootable ISO based on Centos 7.  EDCOP will install all the necessary components required for deploying EDCOP-Tools from a repository. Current Tools that are supported natively (linked to associated GitHub repos):
+ [Suricata IDS/IPS](https://github.com/sealingtech/EDCOP-SURICATA)
+ [Bro NSM/IDS](https://github.com/sealingtech/EDCOP-BRO)
+ [Moloch Full-PCAP](https://github.com/sealingtech/EDCOP-MOLOCH)
+ [ElasticSearch](https://github.com/sealingtech/EDCOP-ELASTICSEARCH)
+ [ElasticSearch XPACK](https://github.com/sealingtech/EDCOP-XPACK)
+ [Kibana](https://github.com/sealingtech/EDCOP-KIBANA)

Checkout this quick feature demo of EDCOP:

[![EDCOP Feature Demo](https://github.com/sealingtech/EDCOP/raw/master/docs/images/youtube_video.png)](https://www.youtube.com/watch?v=k6DARQP9CXo)

## Overview
---
The EDCOP is a scalable cluster to deploy virtual network defense tools on. It is designed to install a kubernetes cluster that is purpose-built to deploy and manage tools for Defensive Cyber Operations (DCO), although it could be used for any NFVi or standard application. 

![EDCOP Architecture](https://github.com/sealingtech/EDCOP/raw/master/docs/images/stacked_platform_concept.png)

EDCOP is designed to be a platform to deploy any CND tools.  Once deployed you will have Bro, Suricata, ELK stack and other tools made available to you.  Each tool has a seperate Github repository viewable here:
https://github.com/sealingtech/

EDCOP is designed to work in a number of deployment scenarios including a single physical system as well as large cluster with a traffic load balancer.

Installation takes place by building a "master" node which is then used to build more "minion" nodes.  Once this process is completed then it is possible to deploy tools in a scalable fashion.  


![Installation instructions are located here](https://github.com/sealingtech/EDCOP/blob/master/docs/installation_guide.rst)


