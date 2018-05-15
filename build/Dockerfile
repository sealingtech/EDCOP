FROM centos:7.4.1708

RUN yum -y --disablerepo=* --enablerepo=base --enablerepo=extras --enablerepo=updates install epel-release wget isomd5sum createrepo mkisofs yum-utils mtools dosfstools syslinux

RUN rpm -ivh http://repos.sealingtech.org/edcop/edcop-repo-1-0.noarch.rpm

COPY . /EDCOP

RUN cd /EDCOP/build && ./online-configure.sh && ./build-image.sh && rm -rf ~/build
