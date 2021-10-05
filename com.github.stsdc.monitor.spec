Name: com.github.stsdc.monitor
Version: 0.10.0
Release: 1%{?dist}
Summary: Summary tbd
License: License tbd
URL: https://github.com/stsdc/monitor
Source0: https://github.com/stsdc/monitor/archive/refs/tags/0.10.0.tar.gz

BuildRequires: meson
BuildRequires: vala
BuildRequires: gcc
BuildRequires: git
BuildRequires: pkgconfig(gtk+-3.0)
BuildRequires: pkgconfig(gee-0.8)
BuildRequires: pkgconfig(glib-2.0)
BuildRequires: pkgconfig(granite)
BuildRequires: pkgconfig(gio-2.0)
BuildRequires: pkgconfig(gobject-2.0)
BuildRequires: pkgconfig(libgtop-2.0)
BuildRequires: pkgconfig(libwnck-3.0)
BuildRequires: pkgconfig(wingpanel)
BuildRequires: pkgconfig(gdk-x11-3.0)
BuildRequires: pkgconfig(libhandy-1)

%description

%prep
%autosetup

%build
%meson
%meson_build

%install
%meson_install

%check
%meson_test

%files
%{_bindir}/com.github.stsdc.monitor
%{_libdir}/liblivechart.so
%{_libdir}/libmonitor.so

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%changelog
* Tue Oct 05 2021 meson <meson@example.com> - 
- 

