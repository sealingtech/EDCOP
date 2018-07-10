network  --device=lo --hostname={{ data.host.name }}
network --bootproto=static --device={{ data.network_pxe.interface }} --ip={{ data.network_pxe._ip_address }} --netmask={{ data.network_pxe._netmask }} --ipv6=auto --nodefroute --activate
firewall --disabled

{# Spit out the appropriate config based on what combo of cluster NIC teaming and static/dhcp config is selected #}
{%- if data.network_cluster.teaming=='yes' -%}
	{% if data.network_cluster.bootproto=='static' %}
network --bootproto=static --device=team0 --gateway={{ data.network_cluster.gateway }} --ip={{ data.network_cluster._ip_address }} --nameserver={{ data.network_cluster._dns1 }},{{ data.network_cluster._dns2 }} --netmask={{ data.network_cluster._netmask }} --activate --teamslaves={{ data.network_cluster.interface|join(',') }} --teamconfig='{"runner": {"name": "lacp","active": true,"fast_rate": true,"tx_hash": ["eth", "ipv4","ipv6"]},"link_watch": {"name": "ethtool"}}'  
	{% else %}
network --bootproto=dhcp --device=team0 --teamslaves={{ data.network_cluster.interface|join(',') }} --activate --teamconfig='{"runner": {"name": "lacp","active": true,"fast_rate": true,"tx_hash": ["eth", "ipv4","ipv6"]},"link_watch": {"name": "ethtool"}}' 
	{% endif %}
{% else %}
	{% if data.network_cluster.bootproto=='static' %}
network --device={{ data.network_cluster.interface[0] }} --bootproto=static --ip={{ data.network_cluster._ip_address }} --netmask={{ data.network_cluster._netmask }} --gateway={{ data.network_cluster.gateway }} --nameserver={{ data.network_cluster._dns1 }},{{ data.network_cluster._dns2 }} --activate
	{% else %}
network --device={{ data.network_cluster.interface[0] }} --bootproto=dhcp --activate	
	{% endif %}
{%- endif -%}