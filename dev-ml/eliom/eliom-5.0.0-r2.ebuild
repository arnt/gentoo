# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils multilib findlib

DESCRIPTION="A web framework to program client/server applications"
HOMEPAGE="http://ocsigen.org/eliom/"
SRC_URI="https://github.com/ocsigen/eliom/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1-with-linking-exception"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE="doc +ocamlopt +ppx"

RDEPEND=">=dev-lang/ocaml-4.03:=[ocamlopt?]
	>=dev-ml/js_of_ocaml-2.8.2:=
	>=www-servers/ocsigenserver-2.5:=
	>=dev-ml/tyxml-4:=
	>=dev-ml/deriving-0.6:=
	>=dev-ml/reactiveData-0.2:=
	dev-ml/ocaml-ipaddr:=
	dev-ml/react:=
	dev-ml/ocaml-ssl:=
	>=dev-ml/lwt-2.5.0:=
	dev-ml/calendar:=
	dev-ml/camlp4:=
	ppx? ( >=dev-ml/ppx_tools-0.99.3:= )"
DEPEND="${RDEPEND}
	dev-ml/ocamlbuild
	dev-ml/opam"

src_prepare() {
	epatch "${FILESDIR}/"{camlp4,oc43,oc43-2}.patch \
		"${FILESDIR}/tyxml4.patch" \
		"${FILESDIR}/jsofocaml-282.patch"
}

src_compile() {
	if use ocamlopt ; then
		emake PPX=$(usex ppx true false) all
	else
		emake PPX=$(usex ppx true false) byte
	fi
	use doc && emake doc
	emake man
}

src_install() {
	opam-installer \
		--prefix="${ED}/usr" \
		--libdir="${D}/$(ocamlc -where)" \
		--docdir="${ED}/usr/share/doc/${PF}" \
		--mandir="${ED}/usr/share/man" \
		|| die
	dodoc CHANGES README.md
	if use doc ; then
		docinto client/html
		dodoc -r _build/src/lib/client/api.docdir/*
		docinto server/html
		dodoc -r _build/src/lib/server/api.docdir/*
	fi
}
