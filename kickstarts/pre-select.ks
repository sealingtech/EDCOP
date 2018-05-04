%pre --interpreter=/usr/bin/bash
exec < /dev/tty6 > /dev/tty6 2> /dev/tty6
chvt 6

function printLogo() {
echo '                                                             //'
echo '                                                           / /'
echo '                                                         /  /'
echo '                                                       /   /'
echo '                                                     /    /  '
echo '                                                   /     /'
echo '                                                 /      /'
echo '                                               /       /____'
echo '  ___   _____                          ___   /           __/____   ______     __    _    _'
echo ' /   \ |        /\   |      | |\   |  /   \/____        |__   __| |  ____|  ·  _ · | |  | |'
echo ' |     |       /  \  |      | | \  | /         /       /   | |    | |____  | ,     | |__| |'
echo '  `--, |----  |----| |      | |  \ | |  ___   /      /     | |    |  ____| | |     |  __  |'
echo '     | |      |    | |      | |   \| \     | /     /       | |    | |____  |  ·_·. | |  | |'
echo ' \___/ |_____ |    | |_____ | |    |  \___/ /    /         |_|    |______|  ·.__.· |_|  |_|'
echo '                                           /   /              '
echo '                                          /  /'
echo '                                         / /  '
echo '                                        //'

}

IFLIST=$(ip -o link show | awk -F': ' '{print $2}')
IFARRAY=(${IFLIST[@]})


HOSTNAME="master-$RANDOM.local"
CLUSTERIF="${IFARRAY[1]}"
MASTERIP="DHCP"
MINIONIF="${CLUSTERIF}"
PXEIF="${IFARRAY[2]}"
PXEIP=10.50.50.10
PXENETMASK=255.255.255.0
DHCPSTART=10.50.50.100
DHCPEND=10.50.50.150
DHCP="Y"

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

