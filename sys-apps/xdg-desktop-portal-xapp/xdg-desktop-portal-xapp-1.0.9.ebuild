# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson systemd

DESCRIPTION="Backend implementation for xdg-desktop-portal using Cinnamon/MATE/Xfce"
HOMEPAGE="https://github.com/linuxmint/xdg-desktop-portal-xapp/"
SRC_URI="https://github.com/linuxmint/xdg-desktop-portal-xapp/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~loong ~ppc64 ~riscv x86"

DEPEND="
	>=dev-libs/glib-2.44:2
	>=sys-apps/xdg-desktop-portal-1.5
"
RDEPEND="
	${DEPEND}
	sys-apps/xdg-desktop-portal-gtk
	>=x11-libs/xapp-2.8.4
"
BDEPEND="
	dev-util/gdbus-codegen
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=(
	# Remove orphaned gdk references
	# https://github.com/linuxmint/xdg-desktop-portal-xapp/commit/b364687b8a696c78f2d3c46e0c45c2dc28e79a33
	"${FILESDIR}/${PN}-${PV}-remove-gdk-refs.patch"
)

src_configure() {
	local emesonargs=(
		-Dsystemduserunitdir="$(systemd_get_userunitdir)"
	)
	meson_src_configure
}
