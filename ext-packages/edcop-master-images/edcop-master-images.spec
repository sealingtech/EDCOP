%define  debug_package %{nil}

Name:           edcop-master-images
Version:        1
Release:        0
Summary:        Expandable DCO Platform Master Containers

Group:          application
License:        SealingTech

URL:            http://repos.sealingtech.org/edcop/1.0
Source0:        http://repos.sealingtech.org/edcop/edcop-master.tar.gz

BuildArch:     noarch

%description
This package contains all of the images required to run the master server of the Expandable DCO Platform (EDCOP).

%prep
%setup -q  -c -T
%build


%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d %{buildroot}/EDCOP/images
install %{SOURCE0} %{buildroot}/EDCOP/images

%clean
rm -rf $RPM_BUILD_ROOT

%post
tar xzf /EDCOP/images/edcop-master.tar.gz -C /EDCOP/images
rm -f /EDCOP/images/edcop-master.tar.gz

%postun
rm -rf /EDCOP/images/edcop-master

%files
%defattr(-,root,root,-)
/EDCOP/images/edcop-master.tar.gz

%changelog
* Sun Dec 10 2017 Ed Sealing <ed.sealing@sealingtech.org> - 11-20
- Initial Commit
