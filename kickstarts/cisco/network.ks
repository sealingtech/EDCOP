# pre-hostname is generated within the pre-select-network section
%include /tmp/pre-hostname

firewall --disabled

network --bootproto=static --device=team0 --gateway=10.240.240.1 --ip=10.240.240.10 --nameserver=10.240.240.1 --netmask=255.255.255.0 --activate --teamslaves="eth2,eth3,eth5,eth6" --teamconfig='{"runner": {"name": "lacp","active": true,"fast_rate": true,"tx_hash": ["eth", "ipv4","ipv6"]},"link_watch": {"name": "ethtool"}}'

#network --bootproto=dhcp --device=eth0 --gateway=10.240.240.1 --ip=10.240.240.10 --nameserver=10.240.240.1 --netmask=255.255.255.0--activate

