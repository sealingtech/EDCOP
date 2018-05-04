#!/usr/bin/env python
# pylint: disable=too-many-ancestors
"""Menu system."""

import sys
import npyscreen
import classes
import datetime
from kickstart import *

def str_ljust(_string):
    """Add padding to string."""
    pad = 20
    return str(_string.ljust(pad, ".") + ":")

def update_enabled_widget(widget):
    """Update."""
    if widget.parent.enabled.value == [0]:
        widget.parent.interface.editable = True
        widget.parent.display()
    else:
        widget.parent.interface.editable = False
        widget.parent.interface.value = None
        widget.parent.display()

def update_bootproto_widget(widget):
    """Update."""
    if widget.parent.bootproto.value == [1]:
        widget.parent.ipaddress.editable = False
        widget.parent.ipaddress.hidden = True
        widget.parent.ipaddress.color = 'NO_EDIT'
        widget.parent.netmask.editable = False
        widget.parent.netmask.hidden = True
        widget.parent.netmask.color = 'NO_EDIT'
        widget.parent.display()
    else:
        widget.parent.ipaddress.editable = True
        widget.parent.ipaddress.hidden = False
        widget.parent.ipaddress.color = 'DEFAULT'
        widget.parent.netmask.editable = True
        widget.parent.netmask.hidden = False
        widget.parent.netmask.color = 'DEFAULT'
        widget.parent.display()


# pylint: disable=too-many-instance-attributes
class MyTestApp(npyscreen.NPSAppManaged):
    """TestApp.

    All Forms registered with an NPSAppManaged instance can access the
    controlling application as self.parentApp.
    """

    def calculate_menu_height(self):
        """Calculate menu height for wid2et."""
        return max(2, len(self.host.interfaces))

    # pylint: disable=attribute-defined-outside-init
    def onStart(self):
        """Register all forms for application."""
        self.begin_at = 25
        self.bootproto = ["static", "dhcp"]
        self.teaming = ['yes', 'no']
        self.host = classes.Host()
        self.network_pxe = classes.PXENetwork()
        self.network_cluster = classes.ClusterNetwork()
        self.network_trust = classes.Network()
        self.network_untrust = classes.Network()
        self.network_passive = classes.Network()
        self.storage_os = classes.Storage(mountpoint="/")
        self.storage_fast = classes.Storage(mountpoint="/var/EDCOP/fast")
        self.storage_bulk = classes.Storage(mountpoint="/var/EDCOP/bulk")
        self.storage_shared = classes.Storage(mountpoint="/var/EDCOP/shared")
        
        self.addForm("MAIN", MainForm)
        self.addForm("HOSTNAME", HostEditForm)
        self.addForm("NETWORKSELECT", NetworkSelectForm)
        self.addForm("NETWORKPXE", PXENetForm)
        self.addForm("NETWORKCLUSTER", ClusterNetForm)
        self.addForm("NETWORKTRUST", NetworkEditForm,
                     network=self.network_trust, name="Trust (LAN)")
        self.addForm("NETWORKUNTRUST", NetworkEditForm,
                     network=self.network_untrust, name="Untrust (WAN)")
        self.addForm("NETWORKPASSIVE", NetworkEditForm,
                     network=self.network_passive, name="Passive")
        self.addForm("STORAGESELECT", StorageSelectForm)
        self.addForm("STORAGEOS", StorageEditForm, storage=self.storage_os, name="EDCOP OS")
        self.addForm("STORAGEFAST", StorageEditForm, storage=self.storage_fast, name="Fast")
        self.addForm("STORAGEBULK", StorageEditForm, storage=self.storage_bulk, name="Bulk")
        self.addForm("STORAGESHARED", StorageEditForm, storage=self.storage_shared, name="Shared")


# pylint: disable=too-many-instance-attributes
class MainMenuWidget(npyscreen.MultiLineAction):
    """Display main menu."""

    def __init__(self, *args, **keywords):
        """Init."""
        super(MainMenuWidget, self).__init__(*args, **keywords)
        self.menu_hostname = "Set Hostname"
        self.menu_network = "Configure Network"
        self.menu_storage = "Configure Storage"
        self.values = [self.menu_hostname,
                       self.menu_network,
                       self.menu_storage]
        self.max_height = len(self.values) + 1

    # pylint: disable=invalid-name
    def actionHighlighted(self, act_on_this, key_press):
        """Select form."""
        if act_on_this == self.menu_hostname:
            self.parent.parentApp.switchForm("HOSTNAME")
        if act_on_this == self.menu_network:
            self.parent.parentApp.switchForm("NETWORKSELECT")
        if act_on_this == self.menu_storage:
            self.parent.parentApp.switchForm("STORAGESELECT")


