# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop flag-o-matic

DESCRIPTION="Texas Instruments hand-helds emulator"
HOMEPAGE="http://lpg.ticalc.org/prj_tiemu/"
SRC_URI="http://repo.calcforge.org/debian/source/${PN}_${PV}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="dbus nls sdl threads xinerama"

RDEPEND="
	gnome-base/libglade:2.0
	sci-libs/libticables2
	sci-libs/libticalcs2
	sci-libs/libtifiles2
	sci-libs/libticonv
	x11-libs/gtk+:2
	dbus? ( >=dev-libs/dbus-glib-0.60 )
	nls? ( virtual/libintl )
	sdl? ( media-libs/libsdl )
	xinerama? ( x11-libs/libXinerama )"
DEPEND="${RDEPEND}
	xinerama? ( x11-base/xorg-proto )"
BDEPEND="
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

PATCHES=(
	"${FILESDIR}"/${P}-remove_depreciated_gtk_calls.patch
	"${FILESDIR}"/${P}-r2820.patch
	"${FILESDIR}"/${P}-fix-ftbfs-with-customized-abort-function.patch
	"${FILESDIR}"/${P}-clang16-build-fix.patch
	"${FILESDIR}"/${P}-implicit-int.patch
)

src_prepare() {
	default
	# Don't use GTK_DISABLE_DEPRECATED flags
	sed 's:-DGTK_DISABLE_DEPRECATED::g' -i configure.ac configure || die
}

src_configure() {
	# -Werror=lto-type-mismatch
	# https://bugs.gentoo.org/862381
	filter-lto

	econf \
		--disable-rpath \
		--disable-debugger \
		--disable-gdb \
		$(use_enable nls) \
		$(use_enable sdl sound) \
		$(use_enable threads) \
		$(use_enable threads threading) \
		$(use_with dbus) \
		--without-kde \
		$(use_with xinerama)
}

src_install() {
	default

	rm -f "${ED}"/usr/share/tiemu/{Manpage.txt,COPYING,RELEASE,AUTHORS,LICENSES} || die
	make_desktop_entry tiemu "TiEmu Calculator" \
		"${EPREFIX}"/usr/share/tiemu/pixmaps/icon.xpm
}
