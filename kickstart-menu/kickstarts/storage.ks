bootloader --append=\crashkernel=auto --location=mbr --boot-drive={{ data.storage_os._disk[0] }} intel_iommu=on iommu=pt default_hugepagesz=2M hugepagesz=2M hugepages=2048\

{% if data.storage_fast._disk != None and data.storage_bulk._disk != None and data.storage_shared._disk != None %}
{# if If Base OS, Bulk, Fast, and Shared storgage drives are defined #}
clearpart --all --initlabel --drives={{ data.storage_os._disk[0] }},{{ data.storage_bulk._disk[0] }},{{ data.storage_fast._disk[0] }}
part /boot --size=500 --fstype=xfs --asprimary --ondisk {{ data.storage_os._disk[0] }}
part /boot/efi --fstype=efi --size=500 --asprimary --ondisk {{ data.storage_os._disk[0] }}
part pv.os --size=13000 --fstype=xfs --grow --asprimary --ondisk {{ data.storage_os._disk[0] }}
volgroup vg00 pv.os
logvol /              --vgname=vg00 --name=root  --fstype=xfs --size 10000 --maxsize 50000 --grow
logvol /home          --vgname=vg00 --name=home  --fstype=xfs --size 1000 --maxsize 10000 --grow
logvol /var/log       --vgname=vg00 --name=log   --fstype=xfs --size 1500 --maxsize 25000 --grow
logvol /tmp           --vgname=vg00 --name=tmp   --fstype=xfs --size 500 --maxsize 6000  --grow
part pv.bulk --size=1000 --fstype=xfs --grow --asprimary --ondisk {{ data.storage_bulk._disk[0] }}
volgroup vg01 pv.bulk
logvol /EDCOP/bulk    --vgname=vg01 --name=bulk  --fstype=xfs --size 1000 --grow
part pv.fast --size=1000 --fstype=xfs --grow --asprimary --ondisk {{ data.storage_fast._disk[0] }}
volgroup vg02 pv.fast
logvol /EDCOP/fast    --vgname=vg02 --name=bulk  --fstype=xfs --size 1000 --grow
part pv.share --size=1000 --fstype=xfs --grow --asprimary --ondisk {{ data.storage_shared._disk[0] }}
volgroup vg03 pv.share
logvol /EDCOP/shared    --vgname=vg03 --name=bulk  --fstype=xfs --size 1000 --grow 

{% else %}
{# if {$OSDRIVE} is only thing defined: #}
clearpart --all --initlabel --drives={{ data.storage_os._disk[0] }}
part /boot --size=500 --fstype=xfs --asprimary --ondisk {{ data.storage_os._disk[0] }}
part /boot/efi --fstype=efi --size=500 --asprimary --ondisk {{ data.storage_os._disk[0] }}
part pv.os --size=13000 --fstype=xfs --grow --asprimary --ondisk {{ data.storage_os._disk[0] }}
volgroup vg00 pv.os
logvol /              --vgname=vg00 --name=root  --fstype=xfs --size 10000 --maxsize 50000 --grow
logvol /home          --vgname=vg00 --name=home  --fstype=xfs --size 1000 --maxsize 10000 --grow
logvol /var/log       --vgname=vg00 --name=log   --fstype=xfs --size 1500 --maxsize 25000 --grow
logvol /tmp           --vgname=vg00 --name=tmp   --fstype=xfs --size 500 --maxsize 6000  --grow
logvol /EDCOP/bulk    --vgname=vg00 --name=bulk  --fstype=xfs --size 1000 --grow
{% endif %}