# pylint: disable=too-many-instance-attributes
class NetworkMenuWidget(npyscreen.MultiLineAction):
    """Display main menu."""

    def __init__(self, *args, **keywords):
        """Init."""
        super(NetworkMenuWidget, self).__init__(*args, **keywords)
        self.menu_pxe = "PXE Network"
        self.menu_cluster = "Cluster Network"
        self.menu_trust = "Inline-Trust (LAN) Network"
        self.menu_untrust = "Inline-UnTrust (WAN) Network"
        self.menu_passive = "Passive Network"
        self.values = [self.menu_pxe,
                       self.menu_cluster,
                       self.menu_trust,
                       self.menu_untrust,
                       self.menu_passive]
        self.max_height = len(self.values) + 1

    # pylint: disable=invalid-name
    def actionHighlighted(self, act_on_this, key_press):
        """Select form."""
        if act_on_this == self.menu_pxe:
            self.parent.parentApp.switchForm("NETWORKPXE")
        if act_on_this == self.menu_cluster:
            self.parent.parentApp.switchForm("NETWORKCLUSTER")
        if act_on_this == self.menu_trust:
            self.parent.parentApp.switchForm("NETWORKTRUST")
        if act_on_this == self.menu_untrust:
            self.parent.parentApp.switchForm("NETWORKUNTRUST")
        if act_on_this == self.menu_passive:
            self.parent.parentApp.switchForm("NETWORKPASSIVE")


# pylint: disable=too-many-instance-attributes
class StorageMenuWidget(npyscreen.MultiLineAction):
    """Display main menu."""

    def __init__(self, *args, **keywords):
        """Init."""
        super(StorageMenuWidget, self).__init__(*args, **keywords)
        self.menu_os = "EDCOP OS"
        self.menu_fast = "Local-Fast"
        self.menu_bulk = "Local-Bulk"
        self.menu_shared = "Shared"
        self.values = [self.menu_os,
                       self.menu_fast,
                       self.menu_bulk,
                       self.menu_shared]
        self.max_height = len(self.values) + 1

    # pylint: disable=invalid-name
    def actionHighlighted(self, act_on_this, key_press):
        """Select form."""
        if act_on_this == self.menu_os:
            self.parent.parentApp.switchForm("STORAGEOS")
        if act_on_this == self.menu_fast:
            self.parent.parentApp.switchForm("STORAGEFAST")
        if act_on_this == self.menu_bulk:
            self.parent.parentApp.switchForm("STORAGEBULK")
        if act_on_this == self.menu_shared:
            self.parent.parentApp.switchForm("STORAGESHARED")


class MainForm(npyscreen.ActionFormMinimal):
    """Home Screen."""

    def create(self):
        """Run at instantiation."""
        self.name = "EDCOP"
        self.add(MainMenuWidget)

    def on_ok(self):
        """Next."""
        self.parentApp.setNextForm(None)


class NetworkSelectForm(npyscreen.ActionFormMinimal):
    # Class for the form that has options for PXE, cluster, passive, etc sub-menus
    """Form."""

    def create(self):
        """Run at instantiation."""
        self.name = "EDCOP > Network"
        self.add(NetworkMenuWidget)

    def on_ok(self):
        """Next."""
        self.parentApp.setNextForm("MAIN")


class StorageSelectForm(npyscreen.ActionFormMinimal):
    """Form."""

    def create(self):
        """Run at instantiation."""
        self.name = "EDCOP > Storage"
        self.add(StorageMenuWidget)

    def on_ok(self):
        """Next."""
        self.parentApp.setNextForm("MAIN")


class HostEditForm(npyscreen.ActionFormV2):
    """Edit Hostname."""

    def create(self):
        """Create method is called by the Form constructor.

        It does nothing by default - it is there for you to override in subclasses,
        but it is the best place to set up all the widgets on a Form. Expect this
        method to be full of self.add(...) method calls, then!
        """
        self.name = "Host configuration:"
        self.hostname = self.add(npyscreen.TitleText, name="Hostname")

    # pylint: disable=invalid-name
    def beforeEditing(self):
        """Call before form is edited."""
        self.hostname.value = self.parentApp.host.name

    # pylint: disable=invalid-name
    def afterEditing(self):
        """Call when the form is exited."""
        self.parentApp.host.name = self.hostname.value
        self.parentApp.switchFormPrevious()
        
    def on_ok(self):
        if (self.hostname.value != ""):
            try:
                self.parentApp.host.name = self.hostname.value
            except:
                npyscreen.notify_confirm("Something went wrong. Please check your hostname", title="Error")
        else:
            npyscreen.notify_confirm("You must enter a hostname.", title="Error")
            
        


