# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="LightDM meta package"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/LightDM"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~x86"
IUSE="audit +gtk +introspection kde qt4 qt5 +gnome"
REQUIRED_USE="|| ( gtk kde )"

DEPEND="~x11-misc/lightdm-base-${PV}[introspection=]
	qt4? ( ~x11-misc/lightdm-qt4-${PV} )
	qt5? ( ~x11-misc/lightdm-qt5-${PV} )"
RDEPEND="${DEPEND}"
PDEPEND="
	gtk? ( x11-misc/lightdm-gtk-greeter )
	kde? ( x11-misc/lightdm-kde )"
