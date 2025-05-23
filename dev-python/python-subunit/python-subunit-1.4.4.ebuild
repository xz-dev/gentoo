# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} pypy3_11 )

inherit distutils-r1 multilib-minimal autotools

MY_P=subunit-${PV}
DESCRIPTION="A streaming protocol for test results"
HOMEPAGE="
	https://launchpad.net/subunit/
	https://pypi.org/project/python-subunit/
"
SRC_URI="
	https://github.com/testing-cabal/subunit/archive/${PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S=${WORKDIR}/${MY_P}

LICENSE="Apache-2.0 BSD"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE="static-libs test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-python/testtools-0.9.34[${PYTHON_USEDEP}]
	dev-python/iso8601[${PYTHON_USEDEP}]
"
DEPEND="
	${RDEPEND}
	>=dev-libs/check-0.9.11[${MULTILIB_USEDEP}]
	>=dev-util/cppunit-1.13.2[${MULTILIB_USEDEP}]
	>=virtual/pkgconfig-0-r1
	test? (
		dev-python/fixtures[${PYTHON_USEDEP}]
		dev-python/hypothesis[${PYTHON_USEDEP}]
		dev-python/testscenarios[${PYTHON_USEDEP}]
	)
"

PATCHES=(
	"${FILESDIR}/subunit-1.4.0-werror.patch"
)

src_prepare() {
	mv all_tests.py python/ || die

	distutils-r1_src_prepare
	eautoreconf
	multilib_copy_sources
}

multilib_src_configure() {
	ECONF_SOURCE=${S} \
	econf \
		--enable-shared \
		$(use_enable static-libs static)
}

multilib_src_compile() {
	default
	multilib_is_native_abi && distutils-r1_src_compile
}

python_test() {
	cd python || die
	"${EPYTHON}" -m testtools.run -v all_tests.test_suite ||
		die "Testing failed with ${EPYTHON}"
}

multilib_src_test() {
	multilib_is_native_abi && distutils-r1_src_test
}

multilib_src_install() {
	local targets=(
		install-include_subunitHEADERS
		install-pcdataDATA
		install-libLTLIBRARIES
	)
	emake DESTDIR="${D}" "${targets[@]}"

	multilib_is_native_abi && distutils-r1_src_install
}

multilib_src_install_all() {
	einstalldocs
	find "${D}" -name '*.la' -delete || die
}
