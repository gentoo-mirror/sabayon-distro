# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils subversion
ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/entropy/tags/${PV}"

DESCRIPTION="Official Sabayon Linux Package Manager Client (tagged release)"
HOMEPAGE="http://www.sabayonlinux.org"
PYTHON_MODNAME="pysqlite2"
PYSQLITE_VER="2.3.5"
PYSQLITE_DIRNAME="pysqlite"
SRC_URI="http://initd.org/pub/software/pysqlite/releases/${PYSQLITE_VER:0:3}/${PYSQLITE_VER}/pysqlite-${PYSQLITE_VER}.tar.gz"

LICENSE="GPL-2 pysqlite"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
S="${WORKDIR}"/trunk

DEPEND="~sys-apps/entropy-${PV} sys-apps/diffutils"
RDEPEND="${DEPEND}"

src_compile() {
	einfo "nothing to compile"
}

src_install() {

	##########
	#
	# Equo
	#
	#########

	dodir /usr/$(get_libdir)/entropy/client
	dodir /etc/portage

	# copying portage bashrc
	insinto /etc/portage
	mv ${S}/conf/etc-portage-bashrc ${S}/conf/bashrc
	doins ${S}/conf/bashrc

        # copy configuration
        cd ${S}/conf
        dodir /etc/entropy
        insinto /etc/entropy
        doins equo.conf
        doins repositories.conf
	
	# copy client
	cd ${S}/client
	insinto /usr/$(get_libdir)/entropy/client
	doins *.py
	doins equo

	cd ${S}
	dodir /usr/bin
	echo '#!/bin/sh' > equo
	echo 'if [ -f "/etc/profile" ]; then source /etc/profile; fi' >> equo
	echo 'cd /usr/'$(get_libdir)'/entropy/client' >> equo
	echo 'LD_LIBRARY_PATH="/usr/'$(get_libdir)'/entropy/client/lib/:/usr/'$(get_libdir)'/entropy/client/libraries/pysqlite2/" python equo "$@"' >> equo
	exeinto /usr/bin
	doexe equo

}
