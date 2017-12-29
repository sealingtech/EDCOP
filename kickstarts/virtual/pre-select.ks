%pre --interpreter=/usr/bin/bash
exec < /dev/tty6 > /dev/tty6 2> /dev/tty6
chvt 6

HOSTNAME="MASTER-$RANDOM"
PXEIF=eth1
PXEIP=10.50.50.10
PXENETMASK=255.255.255.0
DHCPSTART=10.50.50.100
DHCPEND=10.50.50.150

echo "##### PXE NETWORK SETTINGS ####"
echo "Default Values are   :  "
echo "HOSTNAME             : " $HOSTNAME
echo "PXE-Server Interface : " $PXEIF
echo "PXE-Server IP Address: " $PXEIP
echo "PXE-Server Netmask   : " $PXENETMASK
echo "DHCP Range           : " $DHCPSTART "-" $DHCPEND
read -p "Would you like to accept defaults? (Y/N)" ANSWER

while [[ $ANSWER != "Y" && $ANSWER != "N"  ]]
do
echo "Please type Y or N only"
read -p "Would you like to accept defaults? (Y/N)" ANSWER
done

function getconfig() {
   read -p "Enter hostname    : " HOSTNAME
   read -p "Enter PXE-Server Interface      : " PXEIF
   read -p "Enter PXE-Server IP Address         : " PXEIP
   read -p "Enter PXE-Server Netmask         : " PXENETMASK
   IFS=. read -r i1 i2 i3 i4 <<< $PXEIP
   IFS=. read -r m1 m2 m3 m4 <<< $PXENETMASK
   PXENET=$(printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))")
   echo "PXE-Server Netwrk      : " $PXENET
   read -p "Enter last octet of DHCP starting IP:" STARTIP
   read -p "Enter last octet of DHCP ending IP  :" ENDIP
   DHCPSTART=$($printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" $STARTIP)
   DHCPEND=$(printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" $ENDIP)
   echo "New Settings are: "
   echo "HOSTNAME: " $HOSTNAME
   echo "PXE-Server Interface   : " $PXEIF
   echo "PXE-Server IP Address  : " $PXEIP
   echo "PXE-Server Netmask     : " $PXENETMASK
   echo "PXE-Server Network     : " $PXENET
   echo "DHCP Range             : " $DHCPSTART "-" $DHCPEND

}
if [[ $ANSWER = "Y" ]]
then
   echo "Defaults will be kept... Proceeding with install!"
elif [[ $ANSWER = "N" ]]
then
   while [[ $KEEP != "Y" ]]
   do
     getconfig
     read -p "Would you like to keep these settings? (Y/N)" KEEP
   done

else
   echo "ERROR: Passed loop without a Y or N"
   exit 1
fi

echo "network  --device=lo --hostname=$HOSTNAME" > /tmp/pre-hostname
echo "network --bootproto=static --device=$PXEIF --ip=$PXEIP --netmask=$PXENETMASK --ipv6=auto" >> /tmp/pre-hostname

echo "#### INSTALLATION DRIVE SETTINGS ####"
echo "Please Select a Drive to install EDCOP on: "
select opt in `echo $(list-harddrives) | cut -d ' ' -f1` custom; do
	case $opt in
	  custom) read -p "Enter a drive path (e.g. RAID0_0): " DRIVE
	    break ;;
	  *) DRIVE=`echo $opt | head -n1 | awk '{print $1}'`
	    break ;;
	esac
done

echo "bootloader --append=\" crashkernel=auto net.ifnames=0 --location=mbr --boot-drive=$DRIVE\"" >/tmp/pre-storage
echo "clearpart --all --initlabel --drives=$DRIVE" >>/tmp/pre-storage

echo "#!/bin/bash" >/tmp/vars
echo "HOSTNAME=$HOSTNAME" >> /tmp/vars
echo "PXEIF=$PXEIF" >> /tmp/vars
echo "PXEIP=$PXEIP" >> /tmp/vars
echo "PXENETMASK=$PXENETMASK" >> /tmp/vars
echo "PXENET=$PXENET" >> /tmp/vars
echo "DHCPSTART=$DHCPSTART" >> /tmp/vars
echo "DHCPEND=$DHCPEND" >> /tmp/vars
echo "DRIVE=$DRIVE" >> /tmp/vars

echo
sleep 1

chvt 1
exec < /dev/tty1 > /dev/tty1 2> /dev/tty1
%end

