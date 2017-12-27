# pre-hostname is generated within the pre-select-network section
%include /tmp/pre-hostname

firewall --disabled

network --bootproto=static --device=team0 --gateway=10.250.250.1 --ip=10.250.250.10 --nameserver=10.250.250.1 --netmask=255.255.255.0 --activate --teamslaves="eth2,eth3,eth4,eth5" --teamconfig='{"runner": {"name": "lacp","active": true,"fast_rate": true,"tx_hash": ["eth", "ipv4","ipv6"]},"link_watch": {"name": "ethtool"}}'

