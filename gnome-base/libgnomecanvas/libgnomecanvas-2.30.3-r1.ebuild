# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

GNOME_TARBALL_SUFFIX="bz2"
inherit gnome2 multilib-minimal virtualx

DESCRIPTION="The Gnome 2 Canvas library"
HOMEPAGE="https://library.gnome.org/devel/libgnomecanvas/stable/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~loong ~mips ppc ppc64 sparc x86 ~amd64-linux ~x86-linux ~x64-macos ~x64-solaris"
IUSE="glade"

RDEPEND=">=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}]
	>=x11-libs/gtk+-2.24.23:2[${MULTILIB_USEDEP}]
	>=media-libs/libart_lgpl-2.3.21-r2[${MULTILIB_USEDEP}]
	>=x11-libs/pango-1.36.3[${MULTILIB_USEDEP}]
	glade? ( >=gnome-base/libglade-2.6.4-r1:2.0[${MULTILIB_USEDEP}] )"

DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-lang/perl-5
	sys-devel/gettext
	dev-util/glib-utils
	>=dev-util/intltool-0.35
	virtual/pkgconfig"

src_prepare() {
	gnome2_src_prepare

	# Fix intltoolize broken file, see upstream #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in \
		|| die "sed failed"

	# Don't build demos that are not even installed, bug #226299
	sed 's/^\(SUBDIRS =.*\)demos\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
		|| die "sed 2 failed"
}

multilib_src_configure() {
	ECONF_SOURCE=${S} \
	gnome2_src_configure \
		$(use_enable glade) \
		--disable-static

	ln -s "${S}"/docs/reference/html docs/reference/html || die
}

multilib_src_install() {
	gnome2_src_install
}

multilib_src_test() {
	virtx emake check
}
