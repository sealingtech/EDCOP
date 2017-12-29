%pre
echo "network  --device=lo --hostname=MINION-$RANDOM" > /tmp/pre-hostname
%end


# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
install
# Use cmdline install
text
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
# Zeroize the Master Boot Record
zerombr
# Currently required to disabled SELINUX for Kubernetes
selinux --disabled
# Reboot when complete
reboot

network --bootproto=dhcp --device=eth0 --activate
network --bootproto=dhcp --device=eth1 --nodefroute
%include /tmp/pre-hostname

# Temorarily disable firewall while builing
#firewall --enabled --port=22:tcp,6443:tcp,2379:tcp,2380:tcp,10250:tcp,9090:tcp,30010:tcp
firewall --disabled

# Root password
rootpw --plaintext open.local.box
# System timezone
timezone America/New_York --isUtc
# System bootloader configuration

clearpart --all --initlabel --drives=<insert-drive>

bootloader --append=" crashkernel=auto net.ifnames=0 --location=mbr --boot-drive=<insert-drive> intel_iommu=on iommu=pt hugepages=2000"


#autopart --type=lvm
part /boot --size=200 --fstype=xfs --asprimary
part biosboot --size=1 --fstype="biosboot"
part pv.os --size=3000 --fstype=xfs --grow --asprimary

volgroup vg00 pv.os
logvol /              --vgname=vg00 --name=root  --fstype=xfs --size 5500 --maxsize 21000 --grow
logvol /var           --vgname=vg00 --name=var   --fstype=xfs --size 4000 --grow
logvol /home          --vgname=vg00 --name=home  --fstype=xfs --size 1000 --grow
logvol /var/log       --vgname=vg00 --name=log   --fstype=xfs --size 1500 --maxsize 25000 --grow
logvol /var/log/audit --vgname=vg00 --name=audit --fstype=xfs --size 1500 --maxsize 25000 --grow
logvol /tmp           --vgname=vg00 --name=tmp   --fstype=xfs --size 100 --maxsize 6000  --grow

%packages --excludedocs
@^minimal
@core
kexec-tools
openscap
openscap-scanner
scap-security-guide
#EDCOP specific packages
edcop-cni
dpdk-stable
dpdk-stable-devel
openvswitch
openvswitch-devel
python-six
vim-enhanced
mlocate
net-tools
open-vm-tools
bridge-utils
cockpit
cockpit-system
cockpit-bridge
cockpit-kubernetes
kubeadm
kubelet
kubectl
container-selinux
wget
docker-ce
epel-release
-aic94xx-firmware
-iwl6000-firmware
-iwl6050-firmware
-iwl7265-firmware
-iwl4965-firmware
-iwl6000g2b-firmware
-iwl105-firmware
-iwl1000-firmware
-iwl135-firmware
-iwl100-firmware
-iwl3945-firmware
-iwl3160-firmware
-iwl2030-firmware
-iwl5000-firmware
-iwl6000g2a-firmware
-ivtv-firmware
-iwl2000-firmware
-iwl5150-firmware
-iwl7260-firmware
-postfix

%end


#%post --nochroot --log=/mnt/sysimage/root/EDCOP_post-nochroot.log
#You can copy files from the disk over to the install directory e.g.
#%end

%post --log=/root/EDCOP_post.log
systemctl enable openvswitch
systemctl enable cockpit
systemctl enable docker
systemctl enable kubelet

modprobe br-netfilter
echo "br-netfilter" > /etc/modprobe.d/br-netfilter
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo "net.bridge.bridge-nf-call-iptables=1" > /etc/sysctl.d/k8s.conf
echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.d/k8s.conf
sed -i --follow-symlinks 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

#
# We're moving to a Registry-based approach on the Master server. Images will be pulled from there
# rather than wget.
#
#mkdir -p /EDCOP/images
#wget -P /EDCOP/images/ -r -np -nH --cut-dirs=50 -R "TRANS.TBL" -R "index.html" http://<insert-master-ip>:5415/deploy/EXTRAS/docker-images/


#
# Moved to an RPM install for the CNI files
#
#mkdir -p /opt/cni/bin
#wget -P /opt/cni/bin -r -np -nH --cut-dirs=50 -R "TRANS.TBL" -R "index.html" http://<insert-master-ip>:5415/deploy/EXTRAS/multus-bins/
#chmod 755 /opt/cni/bin/*

mkdir /root/.kube/
wget -P /root/.kube/ http://<insert-master-ip>:5415/deploy/EXTRAS/kubernetes/config


cat <<EOF | tee /etc/systemd/system/minion-firstboot.service
[Unit]
Description=Auto-execute my post install scripts
After=network.target

[Service]
ExecStart=/root/minion-firstboot.sh
User=root
WorkingDirectory=/root

[Install]
WantedBy=multi-user.target
EOF

systemctl enable minion-firstboot

cat <<'EOF' | tee /root/minion-firstboot.sh
#!/bin/bash

kubeadm join --token <insert-token> <insert-master-ip>:6443 --discovery-token-unsafe-skip-ca-verification
systemctl start cockpit
systemctl disable minion-firstboot

ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true

rm -f /root/minion-firstboot.sh
rm -f /etc/systemd/system/minion-firstboot.service
EOF

chmod +x /root/minion-firstboot.sh

%end

