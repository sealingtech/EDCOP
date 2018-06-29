#!/usr/bin/env python
"""Desgined for interactive kickstart configuration."""
from __future__ import print_function
# import ipaddress
import os
import random
import parted
# pylint: disable=attribute-defined-outside-init


def get_devices():
    """Code used by list-harddrives in anaconda."""
    devices = parted.getAllDevices()
    devices = [d for d in devices if d.type != parted.DEVICE_DM and not
               d.path.startswith('/dev/sr')]

    for dev in devices:
        path = dev.path[5:] if dev.path.startswith('/dev/') else dev.path
        yield path, dev.getSize()


class Host(object):
    """Host class."""

    def __init__(self):
        """Init."""
        self.interfaces = []
        self.harddrives = []
        for name in os.listdir('/sys/class/net'):
            if not name == 'lo':
                self.interfaces.append(name)
        for dev, size in sorted(set(get_devices())):
            self.harddrives.append([dev, size])
        self.name = 'master-' + str(random.randint(1, 65535))

    def pre_hostname(self):
        """Create /tmp/pre_hostname kickstart snipet."""
        # filepath = '/tmp/pre_hostname'
        lines = []
        lines.append('network --device=lo --hostname=' + self.name)
        print(lines)

    def pre_storage(self):
        """Create /tmp/pre_storage kickstart snipet."""
        # filepath = '/tmp/pre_storage'
        pass


# pylint: disable=too-many-instance-attributes
class Network(object):
    """Network."""

    # pylint: disable=too-many-arguments
    def __init__(self,
                 ip_address=None,
                 netmask=None,
                 network=None,
                 interface=None,
                 enabled=False,
                 bootproto=None):
        """Init."""
        self.ip_address = ip_address
        self.netmask = netmask
        self.bootproto = bootproto
        self.interface = interface
        self.enabled = enabled

    @property
    def ip_address(self):
        """Set and return ip_address."""
        return self._ip_address

    @ip_address.setter
    def ip_address(self, value):
        self._ip_address = value

    @property
    def netmask(self):
        """Set and return netmask."""
        return self._netmask

    @netmask.setter
    def netmask(self, value):
        self._netmask = value

    @property
    def bootproto(self):
        """Set and return netmask."""
        return self._bootproto

    @bootproto.setter
    def bootproto(self, value):
        # if value == 0 or value == 'static':
        #     self._bootproto = 'static'
        # elif value == 1 or value == 'dhcp':
        #     self._bootproto = 'dhcp'
        self._bootproto = value


class PXENetwork(Network):
    """PXENetwork class inherits Network."""

    # pylint: disable=too-many-arguments
    def __init__(self,
                 dhcp_start='10.50.50.100',
                 dhcp_end='10.50.50.150',
                 ip_address='10.50.50.1',
                 netmask='255.255.255.0',
                 network='10.50.50.0',
                 bootproto='static',
                 **kargs):
        """Init."""
        super(PXENetwork, self).__init__(enabled=True,
                                         ip_address=ip_address,
                                         netmask=netmask,
                                         bootproto=bootproto,
                                         **kargs)
        self.dhcp_start = dhcp_start
        self.dhcp_end = dhcp_end
        self.bootproto = bootproto
        
        
    def bootproto(self):
        return self._bootproto
    
    def bootproto(selfself, value):
        self._bootproto = value


class ClusterNetwork(Network):
    """ClusterNetwrok class inherits Network."""

    # pylint: disable=too-many-arguments
    def __init__(self,
                 dns1='10.250.250.1',
                 dns2='8.8.8.8',
                 gateway='10.250.250.1',
                 ip_address='10.250.250.10',
                 netmask='255.255.255.0',
                 network='10.250.250.0',
                 bootproto='static',
                 teaming='yes',
                 **kargs):
        """Init."""
        super(ClusterNetwork, self).__init__(enabled=True,
                                             ip_address=ip_address,
                                             netmask=netmask,
                                             bootproto=bootproto,
                                             **kargs)
        self.dns1 = dns1
        self.dns2 = dns2
        self.gateway = gateway
        self.bootproto = bootproto
        self.teaming = teaming

    @property
    def dns1(self):
        """Allow you to set DNS1."""
        return self._dns1

    @dns1.setter
    def dns1(self, value):
        self._dns1 = value

    @property
    def dns2(self):
        """Allow you to set DNS2."""
        return self._dns2

    @dns2.setter
    def dns2(self, value):
        self._dns2 = value
        
    def bootproto(self):
        return self._bootproto
    
    def bootproto(selfself, value):
        self._bootproto = value
        
    


class Storage(object):
    """Storage class used to setup disk requirements."""

    def __init__(self, mountpoint=None, disk=None):
        """Init."""
        self.mountpoint = mountpoint
        self.disk = disk

    @property
    def mountpoint(self):
        """Allow you to configure the mountpoint."""
        return self._mountpoint

    @mountpoint.setter
    def mountpoint(self, mountpoint):
        self._mountpoint = mountpoint

    @property
    def disk(self):
        """Return host disk object."""
        return self._disk

    @disk.setter
    def disk(self, disk):
        self._disk = disk


def main():
    """Main."""
    pxe_network = PXENetwork()
    cluster_network = ClusterNetwork()
    inline_trust = Network()
    inline_untrust = Network()
    passive = Network()
    host = Host()

    pxe_network.ip_address = u'192.198.69.101'
    cluster_network.bootproto = 'dhcp'
    cluster_network.interface = host.interfaces[0]
    host.pre_hostname()
    print(pxe_network.__dict__)
    print(cluster_network.__dict__)
    print(inline_trust.__dict__)
    print(inline_untrust.__dict__)
    print(passive.__dict__)
    print(host.__dict__)

if __name__ == '__main__':
    main()
