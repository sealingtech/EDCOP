%pre
echo "network  --device=lo --hostname=minion-$RANDOM" > /tmp/pre-hostname
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

%include /tmp/pre-hostname
network --bootproto=dhcp --device=<insert-clusterif> --activate
network --bootproto=dhcp --device=<insert-pxeif> --nodefroute

# Temorarily disable firewall while builing
#firewall --enabled --port=22:tcp,6443:tcp,2379:tcp,2380:tcp,10250:tcp,9090:tcp,30010:tcp
firewall --disabled

# Root password
rootpw --plaintext open.local.box
# System timezone
timezone America/New_York --isUtc
# System bootloader configuration

#
# Enable intel_iommu and allocate 2048 hugepages (~4GB of hugepages)
#
# NOTE: Currently we are using 2MB hugepages in order to support multiple types of systems. This
#       is required by DPDK. This can be changed to support 1GB hugepages if necessary, but the 
#       benefits of this have not been fully explored.
#

bootloader --append=" crashkernel=auto --location=mbr --boot-drive=<insert-drive> intel_iommu=on iommu=pt default_hugepagesz=2M hugepagesz=2M hugepages=2048"

%include http://<insert-master-ip>:5415/deploy/ks/minion/storage.ks

%packages --excludedocs
@^minimal
@core
kexec-tools
openscap
openscap-scanner
scap-security-guide
#EDCOP specific packages
python-six
vim-enhanced
mlocate
net-tools
open-vm-tools
bridge-utils
virt-viewer
kubeadm
kubelet
kubectl
container-selinux
wget
docker
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
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/k8s.conf
sed -i --follow-symlinks 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

#
# We're moving to a Registry-based approach on the Master server. Images will be pulled from there
# rather than wget.
#
#mkdir -p /EDCOP/images
#wget -P /EDCOP/images/ -r -np -nH --cut-dirs=50 -R "TRANS.TBL" -R "index.html" http://<insert-master-ip>:5415/deploy/EXTRAS/docker-images/

mkdir /root/.kube/
wget -P /root/.kube/ http://<insert-master-ip>:5415/deploy/EXTRAS/kubernetes/config
wget -P /etc/pki/ca-trust/source/anchors/ http://<insert-master-ip>:5415/deploy/EXTRAS/certs/edcop-root.crt
update-ca-trust

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

cat <<EOF | tee /etc/cockpit/cockpit.conf
[WebService]
AllowUnencrypted=true
UrlRoot=/
EOF

systemctl enable minion-firstboot

cat <<'EOF' | tee /root/minion-firstboot.sh
#!/bin/bash
sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf

kubeadm join --token <insert-token> <insert-master-ip>:6443 --discovery-token-unsafe-skip-ca-verification

systemctl start cockpit
systemctl disable minion-firstboot

ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
kubectl label nodes $(hostname | awk '{print tolower($0)}') nodetype=worker --overwrite

rm -f /root/minion-firstboot.sh
rm -f /etc/systemd/system/minion-firstboot.service
EOF

chmod +x /root/minion-firstboot.sh

echo "<insert-master-ip>        edcop-master.local master" >> /etc/hosts
sed -i "/localhost/ s/$/ $(hostname)/" /etc/hosts

useradd -r -u 2000 elasticsearch
mkdir /EDCOP/bulk/esdata
chown elasticsearch:elasticsearch /EDCOP/bulk/esdata

useradd -r -u 2001 moloch 
mkdir /EDCOP/bulk/moloch/ /EDCOP/bulk/moloch/raw /EDCOP/bulk/moloch/logs
chown moloch:moloch /EDCOP/bulk/moloch/ /EDCOP/bulk/moloch/raw /EDCOP/bulk/moloch/logs 


mkdir /EDCOP/bulk/ceph


%end



