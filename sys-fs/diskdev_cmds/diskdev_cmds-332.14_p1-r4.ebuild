# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic toolchain-funcs

MY_PV=${PV%_p*}

DESCRIPTION="HFS and HFS+ utils ported from OSX, supplies mkfs and fsck"
HOMEPAGE="http://opendarwin.org"
SRC_URI="http://darwinsource.opendarwin.org/tarballs/apsl/diskdev_cmds-${MY_PV}.tar.gz
		 mirror://gentoo/diskdev_cmds-${PV}.patch.bz2"
LICENSE="APSL-2"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ppc ppc64 x86"
DEPEND="dev-libs/openssl:0="
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${MY_PV}"

PATCHES=(
	"${WORKDIR}"/diskdev_cmds-${PV}.patch
	"${FILESDIR}"/${PN}-respect-cflags.patch
	"${FILESDIR}"/${P}-AR.patch
	"${FILESDIR}"/${P}-no-sysctl.patch
	"${FILESDIR}"/${P}-ldflags.patch
	"${FILESDIR}"/${P}-musl.patch
)

src_compile() {
	# -Werror=strict-alising
	# https://bugs.gentoo.org/863893
	# Upstream is entirely dead (since 2006!) and apple's opensource dump isn't
	# exactly where you go to report (0) bugs to an automated feed.
	#
	# Do not trust with LTO either.
	append-flags -fno-strict-aliasing
	filter-lto

	emake -f Makefile.lnx AR="$(tc-getAR)" CC="$(tc-getCC)"
}

src_install() {
	into /
	dosbin fsck_hfs.tproj/fsck_hfs
	dosbin newfs_hfs.tproj/newfs_hfs
	dosym newfs_hfs /sbin/mkfs.hfs
	dosym newfs_hfs /sbin/mkfs.hfsplus
	dosym fsck_hfs /sbin/fsck.hfs
	dosym fsck_hfs /sbin/fsck.hfsplus
	doman newfs_hfs.tproj/newfs_hfs.8
	newman newfs_hfs.tproj/newfs_hfs.8 mkfs.hfs.8
	newman newfs_hfs.tproj/newfs_hfs.8 mkfs.hfsplus.8
	doman fsck_hfs.tproj/fsck_hfs.8
	newman fsck_hfs.tproj/fsck_hfs.8 fsck.hfs.8
	newman fsck_hfs.tproj/fsck_hfs.8 fsck.hfsplus.8
}
