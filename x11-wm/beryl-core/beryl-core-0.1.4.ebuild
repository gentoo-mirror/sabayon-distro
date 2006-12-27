# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/beryl-core/beryl-core-0.1.2.ebuild,v 1.1 2006/11/15 04:04:47 tsunam Exp $

inherit autotools

DESCRIPTION="Beryl window manager for AIGLX and XGL"
HOMEPAGE="http://beryl-project.org"
SRC_URI="http://releases.beryl-project.org/${PV}/${P}.tar.bz2
	http://releases.beryl-project.org/${PV}/beryl-mesa-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
LANGS="ca_ES de_DE es_AR es_ES fr_FR hu_HU it_IT ja_JP ko_KR ru_RU pl_PL 
pt_BR pt_PT sv_FI sv_SE uk_UA zh_CN zh_HK zh_TW"

DEPEND=">=x11-base/xorg-server-1.1.1-r1
	>=x11-libs/gtk+-2.8.0
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXrandr
	x11-libs/startup-notification"

RDEPEND="${DEPEND}
	x11-apps/xdpyinfo"

PDEPEND="~x11-plugins/beryl-plugins-${PV}"

src_compile() {
	eautoreconf

	econf --with-berylmesadir="${WORKDIR}/beryl-mesa" || die "econf failed"
	emake -j1 || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
