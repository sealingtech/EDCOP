%post --nochroot --log=/mnt/sysimage/root/EDCOP_post_nochroot.log
mkdir -p /mnt/sysimage/EDCOP/pxe/{deploy,pxelinux.cfg}
mkdir -p /mnt/sysimage/EDCOP/{images,kube-network}
mkdir -p /mnt/sysimage/opt/cni/bin
mkdir -p /mnt/sysimage/etc/cni/net.d/

cp /tmp/vars /mnt/sysimage/EDCOP
cp -r /mnt/sysimage/usr/share/syslinux/* /mnt/sysimage/EDCOP/pxe/
cp -r /run/install/repo/* /mnt/sysimage/EDCOP/pxe/deploy
cp -f /run/install/repo/EXTRAS/default-virtual /mnt/sysimage/EDCOP/pxe/pxelinux.cfg/default
cp -f /run/install/repo/EXTRAS/firstboot/firstboot-virtual.sh /mnt/sysimage/root/firstboot.sh
cp -f /run/install/repo/EXTRAS/docker-images/*.gz /mnt/sysimage/EDCOP/images/
cp -f /run/install/repo/EXTRAS/nginx/nginx.conf /mnt/sysimage/etc/nginx/nginx.conf
cp -f /run/install/repo/EXTRAS/nginx/proxy.conf /mnt/sysimage/etc/nginx/conf.d/proxy.conf
cp -f /run/install/repo/EXTRAS/kube-network/* /mnt/sysimage/EDCOP/kube-network/
cp -f /run/install/repo/EXTRAS/multus-bins/* /mnt/sysimage/opt/cni/bin

%end

