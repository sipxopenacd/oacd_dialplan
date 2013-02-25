%global realname oacd_dialplan
%global debug_package %{nil}
%global upstream sipxopenacd

Name:		erlang-oacd_dialplan
Version:	2.0.0
Release:	%{?buildno:%buildno}%{!?buildno:1}
Summary:	Dialplan plug-in for OpenACD
Group:		Development/Libraries
License:	AGPL3
URL:		http://github.com/sipxopenacd/oacd_dialplan
Source0:	%{name}-%{version}.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildRequires:	erlang-rebar
BuildRequires:	erlang-eunit
BuildRequires:	erlang-lager
BuildRequires:	erlang-openacd
Requires:	erlang-erts%{?_isa} >= R15B
Requires:	erlang-kernel%{?_isa}
Requires:	erlang-stdlib%{?_isa} >= R15B
BuildRequires:	erlang-lager
BuildRequires:	erlang-openacd

%description
Dialplan plug-in for OpenACD


%prep
%setup -n %{name}-%{version}

%build
make

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_libdir}/erlang/lib/%{realname}-%{version}/ebin
mkdir -p %{buildroot}%{_libdir}/erlang/lib/%{realname}-%{version}/include
install -m 644 ebin/%{realname}.app %{buildroot}%{_libdir}/erlang/lib/%{realname}-%{version}/ebin
install -m 644 ebin/*.beam %{buildroot}%{_libdir}/erlang/lib/%{realname}-%{version}/ebin
install -m 644 include/*.hrl %{buildroot}%{_libdir}/erlang/lib/%{realname}-%{version}/include

%clean
rm -rf %{buildroot}

%files
%dir %{_libdir}/erlang/lib/%{realname}-%{version}
%dir %{_libdir}/erlang/lib/%{realname}-%{version}/ebin
%dir %{_libdir}/erlang/lib/%{realname}-%{version}/include
%{_libdir}/erlang/lib/%{realname}-%{version}/ebin/%{realname}.app
%{_libdir}/erlang/lib/%{realname}-%{version}/ebin/*.beam
%{_libdir}/erlang/lib/%{realname}-%{version}/include/*.hrl


%changelog
* Mon Feb 25 2013 Jan Vincent Liwanag - 2.0.0-1
- Initial release