class NetForm(npyscreen.ActionFormV2):
    # Base Network Form class.

    def create(self):
        """Create method is called by the Form constructor."""
        self.begin_at = self.parentApp.begin_at
        self.bootproto = self.add(npyscreen.TitleSelectOne,
                                  name=str_ljust("Bootproto"),
                                  begin_entry_at=self.begin_at,
                                  max_height=3,
                                  scroll_exit=True)
        self.teaming = self.add(npyscreen.TitleSelectOne,
                                  name=str_ljust("NIC Teaming"),
                                  begin_entry_at=self.begin_at,
                                  max_height=3,
                                  scroll_exit=True)
        self.interface = self.add(npyscreen.TitleMultiSelect,
                                  name=str_ljust("Interface"),
                                  begin_entry_at=self.begin_at,
                                  #max_height=self.parentApp.calculate_menu_height,
                                  max_height=8,
                                  scroll_exit=True)
        self.ipaddress = self.add(npyscreen.TitleText,
                                  name=str_ljust("IP Address"),
                                  begin_entry_at=self.begin_at)
        self.netmask = self.add(npyscreen.TitleText,
                                name=str_ljust("Netmask"),
                                begin_entry_at=self.begin_at)
        self.dhcp_start = self.add(npyscreen.TitleText,
                                   name=str_ljust("DHCP start"),
                                   begin_entry_at=self.begin_at)
        self.dhcp_end = self.add(npyscreen.TitleText,
                                 name=str_ljust("DHCP end"),
                                 begin_entry_at=self.begin_at)
        self.dns1 = self.add(npyscreen.TitleText,
                             name=str_ljust("Primary DNS"),
                             begin_entry_at=self.begin_at)
        self.dns2 = self.add(npyscreen.TitleText,
                             name=str_ljust("Secondary DNS"),
                             begin_entry_at=self.begin_at)
        self.gateway = self.add(npyscreen.TitleText,
                                name=str_ljust("Gateway"),
                                begin_entry_at=self.begin_at)

        self.dhcp_start.hidden = True
        self.dhcp_end.hidden = True
        self.dns1.hidden = True
        self.dns2.hidden = True
        self.gateway.hidden = True
        self.bootproto.values = ['static', 'dhcp']
        self.teaming.values = ['yes', 'no']
        #self.bootproto.value = 0
        self.bootproto.value_changed_callback = update_bootproto_widget

    def on_cancel(self):
        """Next."""
        self.parentApp.switchFormPrevious()

# pylint: disable=too-many-instance-attributes
class PXENetForm(NetForm):
    # PXE Network Form. Extends the NetForm class 

    # pylint: disable=invalid-name
    # pylint: disable=attribute-defined-outside-init
    def beforeEditing(self):
        """Call before form is edited."""
        self.name = "EDCOP > Network > PXE"
        self.network = self.parentApp.network_pxe
        self.interface.values = self.parentApp.host.interfaces
        self.ipaddress.value = self.network.ip_address
        self.netmask.value = self.network.netmask
        self.dhcp_start.value = self.network.dhcp_start
        self.dhcp_end.value = self.network.dhcp_end
        self.dhcp_start.hidden = True
        self.dhcp_end.hidden = True
        self.teaming.hidden = True

    def on_ok(self):
        """Save network information to object."""
        try:
            self.network.bootproto = self.parentApp.bootproto[self.bootproto.value[0]]
            self.network.interface = self.parentApp.host.interfaces[self.interface.value[0]]
            self.network.ip_address = self.ipaddress.value
            self.network.netmask = self.netmask.value
            self.network.dhcp_start = self.dhcp_start.value
            self.network.dhcp_end = self.dhcp_start.value
            self.parentApp.switchFormPrevious()
        except IndexError:
            npyscreen.notify_confirm("Please select a valid interface", title="Error")



class ClusterNetForm(NetForm):
    # Cluster network form. Extends the NetForm class 

    # pylint: disable=invalid-name
    # pylint: disable=attribute-defined-outside-init
    def beforeEditing(self):
        """Update values."""
        self.name = "EDCOP > Network > Cluster"
        self.network = self.parentApp.network_cluster
        self.ipaddress.value = self.network.ip_address
        self.interface.values = self.parentApp.host.interfaces
        self.ipaddress.value = self.network.ip_address
        self.netmask.value = self.network.netmask
        self.dns1.value = self.network.dns1
        self.dns2.value = self.network.dns2
        self.gateway.value = self.network.gateway
        self.dns1.hidden = False
        self.dns2.hidden = False
        self.gateway.hidden = False
        self.teaming.value = self.network.teaming

    def on_ok(self):
        """Save network information to object."""
        try:
            interfaceList = []
            for index in range(len(self.interface.value)):
                interfaceList.append(self.parentApp.host.interfaces[self.interface.value[index]])
            self.network.interface = interfaceList
            self.network.bootproto = self.parentApp.bootproto[self.bootproto.value[0]]
            self.network.ip_address = self.ipaddress.value
            self.network.netmask = self.netmask.value
            self.network.dns1 = self.dns1.value
            self.network.dns2 = self.dns2.value
            self.network.gateway = self.gateway.value
            self.network.teaming = self.parentApp.teaming[self.teaming.value[0]]
                      
            self.parentApp.switchFormPrevious()
        except IndexError:
            npyscreen.notify_confirm("Please select a valid interface", title="Error")

