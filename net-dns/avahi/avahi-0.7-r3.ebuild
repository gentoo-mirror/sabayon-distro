# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit multilib-build

DESCRIPTION="System which facilitates service discovery on a local network (meta package)"
HOMEPAGE="http://avahi.org/"
SRC_URI=""

KEYWORDS="~amd64 ~arm ~x86"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="autoipd bookmarks dbus doc gdbm gtk gtk3 howl-compat +introspection ipv6 kernel_linux mdnsresponder-compat mono nls python qt5 selinux test"

COMMON_DEPEND="=net-dns/avahi-base-${PVR}[autoipd=,bookmarks=,dbus=,doc=,gdbm=,howl-compat=,introspection=,ipv6=,mdnsresponder-compat=,python=,test=,nls=,selinux=,${MULTILIB_USEDEP}]
	gtk? ( =net-dns/avahi-gtk-${PVR}[gdbm=,nls=,dbus=] )
	gtk3? ( =net-dns/avahi-gtk3-${PVR}[dbus=,gdbm=,introspection=,nls=,python=] )
	mono? ( =net-dns/avahi-mono-${PVR}[${MULTILIB_USEDEP}] )
	qt5? ( =net-dns/avahi-qt5-${PVR}[${MULTILIB_USEDEP}] )"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${DEPEND}"
