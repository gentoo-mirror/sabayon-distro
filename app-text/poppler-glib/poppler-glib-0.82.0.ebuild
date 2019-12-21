# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils toolchain-funcs xdg-utils

MY_PN=poppler
MY_P=poppler${P#${PN}}
DESCRIPTION="Glib bindings for poppler"
HOMEPAGE="https://poppler.freedesktop.org/"
SRC_URI="https://poppler.freedesktop.org/poppler-${PV}.tar.xz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~arm"
SLOT="0/92"

IUSE="cairo cjk curl cxx debug doc +introspection +jpeg +jpeg2k +lcms nss png tiff +utils"
S="${WORKDIR}/poppler-${PV}"

# No test data provided
RESTRICT="test"

BDEPEND="
	dev-util/glib-utils
	virtual/pkgconfig
"
DEPEND="
	cairo? (
		dev-libs/glib:2
		x11-libs/cairo
		introspection? ( dev-libs/gobject-introspection:= )
	)
"
RDEPEND="${DEPEND}
	~app-text/poppler-base-${PV}[cjk=,cxx=,jpeg=,jpeg2k=,lcms=,png=,tiff=,utils=,curl=,debug=,doc=,nss=]
"

PATCHES=(
	"${FILESDIR}/${MY_PN}-0.60.1-qt5-dependencies.patch"
	"${FILESDIR}/${MY_PN}-0.28.1-fix-multilib-configuration.patch"
	"${FILESDIR}/${MY_PN}-0.82.0-respect-cflags.patch"
	"${FILESDIR}/${MY_PN}-0.61.0-respect-cflags.patch"
	"${FILESDIR}/${MY_PN}-0.57.0-disable-internal-jpx.patch"
)
src_prepare() {

	cmake-utils_src_prepare

	# Clang doesn't grok this flag, the configure nicely tests that, but
	# cmake just uses it, so remove it if we use clang
	if [[ ${CC} == clang ]] ; then
		sed -e 's/-fno-check-new//' -i cmake/modules/PopplerMacros.cmake || die
	fi

	if ! grep -Fq 'cmake_policy(SET CMP0002 OLD)' CMakeLists.txt ; then
		sed -e '/^cmake_minimum_required/acmake_policy(SET CMP0002 OLD)' \
			-i CMakeLists.txt || die
	else
		einfo "policy(SET CMP0002 OLD) - workaround can be removed"
	fi
}

src_configure() {
	xdg_environment_reset
	local mycmakeargs=(
		-DBUILD_GTK_TESTS=OFF
		-DBUILD_QT5_TESTS=OFF
		-DBUILD_CPP_TESTS=OFF
		-DENABLE_SPLASH=ON
		-DENABLE_ZLIB=ON
		-DENABLE_ZLIB_UNCOMPRESS=OFF
		-DENABLE_UNSTABLE_API_ABI_HEADERS=ON
		-DUSE_FLOAT=OFF
		-DWITH_Cairo=$(usex cairo)
		-DENABLE_LIBCURL=$(usex curl)
		-DENABLE_CPP=$(usex cxx)
		-DWITH_JPEG=$(usex jpeg)
		-DENABLE_DCTDECODER=$(usex jpeg libjpeg none)
		-DENABLE_LIBOPENJPEG=$(usex jpeg2k openjpeg2 none)
		-DENABLE_CMS=$(usex lcms lcms2 none)
		-DWITH_NSS3=$(usex nss)
		-DWITH_PNG=$(usex png)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Core=ON
		-DWITH_TIFF=$(usex tiff)
		-DENABLE_UTILS=$(usex utils)
	)
	use cairo && mycmakeargs+=( -DWITH_GObjectIntrospection=$(usex introspection) )

	cmake-utils_src_configure
}

src_install() {
	DESTDIR="${ED}" cmake-utils_src_make glib/install

	local utils_destdir=${T}/utils-destdir
	rm -rf "${utils_destdir}" || die
	mkdir "${utils_destdir}" || die
	DESTDIR="${utils_destdir}" cmake-utils_src_make utils/install

	if use cairo; then
		# As below with the executables.
		insinto /usr/include/poppler
		doins \
			poppler/CairoFontEngine.h \
			poppler/CairoOutputDev.h \
			poppler/CairoRescaleBox.h
		# Other utils are installed in poppler-base, but that package does not
		# depend on Cairo.
		dobin "${utils_destdir}/usr/bin/pdftocairo"
		doman "${utils_destdir}/usr/share/man/man1/pdftocairo.1"
	fi

	# install pkg-config data
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${BUILD_DIR}"/poppler-glib.pc
	use cairo && doins "${BUILD_DIR}"/poppler-cairo.pc

	# live version doesn't provide html documentation
	if use cairo && use doc && [[ ${PV} != *9999* ]]; then
		# For now install gtk-doc there
		insinto /usr/share/gtk-doc/html/poppler
		doins -r "${S}"/glib/reference/html/*
	fi
}
