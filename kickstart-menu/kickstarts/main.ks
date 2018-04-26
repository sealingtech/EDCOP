%include /run/install/repo/ks/pre-menu.ks
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
install
cdrom
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

%include /tmp/ks/network.ks

# Root password
rootpw --plaintext open.local.box
# System timezone
timezone America/New_York --isUtc
# System bootloader configuration


%include /tmp/ks/storage.ks

%include /tmp/ks/packages.ks

%include /tmp/ks/post-nochroot.ks

%include /tmp/ks/post-chroot.ks
