%post --log=/root/EDCOP_post.log

source /EDCOP/vars

systemctl enable openvswitch
systemctl enable cockpit
systemctl enable docker
systemctl enable kubelet

##### CREATE CA & CERTIFICATES #####

mkdir -p /etc/pki/tls/csr

openssl req -subj '/CN=edcop-root/O=Sealing Technologies Inc/L=Columbia/ST=Maryland/C=US' -new -newkey rsa:2048 -sha256 -days 7300 -nodes -x509 -extensions v3_ca -keyout /etc/pki/CA/private/edcop-root.key -out /etc/pki/CA/certs/edcop-root.crt

openssl req -subj '/CN=edcop-master.local/O=Sealing Technologies Inc/L=Columbia/ST=Maryland/C=US' -new -newkey rsa:2048 -sha256 -days 7300 -nodes -keyout /etc/pki/tls/private/server.key -out /etc/pki/tls/csr/edcop-master.csr

openssl x509 -req -days 7300 -extensions server_cert -set_serial 01 -CA /etc/pki/CA/certs/edcop-root.crt -CAkey /etc/pki/CA/private/edcop-root.key -in /etc/pki/tls/csr/edcop-master.csr -out /etc/pki/tls/certs/server.crt

mkdir -p /EDCOP/pxe/deploy/EXTRAS/certs
cp /etc/pki/CA/certs/edcop-root.crt /EDCOP/pxe/deploy/EXTRAS/certs
cp /etc/pki/tls/certs/server.crt /EDCOP/pxe/deploy/EXTRAS/certs

modprobe br-netfilter
echo "br-netfilter" > /etc/modprobe.d/br-netfilter
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo "net.bridge.bridge-nf-call-iptables=1" > /etc/sysctl.d/k8s.conf
echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.d/k8s.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/k8s.conf
sed -i --follow-symlinks 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

sed -i --follow-symlinks 's/\/usr\/share\/nginx\/html/\/EDCOP\/pxe/g' /etc/nginx/nginx.conf
sed -i --follow-symlinks 's/80/5415/g' /etc/nginx/nginx.conf

systemctl enable nginx
systemctl enable dnsmasq

cat <<EOF | tee /etc/dnsmasq.d/pxeboot.conf
interface=$PXEIF
# and don't bind to 0.0.0.0
bind-interfaces
# extra logging
log-dhcp
dhcp-range=$DHCPSTART,$DHCPEND,1h
# first IP address is the one of the host
dhcp-boot=pxelinux.0
#pxe-service=x86PC,"Automatic Network Boot",pxelinux
# Specify the IP address of another tftp server
enable-tftp
# default location of tftp-server on CentOS
tftp-root=/EDCOP/pxe/
# disable DNS
port=0
EOF


cat <<EOF | tee /etc/systemd/system/EDCOP-firstboot.service
[Unit]
Description=Auto-execute my post install scripts
After=network.target

[Service]
ExecStart=/root/firstboot.sh
User=root
WorkingDirectory=/root

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF | tee /etc/cockpit/cockpit.conf
[WebService]
AllowUnencrypted=true
UrlRoot=/admin
EOF

chmod +x /root/firstboot.sh

sed -i --follow-symlinks "s/<insert-master-ip>/$PXEIP/g" /EDCOP/pxe/pxelinux.cfg/default
sed -i --follow-symlinks "s/<insert-drive>/$DRIVE/g" /EDCOP/pxe/deploy/ks/virtual/minion/main.ks

sed -i "/localhost/ s/$/ edcop-master.local $(hostname)/" /etc/hosts

systemctl enable EDCOP-firstboot

%end

