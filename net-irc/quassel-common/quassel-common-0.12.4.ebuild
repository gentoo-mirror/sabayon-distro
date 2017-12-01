# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils eutils

MY_P=${P/-common}
MY_PN=${PN/-common}
EGIT_REPO_URI=( "https://github.com/${MY_PN}/${MY_PN}" "git://git.${MY_PN}-irc.org/${MY_PN}" )
[[ "${PV}" == "9999" ]] && inherit git-r3

DESCRIPTION="Qt/KDE IRC client supporting a remote daemon (common files)"
HOMEPAGE="http://quassel-irc.org/"
[[ "${PV}" == "9999" ]] || SRC_URI="http://quassel-irc.org/pub/${MY_P}.tar.bz2"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="kde"

RDEPEND="kde? (
	kde-frameworks/oxygen-icons:* )"

DEPEND="${RDEPEND}
		!<net-irc/quassel-${PV}
		!<net-irc/quassel-client-${PV}"
		# -core(-bin) does not depend on it

S="${WORKDIR}/${MY_P}"

src_configure() {
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_make po
}

src_install() {
	# cmake-utils_src_install

	local mypath

	dodoc ChangeLog AUTHORS

	# /usr/share/icons/hicolor
	for mypath in icons/hicolor/*/*/*.{svgz,png}; do
		if [ -f "${mypath}" ]; then
			insinto "/usr/share/${mypath%/*}"
			doins "${mypath}"
		fi
	done

	# /usr/share/quassel/icons/oxygen
	if ! use kde; then
		dodoc icons/README.Oxygen
		local mydest
		for mydest in COPYING AUTHORS CONTRIBUTING; do
			newdoc "icons/oxygen/${mydest}" "${mydest}.Oxygen"
		done

		for mypath in icons/oxygen/*/*/*.{svgz,png}; do
			if [ -f "${mypath}" ]; then
				insinto "/usr/share/quassel/${mypath%/*}"
				doins "${mypath}"
			fi
		done

		insinto /usr/share/quassel/icons/oxygen
		doins icons/oxygen/index.theme
	fi

	doicon icons/oxygen/48x48/apps/quassel.png

	# /usr/share/quassel/stylesheets
	for mypath in data/stylesheets/*.qss; do
		if [ -f "${mypath}" ]; then
			insinto /usr/share/quassel/stylesheets
			doins "${mypath}"
		fi
	done

	# /usr/share/quassel/scripts
	for mypath in data/scripts/*; do
		if [ -f "${mypath}" ]; then
			insinto /usr/share/quassel/scripts
			doins "${mypath}"
		fi
	done

	# /usr/share/quassel/translations
	for mypath in "${CMAKE_BUILD_DIR}"/po/*.qm; do
		insinto /usr/share/quassel/translations
		doins "${mypath}"
	done

	insinto /usr/share/quassel
	doins data/networks.ini

	use kde && doins data/quassel.notifyrc
}
