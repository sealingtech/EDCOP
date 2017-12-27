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


systemctl disable EDCOP-firstboot
systemctl start cockpit

#for i in $(find /EDCOP/images/ -type f -name *.gz);do gunzip -c $i | docker load; done

ping_gw || (echo "Script can not start with no internet" && exit 1)

token=$(kubeadm token generate)

kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version 1.8.4 --token $token --token-ttl 0

sed -i --follow-symlinks "s/<insert-token>/$token/g" /EDCOP/pxe/deploy/ks/virtual/minion/main.ks

interface=$(route | grep default | awk '{print $8}')

IP=$(ip addr show dev $interface | awk '$1 == "inet" { sub("/.*", "", $2); print $2 }')

sed -i --follow-symlinks "s/<insert-master-ip>/$IP/g" /EDCOP/pxe/deploy/ks/virtual/minion/main.ks

mkdir /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
cp /etc/kubernetes/admin.conf /EDCOP/pxe/deploy/EXTRAS/kubernetes/config
chmod 644 /EDCOP/pxe/deploy/EXTRAS/kubernetes/config

kubectl apply --token $token -f /EDCOP/kubernetes/networks/crdnetwork.yaml
kubectl apply --token $token -f /EDCOP/kubernetes/networks/kube-multus.yaml
kubectl apply --token $token -f /EDCOP/kubernetes/networks/flannel-network.yaml
kubectl apply --token $token -f /EDCOP/kubernetes/networks/ovs-network.yaml
kubectl apply --token $token -f /EDCOP/kubernetes/kubernetes-dashboard-http.yaml 

#rm -rf /EDCOP/images

