# EDCOP Master Images
---
An EDCOP Master Server requires the initial kubernetes images to start the cluster. This folder contains the necessary files to build an RPM containing those images

## Downloading and Preping the images
---
The system that you are building edcop-master-images on must have Docker installed.

Tag the Docker images and create a tarball of the image with the following commands:
```shell
mkdir ~/edcop-master

docker save gcr.io/google_containers/kube-apiserver-amd64:v1.8.4 | gzip > ~/edcop-master/kube-apiserver-amd64_v1.8.4.tar.gz
docker save gcr.io/google_containers/kube-controller-manager-amd64:v1.8.4 | gzip > ~/edcop-master/kube-controller-manager-amd64_v1.8.4.tar.gz
docker save gcr.io/google_containers/kube-scheduler-amd64:v1.8.4 | gzip > ~/edcop-master/kube-scheduler-amd64_v1.8.4.tar.gz
docker save gcr.io/google_containers/kube-proxy-amd64:v1.8.4 | gzip > ~/edcop-master/kube-proxy-amd64_v1.8.4.tar.gz
docker save quay.io/coreos/flannel:v0.9.1-amd64 | gzip > ~/edcop-master/flannel_v0.9.1-amd64.tar.gz
docker save gcr.io/google_containers/kubernetes-dashboard-amd64:v1.7.1 | gzip > ~/edcop-master/kubernetes-dashboard-amd64_v1.7.1.tar.gz
docker save gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.5 | gzip > ~/edcop-master/k8s-dns-sidecar-amd64_1.14.5.tar.gz
docker save gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.5 | gzip > ~/edcop-master/k8s-dns-kube-dns-amd64_1.14.5.tar.gz
docker save gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.5 | gzip > ~/edcop-master/k8s-dns-dnsmasq-nanny-amd64_1.14.5.tar.gz
docker save gcr.io/google_containers/etcd-amd64:3.0.17 | gzip > ~/edcop-master/etcd-amd64_3.0.17.tar.gz
docker save gcr.io/google_containers/pause-amd64:3.0 | gzip > ~/edcop-master/pause-amd64_3.0.tar.gz

tar czf edcop-images.tar.gz edcop-master/
```
Move "edcop-images.tar.gz" to your SOURCES directory for RPM building

## Building the RPM
---
```shell
rpm -bb edcop-master-images.spec
```
