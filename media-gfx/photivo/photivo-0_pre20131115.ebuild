# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit qt4-r2

DESCRIPTION="Photo processor for RAW and Bitmap images"
HOMEPAGE="http://www.photivo.org"
SRC_URI="https://dev.gentoo.org/~hwoarang/distfiles/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gimp"

RDEPEND="dev-qt/qtcore:4
	dev-qt/qtgui:4
	|| ( virtual/jpeg:62 media-libs/jpeg:62 )
	media-gfx/exiv2
	media-libs/tiff
	media-libs/libpng
	media-libs/cimg
	media-libs/lcms:2
	>=media-libs/lensfun-0.2.8-r1
	sci-libs/fftw:3.0
	media-libs/liblqr
	media-gfx/graphicsmagick[q16,-lcms]
	gimp? ( media-gfx/gimp )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${PN}-${PV/0_pre/}

src_prepare() {
	# remove ccache dependency and fix lensfun header path
	local File
	for File in $(find "${S}" -type f); do
		if grep -sq ccache ${File}; then
			sed -e 's/ccache//' -i "${File}"
		fi
		if grep -sq "lensfun.h" ${File}; then
		   	sed -e 's/lensfun\.h/lensfun\/lensfun.h/' -i ${File}
		fi
	done

	# useless check (no pkgconfig file is provided)
	sed -e "/PKGCONFIG += CImg/d" \
		-i photivoProject/photivoProject.pro || die
	qt4-r2_src_prepare
}

src_configure() {
	local config="WithSystemCImg"
	if use gimp ; then
		config+=" WithGimp"
	fi

	eqmake4 "CONFIG+=${config}"
}

src_install() {
	qt4-r2_src_install

	if use gimp; then
		exeinto $(gimptool-2.0 --gimpplugindir)/plug-ins
		doexe ptGimp
		doexe "mm extern photivo.py"
	fi
}
