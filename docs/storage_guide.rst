#############
Storage Guide
#############

EDCOP uses shared storage technologies on all nodes labelled as "data".  It is critical to treat these systems with care to ensure data isn't lost.  EDCOP uses a tool called Rook which utilizes Ceph inside of the cluster as well as Elasticsearch to store data across all the nodes.

Elasticsearch Architecture
==========================

Understanding deployment.  Elasticsearch uses a Kubernetes structure called "stateful sets"  This ensures that when pods restart they hostname and IPs are kept consistent.  Each physical node can only host a single Elasticsearch pod at a time.  Data is stored locally  by default on each host in the directory: /EDCOP/bulk/esdata/.

This value can be changed in the Helm values if desired below.  This could be useful if it was desired to place this data on faster storage.  

.. code-block:: bash

  volumes:
    # Persistent data location on the host to store Elasticsearch's data
    data: /EDCOP/bulk/esdata

If the path is changed, it is necessary to change the ownership of the directory on every host to be owned by elasticsearch:elasticsearch.

To change ownership run the command:

.. code-block:: bash
  
  chown -R elasticsearch:elasticsearch <path to new ES directory>


To change location to store Elasticsearch:

.. code-block:: bash

volumes:
  # Persistent data location on the host to store Elasticsearch's data
  data: /EDCOP/bulk/esdata

Understanding pod counts
------------------------

When first deploying Elasticsearch, the default is to deploy a single master node and 0 worker nodes, which means only a single pod will be deployed which takes the master role.  It is possible to have multiple masters as well as multiple workers.  In larger clusters it is reccomended to deploy 3 or more masters (always and odd number) and worker nodes to match the remaining number of data nodes in your cluster.  For example, if you have 10 data nodes you would deploy 3 masters and seven workers.  

In the values file when deployed you can set the number of workernodes and master nodes in the configuration.

.. code-block:: bash

  elasticsearchConfig:
    # runAsUser refers to the UID of the user who owns the persistent data location specified above
    runAsUser: 2000
    # Nodes refers to the number of worker nodes you have
    # NOTE: If you have a one-node cluster, set workerNodes to '0' and master.data to 'true'
    workerNodes: 2
    master:
      # Nodes refers to the number of master nodes you have
      nodes: 1
      # Set to 'true' to enable data to be stored on master node
      data: true


Once deployed, it is possible to increase the number of replicas at any time from the command line.

To view the number of workers and master run the command kubectl get statefulset to view the desired number of master and worker nodes.  Below we can see that there is one desired master node and currently there is one deployed.

.. code-block:: bash

  [root@virtual ~]# kubectl get statefulset
  NAME                                         DESIRED   CURRENT   AGE
  default-elastic-elasticsearch-master         1         1         7d
  default-elasticsearch-elasticsearch          0         0         7d


To scale additional worker nodes run the command:

.. code-block:: bash

  kubectl scale --replicas=<number of desired pods> default-elasticsearch-elasticsearch

To scale additional master nodes run the command:

.. code-block:: bash

  kubectl scale --replicas=<number of desired pods> default-elastic-elasticsearch-master 

Once this command is run the desired number of pods will immediately be increased to the number replicas set, the current pods will slowly increment by one over time until it matches the desired number.  Ensure that you never increase the total replicas past the number of physical nodes you have configured otherwise an error will occur.  After all changes to the cluster, go to the Kibana console and ensure the Elasticsearch health is "green" in the monitoring tab before making additional changes.

Scaling down replicas is more challenging.  It is necessary to scale down a single node at a time then wait until the cluster is green again and continue.


https://www.elastic.co/blog/how-many-shards-should-i-have-in-my-elasticsearch-cluster



If it is necessary to reboot a physical node on the cluster, it is best to disable allocation.  If this option is not set, the cluster will attempt to reallocate all the data off of that failed node which will consume a considerable amount of resources.

To perform the procedure from the master node, get the IP address of the data-service:


.. code-block:: bash

  [root@virtual ~]# kubectl get service
  NAME                               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                        AGE
  data-service                       ClusterIP   10.111.51.141    <none>        9200/TCP,9300/TCP                              49m

The disable allocation with the following command:

.. code-block:: bash

  curl -X PUT "<ip of the data-service>:9200/_cluster/settings" -H 'Content-Type: application/json' -d'
  {
    "persistent": {
      "cluster.routing.allocation.enable": "none"
    }
  }
  '

Once the node has been rebooted and maintenence is completed ensure that the pod is running again on the node that was rebooted.

.. code-block:: bash

  [root@virtual ~]# kubectl get pods -o wide
  NAME                                           READY     STATUS              RESTARTS   AGE       IP               NODE
  default-elasticsearch-elasticsearch-master-0   1/1       Running             0          55m       10.244.184.149   virtual.edcop.io


Re-enable cluster allocation with the following command:


.. code-block:: bash

  curl -X PUT "<ip of the data-service>:9200/_cluster/settings" -H 'Content-Type: application/json' -d'
  {
    "persistent": {
      "cluster.routing.allocation.enable": null
    }
  }
  '

Monitor Kibana to ensure the cluster goes from green to yellow after a time period before making additional changes.


Elasticsearch Upgrade Procedure
-------------------------------



Elasticsearch Resource Optimization
-----------------------------------






Rook Architecture
=================

Talk about monitoring, how to scale, etc.