class NetworkEditForm(npyscreen.ActionFormV2):
    
    """Form."""

    def __init__(self, network, name, *args, **keywords):
        """Init."""
        super(NetworkEditForm, self).__init__()
        self.network = network
        self.name = "EDCOP > Network > " + name

    def create(self):
        """Add."""
        self.enabled = self.add(npyscreen.TitleSelectOne,
                                name=str_ljust("Enable Interface"),
                                max_height=3, scroll_exit=True,
                                begin_entry_at=25)
        self.interface = self.add(npyscreen.TitleSelectOne,
                                  name=str_ljust("Interface"),
                                  scroll_exit=True,
                                  begin_entry_at=25,
                                  editable=True)
        self.enabled.value_changed_callback = update_enabled_widget

    # pylint: disable=invalid-name
    def beforeEditing(self):
        """Refresh."""
        self.enabled.values = ["Enabled",
                               "Disabled"]
        self.enabled.value = [1]
        self.interface.values = self.parentApp.host.interfaces

    def on_ok(self):
        """Ok."""
        self.parentApp.setNextForm("NETWORKSELECT")
        if self.enabled.value == [0]:
            try:
                self.network.enabled = True
                self.network.interface = self.parentApp.host.interfaces[self.interface.value[0]]
            except IndexError:
                npyscreen.notify_confirm("Please select a valid interface", title="Error")

    def on_cancel(self):
        """Cancel."""
        self.parentApp.setNextForm("NETWORKSELECT")


class StorageEditForm(npyscreen.ActionFormV2):
    """Form."""

    def __init__(self, storage, name, *args, **keywords):
        """Init."""
        super(StorageEditForm, self).__init__(*args, **keywords)
        self.storage = storage
        self.name = "EDCOP > Storage > " + name

    def create(self):
        """Add."""
        self.mount = self.add(npyscreen.TitleText, name="Mountpoint")
        self.disk = self.add(npyscreen.TitleSelectOne, name="Disk", scroll_exit=True)

    # pylint: disable=invalid-name
    def beforeEditing(self):
        """Refresh."""
        self.mount.value = self.storage.mountpoint
        self.disk.values = self.parentApp.host.harddrives

    def on_ok(self):
        """Ok."""
        try:
            self.storage.mountpoint = self.mount.value
            self.storage.disk = self.parentApp.host.harddrives[self.disk.value[0]]
            self.parentApp.setNextForm("STORAGESELECT")
        except IndexError:
            npyscreen.notify_confirm("Please select a valid storage drive", title="Error")

    def on_cancel(self):
        """Cancel."""
        self.parentApp.setNextForm("STORAGESELECT")

class EDCOPOSForm(StorageEditForm):
    # Class for EDCOPOS Form. Extends Storage Form
    
    def beforeEditing(self):
        self.name = "EDCOP > Storage > EDCOP OS"
    
    def on_ok(self):
        pass

def logData(KICKSTART_MENU):
    # Dump various data to a log file for TSHOOT purposes
    outFile = open("/tmp/dev.log", "w")
    
    dump = ""
    now = datetime.datetime.now()
    outFile.write(now.isoformat())
    
    dump += now.isoformat() + "\n\n"
    dump += "=================================" + "\n\n"
    dump += KICKSTART_MENU.host.name + "\n"
    dump += str(KICKSTART_MENU.host.__dict__) + "\n"
    dump += str(KICKSTART_MENU.network_pxe.__dict__) + "\n"
    dump += str(KICKSTART_MENU.network_cluster.__dict__) + "\n"
    dump += str(KICKSTART_MENU.network_trust.__dict__) + "\n"
    dump += str(KICKSTART_MENU.network_untrust.__dict__) + "\n"
    dump += str(KICKSTART_MENU.network_passive.__dict__) + "\n"
    dump += str(KICKSTART_MENU.storage_os.__dict__) + "\n"
    dump += str(KICKSTART_MENU.storage_fast.__dict__) + "\n"
    dump += str(KICKSTART_MENU.storage_bulk.__dict__) + "\n"
    dump += str(KICKSTART_MENU.storage_shared.__dict__) + "\n"

    outFile.write(dump)
    outFile.close()
    
      
if __name__ == '__main__':
    try:
        KICKSTART_MENU = MyTestApp()
        KICKSTART_MENU.run()
        
        logData(KICKSTART_MENU)
        
        ksCreator(KICKSTART_MENU)
    except KeyboardInterrupt:
        logData(KICKSTART_MENU)

        sys.exit()
