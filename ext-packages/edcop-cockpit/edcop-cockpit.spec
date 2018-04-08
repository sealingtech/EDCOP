#
# This file is maintained at the following location:
# https://github.com/cockpit-project/cockpit/blob/master/tools/cockpit.spec
#
# If you are editing this file in another location, changes will likely
# be clobbered the next time an automated release is done.
#
# Check first cockpit-devel@lists.fedorahosted.org
#
# Globals that may be defined elsewhere
#  * Version 122
#  * wip 1
#

# earliest base that the subpackages work on; the instances of this get computed/updated
# by tools/gen-spec-dependencies during "make dist", but keep a hardcoded fallback
%define required_base 122

%if 0%{?centos}
%define rhel 0
%endif

# for testing this already gets set in fedora.install, as we want the target
# VERSION_ID, not the mock chroot's one
%if "%{!?os_version_id:1}"
%define os_version_id %(. /etc/os-release; echo $VERSION_ID)
%endif

%define _hardened_build 1

# define to build the dashboard
%define build_dashboard 1

# on RHEL 7.x we build subscriptions; superseded in RHEL 8 (and Fedora) by
# external subscription-manager-cockpit
%if 0%{?rhel} >= 7 && 0%{?rhel} < 8
%define build_subscriptions 1
%endif


%define libssh_version 0.7.1
%if 0%{?fedora} > 0 && 0%{?fedora} < 22
%define libssh_version 0.6.0
%endif

Name:           edcop-cockpit
Summary:        A user interface for Linux servers

License:        LGPLv2+
URL:            http://cockpit-project.org/

Version:        165
%if %{defined wip}
Release:        1.%{wip}%{?dist}
Source0:        cockpit-%{version}.tar.gz
%else
Release:        1%{?dist}
Source0:        https://github.com/cockpit-project/cockpit/releases/download/%{version}/cockpit-%{version}.tar.xz
%endif

BuildRequires: pkgconfig(gio-unix-2.0)
BuildRequires: pkgconfig(json-glib-1.0)
BuildRequires: pkgconfig(polkit-agent-1) >= 0.105
BuildRequires: pam-devel

BuildRequires: autoconf automake
BuildRequires: /usr/bin/python2
BuildRequires: intltool
%if %{defined build_dashboard}
BuildRequires: libssh-devel >= %{libssh_version}
%endif
BuildRequires: openssl-devel
BuildRequires: zlib-devel
BuildRequires: krb5-devel
BuildRequires: libxslt-devel
BuildRequires: docbook-style-xsl
BuildRequires: glib-networking
BuildRequires: sed
BuildRequires: git

BuildRequires: glib2-devel >= 2.37.4
BuildRequires: systemd-devel
BuildRequires: pcp-libs-devel
BuildRequires: krb5-server
BuildRequires: gdb

# For documentation
BuildRequires: xmlto

# This is the "cockpit" metapackage. It should only
# Require, Suggest or Recommend other cockpit-xxx subpackages

Requires: %{name}-bridge = %{version}-%{release}
Requires: %{name}-ws = %{version}-%{release}
Requires: %{name}-system = %{version}-%{release}

# Optional components (for f24 we use soft deps)
%if 0%{?fedora} >= 24 || 0%{?rhel} >= 8
Recommends: %{name}-dashboard = %{version}-%{release}
Recommends: %{name}-networkmanager = %{version}-%{release}
Recommends: %{name}-storaged = %{version}-%{release}
Recommends: sscg >= 2.3
#EDCOP-PATCH
%if 0%{?rhel} >= 8
Recommends: subscription-manager-cockpit
%endif
%ifarch x86_64 %{arm} aarch64 ppc64le i686 s390x
Recommends: %{name}-docker = %{version}-%{release}
%endif
Suggests: %{name}-pcp = %{version}-%{release}
Suggests: %{name}-kubernetes = %{version}-%{release}
Suggests: %{name}-selinux = %{version}-%{release}
Suggests: %{name}-packagekit = %{version}-%{release}

%endif

%description
Cockpit runs in a browser and can manage your network of GNU/Linux
machines.

%files
%{_docdir}/cockpit/AUTHORS
%{_docdir}/cockpit/COPYING
%{_docdir}/cockpit/README.md
%dir %{_datadir}/cockpit
%{_datadir}/metainfo/cockpit.appdata.xml
%{_datadir}/applications/cockpit.desktop
%{_datadir}/pixmaps/cockpit.png
%doc %{_mandir}/man1/cockpit.1.gz

