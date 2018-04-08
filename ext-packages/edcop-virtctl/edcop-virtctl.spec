%undefine _missing_build_ids_terminate_build

Name:		edcop-virtctl
Version:	1
Release:	0
Summary:	EDCOP KubeVirt Controller Binary

Group:		application
License:	SealingTech
Source0: 	%{name}.tar.gz

BuildArch:	x86_64
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}

%description
Temporary binary that contains advanced commands for managing kubevirt containers/machines

%prep
%setup -q


%build


%install
install -m 0755 -d  %{buildroot}/usr/local/bin/
install virtctl $RPM_BUILD_ROOT/usr/local/bin/virtctl

%clean
rm -rf $RPM_BUILD_ROOT


%files
/usr/local/bin/virtctl


%changelog
#
