# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

DESCRIPTION="Sabayon Dracut Configuration"
HOMEPAGE="https://www.sabayon.org/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="sys-fs/btrfs-progs
	sys-fs/mdadm
	sys-fs/lvm2
	sys-boot/plymouth
	sys-kernel/dracut
"
DEPEND="${RDEPEND}"

src_unpack () {
	mkdir -p "${S}" || die
}

src_install () {
	insinto /etc/dracut.conf.d/
	newins "${FILESDIR}"/sabayon.conf 99-sabayon.conf

	exeinto /usr/bin/
	doexe "${FILESDIR}"/sabayon-dracut
}
