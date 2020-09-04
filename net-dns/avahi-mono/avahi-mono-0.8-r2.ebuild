# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

AVAHI_MODULE="${AVAHI_MODULE:-${PN/avahi-}}"
MY_P=${P/-${AVAHI_MODULE}}
MY_PN=${PN/-${AVAHI_MODULE}}

PYTHON_COMPAT=( python3_{6,7,8} )
PYTHON_REQ_USE="gdbm"

inherit autotools eutils flag-o-matic mono-env python-r1 systemd

DESCRIPTION="System which facilitates service discovery on a local network (mono pkg)"
HOMEPAGE="http://avahi.org/"
SRC_URI="https://github.com/lathiat/avahi/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-linux"
IUSE="dbus doc gdbm gtk introspection nls python"

S="${WORKDIR}/${MY_P}"

COMMON_DEPEND="
	~net-dns/avahi-base-${PV}[dbus=,gdbm=,introspection=,nls=,python=]
	gtk? (
		~net-dns/avahi-gtk-${PV}[dbus=,gdbm=,nls=]
		dev-dotnet/gtk-sharp:2
	)
"

DEPEND="${COMMON_DEPEND}
	dev-util/glib-utils
	doc? ( >=virtual/monodoc-1.1.8 )"
RDEPEND="${COMMON_DEPEND}"

pkg_setup() {
	mono-env_pkg_setup
}

src_prepare() {
	default

	# Prevent .pyc files in DESTDIR
	>py-compile

	eautoreconf
}

src_configure() {
	# those steps should be done once-per-ebuild rather than per-ABI
	use sh && replace-flags -O? -O0
	use python && python_setup

	local myconf=(
		--disable-static
		--localstatedir="${EPREFIX}/var"
		--with-distro=gentoo
		--disable-python-dbus
		--disable-manpages
		--disable-xmltoman
		--disable-monodoc
		--disable-pygobject
		--enable-glib
		--enable-gobject
		$(use_enable dbus)
		$(use_enable python)
		$(use_enable nls)
		$(use_enable introspection)
		--disable-qt3
		--disable-qt4
		--disable-qt5
		--disable-gtk
		--disable-gtk3
		--enable-mono
		--enable-monodoc
		$(use_enable gdbm)
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
	)

	if use python; then
		myconf+=(
			$(use_enable dbus python-dbus)
		)
	fi

	econf "${myconf[@]}"
}

src_compile() {
	for target in avahi-common avahi-client avahi-glib avahi-sharp; do
		emake -C "${target}" || die
	done
	emake avahi-sharp.pc || die

	if use gtk; then
		emake -C avahi-ui-sharp || die
		emake avahi-ui-sharp.pc || die
	fi
}

src_install() {
	mkdir -p "${D}/usr/bin" || die

	emake -C avahi-sharp install DESTDIR="${D}" || die
	if use gtk; then
		emake -C avahi-ui-sharp install DESTDIR="${D}" || die
	fi
	dodir /usr/$(get_libdir)/pkgconfig
	insinto /usr/$(get_libdir)/pkgconfig
	doins *.pc

	find "${ED}" -name '*.la' -type f -delete || die
}

