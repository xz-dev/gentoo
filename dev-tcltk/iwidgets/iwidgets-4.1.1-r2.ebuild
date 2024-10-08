# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit virtualx autotools

BASE_URI_ITCLTK="https://downloads.sourceforge.net/incrtcl/%5BIncr%20Tcl_Tk%5D-4-source"
ITCL_VER=4.1.1
ITK_VER=4.1.0

DESCRIPTION="Widget collection for incrTcl/incrTk"
HOMEPAGE="http://incrtcl.sourceforge.net/itcl/"
SRC_URI="
	https://downloads.sourceforge.net/incrtcl/%5BIncr%20Widgets%5D/${PV}/${P}.tar.gz
	${BASE_URI_ITCLTK}/itcl%20${ITCL_VER}/itcl${ITCL_VER}.tar.gz
	${BASE_URI_ITCLTK}/itk%20${ITK_VER}/itk${ITK_VER}.tar.gz"

LICENSE="HPND Old-MIT tcltk"
SLOT="0"
KEYWORDS="amd64 ppc sparc x86 ~amd64-linux ~x86-linux"
RESTRICT="!test? ( test )"

DEPEND="
	>=dev-tcltk/itcl-${ITCL_VER}
	>=dev-tcltk/itk-${ITK_VER}"
RDEPEND="${DEPEND}"

QA_CONFIG_IMPL_DECL_SKIP=(
	stat64 # used to test for Large File Support
)

PATCHES=( "${FILESDIR}"/${P}-dash.patch )

src_prepare() {
	default
	sed \
		-e "/^\(LIB\|SCRIPT\)_INSTALL_DIR =/s|lib|$(get_libdir)|" \
		-i Makefile.in || die

	eautoreconf

	# Bug 115470
	rm doc/panedwindow.n

	rm tests/hierarchy.test || die
}

src_configure() {
	(cd ../itcl${ITCL_VER}; ./configure)
	econf \
		--with-tcl="${EPREFIX}"/usr/$(get_libdir) \
		--with-tk="${EPREFIX}"/usr/$(get_libdir) \
		--with-itcl="${WORKDIR}"/itcl${ITCL_VER} \
		--with-itk="${WORKDIR}"/itk${ITK_VER}
}

src_compile() {
	:
}

src_test() {
	virtx default
}

src_install() {
	default

	# demos are in the wrong place:
	mv "${ED}/usr/$(get_libdir)/${PN}${PV}/demos" "${ED}/usr/share/doc/${PF}/"
}
