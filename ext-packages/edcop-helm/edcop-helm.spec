%undefine _missing_build_ids_terminate_build

Name:		edcop-helm
Version:	1
Release:	0
Summary:	EDCOP Helm Binary

Group:		application
License:	SealingTech
Source0: 	%{name}.tar.gz

BuildArch:	x86_64
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}

%description
Binary for the HELM templating interpreter used by Kubernetes.

%prep
%setup -q


%build


%install
install -m 0755 -d  %{buildroot}/usr/local/bin/
install helm $RPM_BUILD_ROOT/usr/local/bin/helm

%clean
rm -rf $RPM_BUILD_ROOT


%files
/usr/local/bin/helm


%changelog
#
