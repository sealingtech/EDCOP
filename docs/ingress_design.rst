
####################
EDCOP Ingress Design
####################

By default it is not possible to communicate with services internal to the cluster from outside of the cluster..  To communicate with services inside the cluster two methods are used.  ![Traefik](https://traefik.io) provides access to all web services over https and nodeports provide access to all non-web services.  It is important to understand some of these concepts for deploying applications as well as designing scalable solutions.


#######
Traefik
#######

Traefik is deployed on all nodes including the masterin EDCOP.  This means that if a web request comes in to any node the traffic will be forwarded to the proper location inside of the cluster regardless of which host the service is running on.  Traefik terminates SSL and uses a certificate called edcop-wild that is created when you install.  When new capabilities are deployed an ingress is created which is how Traefik know where to send traffic.  Treafik uses ![SNI]() https://en.wikipedia.org/wiki/Server_Name_Indication) which means that users must browse to websites using the domain name and on the IP address.  The purpose of the wild card DNS entry is to make sure that all requests to a specific sub-domain is forwarded to traefik so that it can figure out where to send data.

In smaller deployments you can point these DNS records to the master.  In larger deployments this can become an issue as all traffic is being processed by the master node.  A more scalable option is to use a network load balancer which forwards network traffic to all nodes (master and minions).  This serves to spread the load of this traffic as well as provides redundancy in case a node fails.  In this situation, the wild card DNS entry must be pointed at the load balancer IP.  

When configuring any charts with an ingress (such as Kibana), it is important to look for the value host and change this value to any subdomain under the FQDN value you selected when you built the cluster.  If this option is not selected then the default value will be deployed incorrectly.  Once deployed and the service is up, it is possible to browse to this host name.

To view Traefik ingresses, browse to loadbalancer.<fqdn> where you can view all current ingresses as well as view their status.  From the console it is possible to run the command from the command line.

.. code-block:: bash
  
  kubectl get ingress --all-namespaces



########
NodePort
########

NodePort services traffic for all non web traffic.  NodePorts instruct kube-proxy which lives on every node to forward traffic to the proper location inside of the cluster.  Nodeports are a port number between 30,000 and 32,767.  When deploying capabilities (such as ingress) containing node ports set the port number to a unique number.  To view current node ports from the command line use the following command:

.. code-block:: bash

  kubectl get service --all-namespaces | grep NodePort

Traffic can be load balanced here if desired using an external load balancer or it is possible to point clients to specific nodes and spread out the traffic in the way.


  

