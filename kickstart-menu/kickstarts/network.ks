network  --device=lo --hostname={{ data.host.name }}

{% if data.network_cluster.teaming=='yes' %}

network --bootproto=static --device=team0 --gateway=172.16.250.1 --ip=172.16.250.120 --nameserver=172.16.250.1 --netmask=255.255.255.0 --activate --teamslaves=$TEAMIFS --teamconfig='{"runner": {"name": "lacp","active": true,"fast_rate": true,"tx_hash": ["eth", "ipv4","ipv6"]},"link_watch": {"name": "ethtool"}}'  
{% elif data.network_cluster.bootproto=='dhcp' %}

network --device={{ data.network_cluster.interface }} --bootproto=dhcp --activate
{% elif data.network_cluster.bootproto=='static' %}

network --device=team0 --bootproto=static --ip={{ data.network_cluster._ip_address }} --netmask={{ data.network_cluster._netmask }} --gateway={{ data.network_cluster.gateway }} --nameserver={{ data.network_cluster._dns1 }} --activate
{% endif %}

network --bootproto=static --device={{ data.network_pxe.interface }} --ip={{ data.network_pxe._ip_address }} --netmask={{ data.network_pxe._netmask }} --ipv6=auto
firewall --disabled