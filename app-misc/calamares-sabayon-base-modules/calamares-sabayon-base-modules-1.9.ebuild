# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Sabayon Official Calamares base modules"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI=""
LICENSE="CC-BY-SA-4.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=app-admin/calamares-3.1.12[networkmanager,upower]"
RDEPEND="${DEPEND}"

S="${FILESDIR}"
src_install() {
	insinto "/etc/calamares/"
	doins -r "${S}/${PN}-conf-${PVR}/"*
	insinto "/usr/lib/calamares/modules/"
	doins -r "${S}/${P}/"*
	insinto "/etc/"
	newins "${S}/locale.gen" "locale.gen.bak"
}
