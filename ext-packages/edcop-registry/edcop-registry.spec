%define  debug_package %{nil}

Name:           edcop-registry
Version:        1
Release:        0
Summary:        Expandable DCO Platform Registry Container

Group:          application
License:        SealingTech

URL:            http://repos.sealingtech.org/edcop/1.0
Source0:        http://repos.sealingtech.org/edcop/docker-registry.tar.gz

BuildArch:     noarch
Requires:      docker-ce

%description
This package contains the Docker Registry that is installed with the Expandable DCO Platform (EDCOP).

%prep
%setup -q  -c -T
%build


%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d %{buildroot}%{_tmppath}
install %{SOURCE0} %{buildroot}%{_tmppath}

%clean
rm -rf $RPM_BUILD_ROOT

%post
gunzip -c %{SOURCE0} | docker load
rm -f {_tmppath}/docker-registry.tar.gz

%postun
docker rmi registry:2

%files
%defattr(-,root,root,-)
%config(missingok) %{_tmppath}/docker-registry.tar.gz

%changelog
* Sun Dec 10 2017 Ed Sealing <ed.sealing@sealingtech.org> - 11-20
- Initial Commit
