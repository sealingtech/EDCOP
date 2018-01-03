# EDCOP Registry
---
An EDCOP Master Server hosts a registry where the tools reside. This folder contains the necessary files to build an RPM containing that registry.

## Downloading and Preping the registry
---
The system that you are building edcop-registry on must have Docker installed.

Pull the Docker registry and created a tarball of the image with the following commands:
```shell
docker pull registry:2
docker save registry:2 | gzip > ~/docker-registry.tar.gz
```
## Building the RPM
---
```shell
rpm -bb edcop-registry.spec
```
