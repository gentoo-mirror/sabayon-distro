# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Sabayon Official Calamares base modules"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="https://github.com/Sabayon/calamares-sabayon/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="CC-BY-SA-4.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-admin/calamares[networkmanager,upower]"
RDEPEND="${DEPEND}
    !!app-misc/calamares-sabayon-base-modules"

S="${WORKDIR}/calamares-sabayon-${PV}"

src_install() {
        insinto "/etc/calamares/"
        doins -r "${FILESDIR}/modules-conf/"*
        insinto "/usr/lib/calamares/modules/"
        doins -r "${S}/"*
        insinto "/etc/"
        newins "${FILESDIR}/locale.gen" "locale.gen.bak"
}
