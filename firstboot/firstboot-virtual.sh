#!/bin/bash

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
    echo `OK`
else
    echo `ERROR: Could not establish internet connection!`
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
docker run -d -p 5000:5000 --restart=always --name edcop-registry registry:2

# No need for external connectivity. Using offline images for cluster.
ping_gw || (echo "Script can not start with no internet" && exit 1)

token=$(kubeadm token generate)

kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version 1.10.0 --token $token --token-ttl 0

sed -i --follow-symlinks "s/<insert-token>/$token/g" /EDCOP/pxe/deploy/ks/virtual/minion/main.ks

interface=$(route | grep default | awk '{print $8}')

IP=$(ip addr show dev $interface | awk '$1 == "inet" { sub("/.*", "", $2); print $2 }')

sed -i --follow-symlinks "s/<insert-master-ip>/$IP/g" /EDCOP/pxe/deploy/ks/virtual/minion/main.ks

mkdir /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
cp /etc/kubernetes/admin.conf /EDCOP/pxe/deploy/EXTRAS/kubernetes/config
chmod 644 /EDCOP/pxe/deploy/EXTRAS/kubernetes/config

kubectl apply --token $token -f /EDCOP/kubernetes/networks/calico-multus-etcd.yaml
kubectl apply --token $token -f /EDCOP/kubernetes/networks/crdnetwork.yaml
kubectl apply --token $token -f /EDCOP/kubernetes/networks/ovs-network.yaml
kubectl apply --token $token -f /EDCOP/kubernetes/kubernetes-dashboard-http.yaml 
kubectl apply --token $token -f /EDCOP/kubernetes/traefik-ingress-controller.yaml
kubectl label nodes $(hostname | awk '{print tolower($0)}') nodetype=master --overwrite
kubectl taint nodes $(hostname | awk '{print tolower($0)}') node-role.kubernetes.io/master:NoSchedule-

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

# Implement kubevirt 0.4.0 for testing
kubectl apply --token $token -f /EDCOP/kubernetes/kubevirt.yaml
#rm -rf /EDCOP/images

