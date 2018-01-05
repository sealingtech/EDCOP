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
install fixipam $RPM_BUILD_ROOT/opt/cni/bin/fixipam
install multus $RPM_BUILD_ROOT/opt/cni/bin/multus
install ovs $RPM_BUILD_ROOT/opt/cni/bin/ovs
install sriov $RPM_BUILD_ROOT/opt/cni/bin/sriov

%clean
rm -rf $RPM_BUILD_ROOT


%files
/opt/cni/bin/


%changelog
#
