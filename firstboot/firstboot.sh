#!/bin/bash

source /EDCOP/vars

function ping_gw() {
echo "Checking for Network Connection..."
((count = 100))                            # Maximum number to try.
while [[ $count -ne 0 ]] ; do
    ping -q -w 1 -c 1 8.8.8.8                      # Try once.
    rc=$?
    if [[ $rc -eq 0 ]] ; then
        ((count = 1))                      # If okay, flag to exit loop.
    fi
    ((count = count - 1))                  # So we don't go forever.
done

if [[ $rc -eq 0 ]] ; then                  # Make final determination.
    echo 'OK'
else
    echo 'ERROR: Could not establish internet connection!'
    exit 1
fi

}

# Increase VM max map count & disable swap
sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
systemctl disable EDCOP-firstboot
systemctl start cockpit

#gunzip -c /EDCOP/images/docker-registry.tar.gz | docker load
#for i in $(find /EDCOP/images/edcop-master/ -type f -name *.gz);do gunzip -c $i | docker load; done
#docker run -d -p 5000:5000 --restart=always --name edcop-registry registry:2

# No need for external connectivity. Using offline images for cluster.
ping_gw || (echo "Script can not start with no internet" && exit 1)

#
# Create token for cluster. Initialize Kubernetes Cluster with specific version.
# Token is applied permenantly so that minions can always join cluster.
#

token=$(kubeadm token generate)
sleep 30
kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version 1.10.2 --token $token --token-ttl 0

#
# Apply the token and PXEboot IP address to the minion kickstart
# 

interface=$(route | grep default | awk '{print $8}')
IP=$(ip addr show dev $interface | awk '$1 == "inet" { sub("/.*", "", $2); print $2 }')
#TESTHOSTNAME=(`hostname -A`)
#if [[ ${TESTHOSTNAME[0]} = "localhost.localdomain" ]]
#then
#HOSTNAME="edcop-master.local"
#else
#HOSTNAME=${TESTHOSTNAME[0]}
#fi

sed -i --follow-symlinks "s/<insert-token>/$token/g" /EDCOP/pxe/deploy/ks/minion/main.ks
sed -i --follow-symlinks "s/<insert-master-ip>/$MASTERIP/g" /EDCOP/pxe/deploy/ks/minion/main.ks

sed -i --follow-symlinks "s/<insert-fqdn>/$HOSTNAME/g" /etc/cockpit/cockpit.conf
sed -i --follow-symlinks "s/<insert-fqdn>/$HOSTNAME/g" /EDCOP/kubernetes/platform-apps/cockpit.yaml
sed -i --follow-symlinks "s/<insert-master-ip>/$MASTERIP/g" /EDCOP/kubernetes/platform-apps/cockpit.yaml
sed -i --follow-symlinks "s/<insert-fqdn>/$HOSTNAME/g" /EDCOP/kubernetes/platform-apps/kubernetes-dashboard-http.yaml
sed -i --follow-symlinks "s/<insert-fqdn>/$HOSTNAME/g" /EDCOP/kubernetes/ingress/traefik-ingress-controller.yaml
sed -i --follow-symlinks "s/<insert-fqdn>/$HOSTNAME/g" /EDCOP/kubernetes/platform-apps/kubeapps.yaml
#
# Copy configuration file to root's home directory. Add to minion deployment
# This ensures that "kubectl" commands can be run by root on all systems
#
mkdir /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
cp /etc/kubernetes/admin.conf /EDCOP/pxe/deploy/EXTRAS/kubernetes/config
chmod 644 /EDCOP/pxe/deploy/EXTRAS/kubernetes/config

# 
# Label the first node as 'master'.
# Taint master node so containers can be run on the master
# Add "nodetype=master" annotation to yaml files to schedule pods on the master server (e.g. ElasticSearch index)
#
kubectl label nodes $(hostname | awk '{print tolower($0)}') nodetype=master --overwrite
kubectl taint nodes $(hostname | awk '{print tolower($0)}') node-role.kubernetes.io/master:NoSchedule-

#
# Create Multus/Calico network and Multus/OVS network.
# This creates a Layer-3 mesh network between all nodes/containers
#
kubectl apply --token $token -f /EDCOP/kubernetes/networks/calico-multus-etcd.yaml
kubectl apply --token $token -f /EDCOP/kubernetes/networks/crdnetwork.yaml
kubectl apply --token $token -f /EDCOP/kubernetes/networks/ovs-network.yaml

# We need to wait for the calico configuration to finish so we can read the contents of the config file
while [ ! -f /etc/cni/net.d/10-multus.conf ]
do
  sleep 2
done
cat <<EOF | tee /EDCOP/kubernetes/networks/calico-network.yaml
apiVersion: "kubernetes.com/v1"
kind: Network
metadata:
  name: calico
plugin: calico
args: '[
$(cat /etc/cni/net.d/10-multus.conf | jq .delegates[0])
       ]'
EOF

kubectl apply --token $token -f /EDCOP/kubernetes/networks/calico-network.yaml

#
# Implement kubevirt 0.4.0 for testing
#
kubectl apply --token $token -f /EDCOP/kubernetes/platform-apps/kubevirt.yaml

#
# Initiate helm on cluster
#
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
/usr/local/bin/helm init --service-account tiller

#
# Apply Ingress Controller
#
kubectl create secret tls edcop-tls --key=/etc/pki/tls/private/server.key --cert=/etc/pki/tls/certs/server.crt -n kube-system
kubectl apply --token $token -f /EDCOP/kubernetes/ingress/traefik-ingress-controller.yaml

#
# Initial Persistent Volume based on the NFS server
#
kubectl label node $(hostname | awk '{print tolower($0)}') edcop.io/nfs-storage=true
kubectl apply --token $token -f /EDCOP/kubernetes/storage/nfs-provisioner.yaml


#
# Create the Kubernetes Dashboard (already in nginx proxy as https://<master-ip>/dashboard)
#
kubectl apply --token $token -f /EDCOP/kubernetes/platform-apps/kubernetes-dashboard-http.yaml

#
# Apply ingress rules for cockpit
#
kubectl apply --token $token -f /EDCOP/kubernetes/platform-apps/cockpit.yaml

#
# Apply KubeApps Dashboard
#
kubectl apply --token $token -f /EDCOP/kubernetes/platform-apps/kubeapps.yaml


