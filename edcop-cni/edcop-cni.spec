%undefine _missing_build_ids_terminate_build

Name:		edcop-cni
Version:	1
Release:	0
Summary:	EDCOP CNI Plugins

Group:		application
License:	SealingTech
Source0: 	%{name}.tar.gz	

BuildArch:	x86_64
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}

%description
CNI Plugins required to utilize multiple networks within the EDCOP containers

%prep
%setup -q


%build


%install
install -m 0755 -d  %{buildroot}/opt/cni/bin/
#install bridge %{buildroot}/opt/cni/bin/bridge
#install dhcp $RPM_BUILD_ROOT/opt/cni/bin/dhcp
install fixipam $RPM_BUILD_ROOT/opt/cni/bin/fixipam
#install flannel $RPM_BUILD_ROOT/opt/cni/bin/flannel
install host-device $RPM_BUILD_ROOT/opt/cni/bin/host-device
#install host-local $RPM_BUILD_ROOT/opt/cni/bin/host-local
#install ipvlan $RPM_BUILD_ROOT/opt/cni/bin/ipvlan
#install loopback $RPM_BUILD_ROOT/opt/cni/bin/loopback
#install macvlan $RPM_BUILD_ROOT/opt/cni/bin/macvlan
install multus $RPM_BUILD_ROOT/opt/cni/bin/multus
install ovs $RPM_BUILD_ROOT/opt/cni/bin/ovs
install portmap $RPM_BUILD_ROOT/opt/cni/bin/portmap
#install ptp $RPM_BUILD_ROOT/opt/cni/bin/ptp
#install sample $RPM_BUILD_ROOT/opt/cni/bin/sample
install sriov $RPM_BUILD_ROOT/opt/cni/bin/sriov
#install tuning $RPM_BUILD_ROOT/opt/cni/bin/tuning
install vlan $RPM_BUILD_ROOT/opt/cni/bin/vlan

%clean
rm -rf $RPM_BUILD_ROOT


%files
/opt/cni/bin/


%changelog
#