printLogo
echo "##### NETWORK SETTINGS ####"
echo "Default Values are   :  "
echo "HOSTNAME             : " $HOSTNAME
echo "CLUSTER Interface    : " $CLUSTERIF
echo "CLUSTER IP Address   : " $MASTERIP
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
   clear
   printLogo
   read -p "Enter hostname (entire FQDN)   : " HOSTNAME
   echo "Available Interfaces"
   echo "${IFLIST[@]}"
   read -p "TEAM the network interfaces on Master? (Y/N)" TEAM
   if [[ $TEAM = "Y" ]]
   then
      read -p "Enter CLUSTER Interfaces separated by a comma(e.g. eth0,eth1,eth2,eth4      : " TEAMIFS
      CLUSTERIF="team0"
      IFS=, read -r IF1 IF2 IF3 IF4 <<< $TEAMIFS
      MINIONIF=$IF1
   elif [[ $TEAM = "N" ]]
   then
     read -p "Enter CLUSTER Interface     : " CLUSTERIF
     MINIONIF=$CLUSTERIF
   fi
   read -p "Would you like to set the CLUSTER interface for DHCP? (Y/N)" DHCP
  if [[ $DHCP = "Y" ]]
   then
    MASTERIP="DHCP" 
   elif [[ $DHCP = "N" ]]
   then
     read -p "Enter CLUSTER IP Address      : " MASTERIP
     read -p "Enter CLUSTER Netmask         : " MASTERNETMASK
     read -p "Enter CLUSTER Default Gateway : " MASTERGW
     read -p "Enter CLUSTER DNS             : " MASTERDNS
   fi
   read -p "Enter PXE-Server Interface    : " PXEIF
   read -p "Enter PXE-Server IP Address   : " PXEIP
   read -p "Enter PXE-Server Netmask      : " PXENETMASK
   IFS=. read -r i1 i2 i3 i4 <<< $PXEIP
   IFS=. read -r m1 m2 m3 m4 <<< $PXENETMASK
   PXENET=$(printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))")
   echo "PXE-Server Netwrk      : " $PXENET
   read -p "Enter last octet of DHCP starting IP:" STARTIP
   read -p "Enter last octet of DHCP ending IP  :" ENDIP
   DHCPSTART=$(printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" $STARTIP)
   DHCPEND=$(printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" $ENDIP)
   echo "New Settings are: "
   echo "##### NETWORK SETTINGS ####"
   echo "Default Values are   :  "
   echo "HOSTNAME             : " $HOSTNAME
   echo "CLUSTER Interface    : " $CLUSTERIF
   echo "CLUSTER IP Address   : " $MASTERIP
   echo "PXE-Server Interface : " $PXEIF
   echo "PXE-Server IP Address: " $PXEIP
   echo "PXE-Server Netmask   : " $PXENETMASK
   echo "DHCP Range           : " $DHCPSTART "-" $DHCPEND

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

if [[ $TEAM = "Y" ]]
then
TEAMPARAMS="--teamslaves=$TEAMIFS --teamconfig='{\"runner\": {\"name\": \"lacp\",\"active\": true,\"fast_rate\": true,\"tx_hash\": [\"eth\", \"ipv4\",\"ipv6\"]},\"link_watch\": {\"name\": \"ethtool\"}}'"
fi

if [[ $DHCP = "Y" ]]
then
BOOTPROTO="dhcp"
elif [[ $DHCP = "N" ]]
then
BOOTPROTO="static"
STATICPARAMS="--ip=$MASTERIP --netmask=$MASTERNETMASK --gateway=$MASTERGW --nameserver=$MASTERDNS"
else
echo "ERROR: unknown answer $DHCP in DHCP variable! Expected Y or N."
fi

cat <<EOF | tee -a /tmp/pre-hostname
network --device=$CLUSTERIF --bootproto=$BOOTPROTO $STATICPARAMS $TEAMPARAMS --activate 
network --bootproto=static --device=$PXEIF --ip=$PXEIP --netmask=$PXENETMASK --ipv6=auto --nodefroute --activate
EOF

################################
#### EDCOP Drive Selection #####
################################

declare -a DRIVES=($(echo "$(list-harddrives)" | cut -d ' ' -f1))
declare -a SIZES=($(echo "$(list-harddrives)" | cut -d ' ' -f2 | numfmt --from-unit 1048575 --to=si))
printDrives() {
clear
printLogo
echo "#### INSTALLATION DRIVE SETTINGS ####"
echo "EDCOP is designed to deploy OS and Data drives. These can be on the same drives or separate drives."
echo "At this time, you can only select one drive for each (OS and DATA)"
echo "------------------------------------------------------------------"
num=$(( ${#DRIVES[@]} > ${#SIZES[@]} ? ${#DRIVES[@]} : ${#SIZES[@]} ))
n=-1
while [ $(( n += 1 )) -lt $num ]
do
   printf "%s\t%s\n" ${DRIVES[n]} ${SIZES[n]}
done
}

printDrives
echo "Please Select a Drive to install EDCOP OS on: "
select opt in `echo "$(list-harddrives)" | cut -d ' ' -f1` custom; do
	case $opt in
	  custom) read -p "Enter a drive path (e.g. RAID0_0): " DRIVE
	    break ;;
	  *) DRIVE=`echo $opt | head -n1 | awk '{print $1}'`
	    break ;;
	esac
done
printDrives
echo "Please Select a Drive for the bulk/fast/shared DATA areas: "
select opt2 in `echo "$(list-harddrives)" | cut -d ' ' -f1` custom; do
        case $opt2 in
          custom) read -p "Enter a drive path (e.g. RAID0_0): " BULKDRIVE
            break ;;
          *) BULKDRIVE=`echo $opt2 | head -n1 | awk '{print $1}'`
            break ;;
        esac
done

#
# Enable intel_iommu and allocate 2048 hugepages (~4GB of hugepages)
#
# NOTE: Currently we are using 2MB hugepages in order to support multiple types of systems. This
#       is required by DPDK. This can be changed to support 1GB hugepages if necessary, but the 
#       benefits of this have not been fully explored.
#
echo "bootloader --append=\" crashkernel=auto --location=mbr --boot-drive=$DRIVE intel_iommu=on iommu=pt default_hugepagesz=2M hugepagesz=2M hugepages=2048\"" >/tmp/pre-storage

if [ -z "$BULKDRIVE" ]
then
echo "clearpart --all --initlabel --drives=$DRIVE" >>/tmp/pre-storage
else
echo "clearpart --all --initlabel --drives=$DRIVE,$BULKDRIVE" >>/tmp/pre-storage
echo "part pv.bulk --size=3000 --fstype=xfs --grow --asprimary --ondisk $BULKDRIVE" >>/tmp/pre-storage
echo "volgroup vg01 pv.bulk" >>/tmp/pre-storage
echo "logvol /EDCOP/fast              --vgname=vg01 --name=fast --fstype=xfs --size 5500 --maxsize 100000 --grow" >>/tmp/pre-storage
echo "logvol /EDCOP/bulk              --vgname=vg01 --name=bulk --fstype=xfs --size 5500 --grow" >>/tmp/pre-storage
echo "logvol /EDCOP/shared              --vgname=vg01 --name=shared --fstype=xfs --size 5500 --maxsize 100000 --grow" >>/tmp/pre-storage
fi

echo "part /boot --size=200 --fstype=xfs --asprimary --ondisk $DRIVE" >>/tmp/pre-storage
echo "part /boot/efi --fstype=efi --size=200 --asprimary --ondisk $DRIVE" >>/tmp/pre-storage
echo "part pv.os --size=3000 --fstype=xfs --grow --asprimary --ondisk $DRIVE" >>/tmp/pre-storage
echo "volgroup vg00 pv.os" >>/tmp/pre-storage
echo "logvol /              --vgname=vg00 --name=root  --fstype=xfs --size 5500 --maxsize 21000 --grow" >>/tmp/pre-storage
echo "logvol /var           --vgname=vg00 --name=var   --fstype=xfs --size 4000 --grow" >>/tmp/pre-storage
echo "logvol /home          --vgname=vg00 --name=home  --fstype=xfs --size 1000 --grow --maxsize 10000" >>/tmp/pre-storage
echo "logvol /var/log       --vgname=vg00 --name=log   --fstype=xfs --size 1500 --maxsize 25000 --grow" >>/tmp/pre-storage
echo "logvol /var/log/audit --vgname=vg00 --name=audit --fstype=xfs --size 1500 --maxsize 25000 --grow" >>/tmp/pre-storage
echo "logvol /tmp           --vgname=vg00 --name=tmp   --fstype=xfs --size 100 --maxsize 6000  --grow" >>/tmp/pre-storage

echo "#!/bin/bash" >/tmp/vars
echo "HOSTNAME=$HOSTNAME" >> /tmp/vars
echo "CLUSTERIF=$CLUSTERIF" >> /tmp/vars
echo "MASTERIP=$MASTERIP" >> /tmp/vars
echo "MASTERNETMASK=$MASTERNETMASK" >> /tmp/vars
echo "MASTERGW=$MASTERGW" >> /tmp/vars
echo "MASTERDNS=$MASTERDNS" >> /tmp/vars
echo "MINIONIF=$MINIONIF" >> /tmp/vars
echo "PXEIF=$PXEIF" >> /tmp/vars
echo "PXEIP=$PXEIP" >> /tmp/vars
echo "PXENETMASK=$PXENETMASK" >> /tmp/vars
echo "PXENET=$PXENET" >> /tmp/vars
echo "DHCPSTART=$DHCPSTART" >> /tmp/vars
echo "DHCPEND=$DHCPEND" >> /tmp/vars
echo "DRIVE=$DRIVE" >> /tmp/vars
echo "BULKDRIVE=$BULKDRIVE" >> /tmp/vars

echo
sleep 1

chvt 1
exec < /dev/tty1 > /dev/tty1 2> /dev/tty1
%end

