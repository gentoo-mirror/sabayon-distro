# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

AVAHI_MODULE="${AVAHI_MODULE:-${PN/avahi-}}"
MY_P=${P/-${AVAHI_MODULE}}
MY_PN=${PN/-${AVAHI_MODULE}}

WANT_AUTOMAKE=1.11

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="gdbm"

inherit autotools eutils flag-o-matic multilib multilib-minimal mono-env python-r1 systemd user

DESCRIPTION="System which facilitates service discovery on a local network (mono pkg)"
HOMEPAGE="http://avahi.org/"
SRC_URI="https://github.com/lathiat/avahi/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-linux"
IUSE="dbus doc gdbm gtk introspection nls python utils"

S="${WORKDIR}/${MY_P}"

COMMON_DEPEND="
	~net-dns/avahi-base-${PV}[dbus=,gdbm=,introspection=,nls=,python=,${MULTILIB_USEDEP}]
	gtk? (
		~net-dns/avahi-gtk-${PV}[dbus=,gdbm=,introspection=,nls=,python=,${MULTILIB_USEDEP}]
		>=dev-dotnet/gtk-sharp-2
	)
"

DEPEND="${COMMON_DEPEND}
	doc? ( >=virtual/monodoc-1.1.8 )"
RDEPEND="${COMMON_DEPEND}"

pkg_setup() {
	mono-env_pkg_setup
}

src_prepare() {
	# Make gtk utils optional
	# https://github.com/lathiat/avahi/issues/24
	epatch "${FILESDIR}"/${MY_PN}-0.6.30-optional-gtk-utils.patch

	# Don't install avahi-discover unless ENABLE_GTK_UTILS, bug #359575
	# https://github.com/lathiat/avahi/issues/24
	epatch "${FILESDIR}"/${MY_PN}-0.6.31-fix-install-avahi-discover.patch

	# Fix build under various locales, bug #501664
	# https://github.com/lathiat/avahi/issues/27
	epatch "${FILESDIR}"/${MY_PN}-0.6.31-fix-locale-build.patch

	# Fix openrc-run script issue
	epatch "${FILESDIR}"/${MY_PN}-0.6.32-openrc-0.21.7-fix-init-scripts.patch

	# Drop DEPRECATED flags, bug #384743
	sed -i -e 's:-D[A-Z_]*DISABLE_DEPRECATED=1::g' avahi-ui/Makefile.am || die

	# Fix references to Lennart's home directory, bug #466210
	sed -i -e 's/\/home\/lennart\/tmp\/avahi//g' man/* || die

	# Bug #525832
	epatch_user

	# Prevent .pyc files in DESTDIR
	>py-compile

	eautoreconf

	# bundled manpages
	multilib_copy_sources
}

src_configure() {
	# those steps should be done once-per-ebuild rather than per-ABI
	use sh && replace-flags -O? -O0

	# We need to unset DISPLAY, else the configure script might have problems detecting the pygtk module
	unset DISPLAY

	multilib-minimal_src_configure
}

multilib_src_configure() {
	local myconf=( --disable-static )

	if ! multilib_is_native_abi; then
		myconf+=(
			# used by daemons only
			--disable-libdaemon
			--with-xml=none
		)
	fi

	if use python; then
		myconf+=(
			$(multilib_native_use_enable dbus python-dbus)
		)
	fi

	econf \
		--localstatedir="${EPREFIX}/var" \
		--with-distro=gentoo \
		--disable-python-dbus \
		--disable-manpages \
		--disable-xmltoman \
		--disable-monodoc \
		--disable-pygtk \
		--enable-glib \
		--enable-gobject \
		$(use_enable dbus) \
		$(multilib_native_use_enable python) \
		$(use_enable nls) \
		$(multilib_native_use_enable introspection) \
		--disable-qt3 \
		--disable-qt4 \
		--disable-gtk --disable-gtk-utils \
		--disable-gtk3 \
		$(multilib_is_native_abi && echo -n --enable-mono || echo -n --disable-mono) \
		$(multilib_is_native_abi && echo -n --enable-monodoc || echo -n --disable-monodoc) \
		$(use_enable gdbm) \
		$(systemd_with_unitdir) \
		"${myconf[@]}"
}

multilib_src_compile() {
	if multilib_is_native_abi; then
		for target in avahi-common avahi-client avahi-glib avahi-sharp; do
			cd "${BUILD_DIR}"/${target} || die
			emake || die
		done
		cd "${BUILD_DIR}" || die
		emake avahi-sharp.pc || die

		if use gtk; then
			cd "${BUILD_DIR}"/avahi-ui-sharp || die
			emake || die
			cd "${BUILD_DIR}" || die
			emake avahi-ui-sharp.pc || die
		fi
	fi
}

multilib_src_install() {
	mkdir -p "${D}/usr/bin" || die

	if multilib_is_native_abi; then
		cd "${BUILD_DIR}"/avahi-sharp || die
		emake install DESTDIR="${D}" || die
		if use gtk; then
			cd "${BUILD_DIR}"/avahi-ui-sharp || die
			emake install DESTDIR="${D}" || die
		fi
		cd "${BUILD_DIR}" || die
		dodir /usr/$(get_libdir)/pkgconfig
		insinto /usr/$(get_libdir)/pkgconfig
		doins *.pc
	fi
}

multilib_src_install_all() {
	prune_libtool_files --all
}