%prep
%setup -q

# Apply patches using git in order to support binary patches. Note that
# we also reset mtimes since patches should be "complete" and include both
# generated and source file changes
# Keep this in sync with tools/debian/rules.
if [ -n "%{patches}" ]; then
    git init
    git config user.email "unused@example.com" && git config user.name "Unused"
    git config core.autocrlf false && git config core.safecrlf false && git config gc.auto 0
    git add -f . && git commit -a -q -m "Base" && git tag -a initial --message="initial"
    git am --whitespace=nowarn %{patches}
    touch -r $(git diff --name-only initial..HEAD) .git
    rm -rf .git
fi

%build
exec 2>&1
%configure \
    --disable-silent-rules \
    --with-cockpit-user=cockpit-ws \
    --with-selinux-config-type=etc_t \
    %{?rhel:--without-storaged-iscsi-sessions} \
    --with-appstream-data-packages='[ "appstream-data" ]' \
    %{!?build_dashboard:--disable-ssh}
make -j4 %{?extra_flags} all

%check
exec 2>&1
make -j4 check

%install
make install DESTDIR=%{buildroot}
make install-tests DESTDIR=%{buildroot}
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/pam.d
install -p -m 644 tools/cockpit.pam $RPM_BUILD_ROOT%{_sysconfdir}/pam.d/cockpit
rm -f %{buildroot}/%{_libdir}/cockpit/*.so
install -p -m 644 AUTHORS COPYING README.md %{buildroot}%{_docdir}/cockpit/

# On RHEL we don't yet show options for changing language
%if 0%{?rhel}
echo '{ "linguas": null }' > %{buildroot}%{_datadir}/cockpit/shell/override.json
%endif

# Build the package lists for resource packages
echo '%dir %{_datadir}/cockpit/base1' > base.list
find %{buildroot}%{_datadir}/cockpit/base1 -type f >> base.list
echo '%{_sysconfdir}/cockpit/machines.d' >> base.list

%if %{defined build_dashboard}
echo '%dir %{_datadir}/cockpit/dashboard' >> dashboard.list
find %{buildroot}%{_datadir}/cockpit/dashboard -type f >> dashboard.list
find %{buildroot}%{_datadir}/cockpit/ssh -type f >> dashboard.list
%else
rm -rf %{buildroot}/%{_datadir}/cockpit/dashboard
rm -rf %{buildroot}/%{_datadir}/cockpit/ssh
touch dashboard.list
%endif

echo '%dir %{_datadir}/cockpit/pcp' >> pcp.list
find %{buildroot}%{_datadir}/cockpit/pcp -type f >> pcp.list

echo '%dir %{_datadir}/cockpit/realmd' >> system.list
find %{buildroot}%{_datadir}/cockpit/realmd -type f >> system.list

echo '%dir %{_datadir}/cockpit/tuned' >> system.list
find %{buildroot}%{_datadir}/cockpit/tuned -type f >> system.list

echo '%dir %{_datadir}/cockpit/shell' >> system.list
find %{buildroot}%{_datadir}/cockpit/shell -type f >> system.list

echo '%dir %{_datadir}/cockpit/systemd' >> system.list
find %{buildroot}%{_datadir}/cockpit/systemd -type f >> system.list

echo '%dir %{_datadir}/cockpit/users' >> system.list
find %{buildroot}%{_datadir}/cockpit/users -type f >> system.list

echo '%dir %{_datadir}/cockpit/kdump' >> kdump.list
find %{buildroot}%{_datadir}/cockpit/kdump -type f >> kdump.list

echo '%dir %{_datadir}/cockpit/sosreport' > sosreport.list
find %{buildroot}%{_datadir}/cockpit/sosreport -type f >> sosreport.list

%if %{defined build_subscriptions}
echo '%dir %{_datadir}/cockpit/subscriptions' >> system.list
find %{buildroot}%{_datadir}/cockpit/subscriptions -type f >> system.list
%else
rm -rf %{buildroot}/%{_datadir}/cockpit/subscriptions
%endif

echo '%dir %{_datadir}/cockpit/storaged' > storaged.list
find %{buildroot}%{_datadir}/cockpit/storaged -type f >> storaged.list

echo '%dir %{_datadir}/cockpit/networkmanager' > networkmanager.list
find %{buildroot}%{_datadir}/cockpit/networkmanager -type f >> networkmanager.list

echo '%dir %{_datadir}/cockpit/ostree' > ostree.list
find %{buildroot}%{_datadir}/cockpit/ostree -type f >> ostree.list

echo '%dir %{_datadir}/cockpit/packagekit' >> packagekit.list
find %{buildroot}%{_datadir}/cockpit/packagekit -type f >> packagekit.list

echo '%dir %{_datadir}/cockpit/apps' >> packagekit.list
find %{buildroot}%{_datadir}/cockpit/apps -type f >> packagekit.list

echo '%dir %{_datadir}/cockpit/machines' > machines.list
find %{buildroot}%{_datadir}/cockpit/machines -type f >> machines.list

echo '%dir %{_datadir}/cockpit/ovirt' > ovirt.list
find %{buildroot}%{_datadir}/cockpit/ovirt -type f >> ovirt.list

# on CentOS systems we don't have the required setroubleshoot-server packages
%if 0%{?centos}
rm -rf %{buildroot}%{_datadir}/cockpit/selinux
%else
echo '%dir %{_datadir}/cockpit/selinux' > selinux.list
find %{buildroot}%{_datadir}/cockpit/selinux -type f >> selinux.list
%endif

%ifarch x86_64 %{arm} aarch64 ppc64le i686 s390x
echo '%dir %{_datadir}/cockpit/docker' > docker.list
find %{buildroot}%{_datadir}/cockpit/docker -type f >> docker.list
%else
rm -rf %{buildroot}/%{_datadir}/cockpit/docker
touch docker.list
%endif

%ifarch aarch64 x86_64 ppc64le s390x
%if %{defined wip}
%else
rm %{buildroot}/%{_datadir}/cockpit/kubernetes/override.json
%endif
echo '%dir %{_datadir}/cockpit/kubernetes' > kubernetes.list
find %{buildroot}%{_datadir}/cockpit/kubernetes -type f >> kubernetes.list
%else
rm -rf %{buildroot}/%{_datadir}/cockpit/kubernetes
rm -f %{buildroot}/%{_libexecdir}/cockpit-kube-auth
rm -f %{buildroot}/%{_libexecdir}/cockpit-kube-launch
rm %{buildroot}/%{_libexecdir}/cockpit-stub
touch kubernetes.list
%endif

sed -i "s|%{buildroot}||" *.list

# Build the package lists for debug package, and move debug files to installed locations
find %{buildroot}/usr/src/debug%{_datadir}/cockpit -type f -o -type l > debug.partial
sed -i "s|%{buildroot}/usr/src/debug||" debug.partial
sed -n 's/\.map\(\.gz\)\?$/\0/p' *.list >> debug.partial
sed -i '/\.map\(\.gz\)\?$/d' *.list
tar -C %{buildroot}/usr/src/debug -cf - . | tar -C %{buildroot} -xf -
rm -rf %{buildroot}/usr/src/debug

# On RHEL kdump, networkmanager, selinux, and sosreport are part of the system package
%if 0%{?rhel}
cat kdump.list sosreport.list networkmanager.list selinux.list >> system.list
rm %{buildroot}/usr/share/metainfo/org.cockpit-project.cockpit-sosreport.metainfo.xml
rm %{buildroot}/usr/share/pixmaps/cockpit-sosreport.png
%endif

%find_lang cockpit

# dwz has trouble with the go binaries
# https://fedoraproject.org/wiki/PackagingDrafts/Go
%global _dwz_low_mem_die_limit 0
%if 0%{?fedora} >= 27 || 0%{?rhel} >= 8
%global _debugsource_packages 1
%global _debuginfo_subpackages 0
%endif

%define find_debug_info %{_rpmconfigdir}/find-debuginfo.sh %{?_missing_build_ids_terminate_build:--strict-build-id} %{?_include_minidebuginfo:-m} %{?_find_debuginfo_dwz_opts} %{?_find_debuginfo_opts} %{?_debugsource_packages:-S debugsourcefiles.list} "%{_builddir}/%{?buildsubdir}"

# Redefine how debug info is built to slip in our extra debug files
%define __debug_install_post   \
   %{find_debug_info} \
   cat debug.partial >> %{_builddir}/%{?buildsubdir}/debugfiles.list \
%{nil}

# -------------------------------------------------------------------------------
# Sub-packages

%define __lib lib

%package bridge
Summary: Cockpit bridge server-side component
Requires: glib-networking

%description bridge
The Cockpit bridge component installed server side and runs commands on the
system on behalf of the web based user interface.

%files bridge -f base.list
%{_datadir}/cockpit/base1/bundle.min.js.gz
%doc %{_mandir}/man1/cockpit-bridge.1.gz
%{_bindir}/cockpit-bridge
%{_libexecdir}/cockpit-askpass

%package doc
Summary: Cockpit deployment and developer guide
BuildArch: noarch

%description doc
The Cockpit Deployment and Developer Guide shows sysadmins how to
deploy Cockpit on their machines as well as helps developers who want to
embed or extend Cockpit.

%files doc
%exclude %{_docdir}/cockpit/AUTHORS
%exclude %{_docdir}/cockpit/COPYING
%exclude %{_docdir}/cockpit/README.md
%{_docdir}/cockpit

%package machines
BuildArch: noarch
Summary: Cockpit user interface for virtual machines
Requires: %{name}-bridge >= 122
Requires: %{name}-system >= 122
Requires: libvirt
Requires: libvirt-client
# Optional components (for f24 we use soft deps)
%if 0%{?fedora} >= 24 || 0%{?rhel} >= 8
Recommends: virt-install
%endif

%description machines
The Cockpit components for managing virtual machines.
If "virt-install" is installed, you can also create new virtual machines.

%files machines -f machines.list

%package machines-ovirt
BuildArch: noarch
Summary: Cockpit user interface for oVirt virtual machines
Requires: %{name}-bridge >= 122
Requires: %{name}-system >= 122
Requires: libvirt
Requires: libvirt-client
# package of old name "cockpit-ovirt" was shipped on fedora only
%if 0%{?fedora} >= 25
Obsoletes: %{name}-ovirt < 161
%endif

%description machines-ovirt
The Cockpit components for managing oVirt virtual machines.

%files machines-ovirt -f ovirt.list

%package ostree
BuildArch: noarch
Summary: Cockpit user interface for rpm-ostree
# Requires: Uses new translations functionality
Requires: %{name}-bridge >= 124.x
Requires: %{name}-system >= 124.x
%if 0%{?fedora} > 0 && 0%{?fedora} < 24
Requires: rpm-ostree >= 2015.10-1
%else
Requires: /usr/libexec/rpm-ostreed
%endif

%description ostree
The Cockpit components for managing software updates for ostree based systems.

%files ostree -f ostree.list

%package pcp
Summary: Cockpit PCP integration
Requires: %{name}-bridge >= 134.x
Requires: pcp

%description pcp
Cockpit support for reading PCP metrics and loading PCP archives.

%files pcp -f pcp.list
%{_libexecdir}/cockpit-pcp
%{_localstatedir}/lib/pcp/config/pmlogconf/tools/cockpit

%post pcp
# HACK - https://bugzilla.redhat.com/show_bug.cgi?id=1185764
# We can't use "systemctl reload-or-try-restart" since systemctl might
# be out of sync with reality.
/usr/share/pcp/lib/pmlogger condrestart

%if %{defined build_dashboard}
%package dashboard
Summary: Cockpit remote servers and dashboard
Requires: libssh >= %{libssh_version}
Provides: %{name}-ssh = %{version}-%{release}
# nothing depends on the dashboard, but we can't use it with older versions of the bridge
Conflicts: %{name}-bridge < 135
Conflicts: %{name}-ws < 135

%description dashboard
Cockpit support for connecting to remote servers (through ssh),
bastion hosts, and a basic dashboard.

%files dashboard -f dashboard.list
%{_libexecdir}/cockpit-ssh

%endif

# storaged on RHEL 7.4 and Fedora < 27, udisks on newer ones
# Recommends: not supported in RHEL < 8
%package storaged
Summary: Cockpit user interface for storage, using Storaged
Requires: %{name}-shell >= 122
%if (0%{?rhel} == 7 && "%{os_version_id}" == "7.4") || 0%{?centos} == 7
Requires: storaged >= 2.1.1
Requires: storaged-lvm2 >= 2.1.1
Requires: storaged-iscsi >= 2.1.1
Requires: device-mapper-multipath
%else
%if 0%{?rhel} == 7
Requires: udisks2 >= 2.6
Requires: udisks2-lvm2 >= 2.6
Requires: udisks2-iscsi >= 2.6
Requires: device-mapper-multipath
%else
%if 0%{?fedora} >= 27 || 0%{?rhel} >= 8
Requires: udisks2 >= 2.6
Recommends: udisks2-lvm2 >= 2.6
Recommends: udisks2-iscsi >= 2.6
Recommends: device-mapper-multipath
%else
# Fedora < 27
Requires: storaged >= 2.1.1
Recommends: storaged-lvm2 >= 2.1.1
Recommends: storaged-iscsi >= 2.1.1
Recommends: device-mapper-multipath
%endif
%endif
%endif
%if 0%{?fedora} || 0%{?rhel} >= 8
Requires: python3
Requires: python3-dbus
%else
Requires: python
Requires: python-dbus
%endif
BuildArch: noarch

%description storaged
The Cockpit component for managing storage.  This package uses Storaged.

%files storaged -f storaged.list

%package system
Summary: Cockpit admin interface package for configuring and troubleshooting a system
BuildArch: noarch
Requires: %{name}-bridge >= %{version}-%{release}
Requires: shadow-utils
Requires: grep
Requires: libpwquality
Requires: /usr/bin/date
Provides: %{name}-realmd = %{version}-%{release}
Provides: %{name}-shell = %{version}-%{release}
Obsoletes: %{name}-shell < 127
Provides: %{name}-systemd = %{version}-%{release}
Provides: %{name}-tuned = %{version}-%{release}
Provides: %{name}-users = %{version}-%{release}
%if 0%{?rhel}
Provides: %{name}-networkmanager = %{version}-%{release}
Obsoletes: %{name}-networkmanager < 135
Requires: NetworkManager
Provides: %{name}-kdump = %{version}-%{release}
Requires: kexec-tools
# Optional components (only when soft deps are supported)
%if 0%{?fedora} >= 24 || 0%{?rhel} >= 8
Recommends: polkit
%endif
%if 0%{?rhel} >= 8
Recommends: NetworkManager-team
Recommends: setroubleshoot-server >= 3.3.3
%endif
Provides: %{name}-selinux = %{version}-%{release}
Provides: %{name}-sosreport = %{version}-%{release}
%endif
%if %{defined build_subscriptions}
Provides: %{name}-subscriptions = %{version}-%{release}
Requires: subscription-manager >= 1.13
%endif

%description system
This package contains the Cockpit shell and system configuration interfaces.

%files system -f system.list

%package tests
Summary: Tests for Cockpit
Requires: %{name}-bridge >= 138
Requires: %{name}-system >= 138
Requires: openssh-clients
Provides: %{name}-test-assets = %{version}-%{release}
Obsoletes: %{name}-test-assets < 132

%description tests
This package contains tests and files used while testing Cockpit.
These files are not required for running Cockpit.

%files tests
%config(noreplace) %{_sysconfdir}/cockpit/cockpit.conf
%{_datadir}/cockpit/playground
%{_prefix}/%{__lib}/cockpit-test-assets

%package ws
Summary: Cockpit Web Service
Requires: glib-networking
Requires: openssl
Requires: glib2 >= 2.37.4
Requires(post): systemd
Requires(preun): systemd
Requires(postun): systemd

%description ws
The Cockpit Web Service listens on the network, and authenticates users.

%files ws -f cockpit.lang
%doc %{_mandir}/man5/cockpit.conf.5.gz
%doc %{_mandir}/man8/cockpit-ws.8.gz
%doc %{_mandir}/man8/remotectl.8.gz
%doc %{_mandir}/man8/pam_ssh_add.8.gz
%config(noreplace) %{_sysconfdir}/cockpit/ws-certs.d
%config(noreplace) %{_sysconfdir}/pam.d/cockpit
%{_datadir}/cockpit/issue/active.issue
%{_datadir}/cockpit/issue/inactive.issue
%{_unitdir}/cockpit.service
%{_unitdir}/cockpit.socket
%{_prefix}/%{__lib}/firewalld/services/cockpit.xml
%{_prefix}/%{__lib}/tmpfiles.d/cockpit-tempfiles.conf
%{_sbindir}/remotectl
%{_libdir}/security/pam_ssh_add.so
%{_libexecdir}/cockpit-ws
%attr(4750, root, cockpit-ws) %{_libexecdir}/cockpit-session
%attr(775, -, wheel) %{_localstatedir}/lib/cockpit
%{_datadir}/cockpit/static
%{_datadir}/cockpit/branding

%pre ws
getent group cockpit-ws >/dev/null || groupadd -r cockpit-ws
getent passwd cockpit-ws >/dev/null || useradd -r -g cockpit-ws -d / -s /sbin/nologin -c "User for cockpit-ws" cockpit-ws

%post ws
%systemd_post cockpit.socket
# firewalld only partially picks up changes to its services files without this
test -f %{_bindir}/firewall-cmd && firewall-cmd --reload --quiet || true

%preun ws
%systemd_preun cockpit.socket

%postun ws
%systemd_postun_with_restart cockpit.socket
%systemd_postun_with_restart cockpit.service

# -------------------------------------------------------------------------------
# Conditional Sub-packages

%if 0%{?rhel} == 0

%package kdump
Summary: Cockpit user interface for kernel crash dumping
Requires: %{name}-bridge >= 122
Requires: %{name}-shell >= 122
Requires: kexec-tools
BuildArch: noarch

%description kdump
The Cockpit component for configuring kernel crash dumping.

%files kdump -f kdump.list

%package sosreport
Summary: Cockpit user interface for diagnostic reports
Requires: %{name}-bridge >= 122
Requires: %{name}-shell >= 122
Requires: sos
BuildArch: noarch

%description sosreport
The Cockpit component for creating diagnostic reports with the
sosreport tool.

%files sosreport -f sosreport.list
/usr/share/metainfo/org.cockpit-project.cockpit-sosreport.metainfo.xml
/usr/share/pixmaps/cockpit-sosreport.png

%package networkmanager
Summary: Cockpit user interface for networking, using NetworkManager
Requires: %{name}-bridge >= 122
Requires: %{name}-shell >= 122
Requires: NetworkManager
# Optional components (only when soft deps are supported)
%if 0%{?fedora} >= 24 || 0%{?rhel} >= 8
Recommends: NetworkManager-team
%endif
BuildArch: noarch

%description networkmanager
The Cockpit component for managing networking.  This package uses NetworkManager.

%files networkmanager -f networkmanager.list

%endif

%if 0%{?rhel}%{?centos} == 0

%package selinux
Summary: Cockpit SELinux package
Requires: %{name}-bridge >= 122
Requires: %{name}-shell >= 122
%if 0%{?fedora} >= 24 || 0%{?rhel} >= 8
Recommends: setroubleshoot-server >= 3.3.3
%endif
BuildArch: noarch

%description selinux
This package contains the Cockpit user interface integration with the
utility setroubleshoot to diagnose and resolve SELinux issues.

%files selinux -f selinux.list

%endif

%ifarch x86_64 %{arm} aarch64 ppc64le i686 s390x

%package docker
Summary: Cockpit user interface for Docker containers
Requires: %{name}-bridge >= 122
Requires: %{name}-shell >= 122
Requires: /usr/bin/docker
Requires: /usr/lib/systemd/system/docker.service
Requires: python2

%description docker
The Cockpit components for interacting with Docker and user interface.
This package is not yet complete.

%files docker -f docker.list

%endif

%ifarch aarch64 x86_64 ppc64le s390x

%package kubernetes
Summary: Cockpit user interface for Kubernetes cluster
Requires: /usr/bin/kubectl
# Requires: Needs newer localization support
Requires: %{name}-bridge >= 137.x
Requires: %{name}-shell >= 137.x
BuildRequires: golang-bin
BuildRequires: golang-src
Provides: cockpit-stub = %{version}-%{release}

%description kubernetes
The Cockpit components for visualizing and configuring a Kubernetes
cluster. Installed on the Kubernetes master. This package is not yet complete.

%files kubernetes -f kubernetes.list
%{_libexecdir}/cockpit-kube-auth
%{_libexecdir}/cockpit-kube-launch
%{_libexecdir}/cockpit-stub
%endif

%package packagekit
Summary: Cockpit user interface for packages
BuildArch: noarch
Requires: %{name}-bridge >= 138
Requires: PackageKit

%description packagekit
The Cockpit components for installing OS updates and Cockpit add-ons,
via PackageKit.

%files packagekit -f packagekit.list

# The changelog is automatically generated and merged
%changelog
