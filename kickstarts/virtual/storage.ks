clearpart --all --initlabel --drives=vda
bootloader --append=" crashkernel=auto biosdevname=0 net.ifnames=0 --location=mbr --boot-drive=vda"

part /boot --size=200 --fstype=xfs --asprimary
part biosboot --fstype=biosboot --size=1
part pv.os --size=3000 --fstype=xfs --grow --asprimary

volgroup vg00 pv.os
logvol /              --vgname=vg00 --name=root  --fstype=xfs --size 5500 --maxsize 21000 --grow
logvol /var           --vgname=vg00 --name=var   --fstype=xfs --size 4000 --grow
logvol /home          --vgname=vg00 --name=home  --fstype=xfs --size 1000 --grow
logvol /var/log       --vgname=vg00 --name=log   --fstype=xfs --size 1500 --maxsize 25000 --grow
logvol /var/log/audit --vgname=vg00 --name=audit --fstype=xfs --size 1500 --maxsize 25000 --grow
logvol /tmp           --vgname=vg00 --name=tmp   --fstype=xfs --size 100 --maxsize 6000  --grow

