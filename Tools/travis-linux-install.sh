#!/bin/bash

set -e # exit on failure (same as -o errexit)

lsb_release -a
travis_retry sudo apt-get -qq update

if [[ "$CC" == gcc-5 ]]; then
	travis_retry sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
	travis_retry sudo apt-get -qq update
	travis_retry sudo apt-get install -qq g++-5
elif [[ "$CC" == gcc-6 ]]; then
	travis_retry sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
	travis_retry sudo apt-get -qq update
	travis_retry sudo apt-get install -qq g++-6
elif [[ "$CC" == gcc-7 ]]; then
	travis_retry sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
	travis_retry sudo apt-get -qq update
	travis_retry sudo apt-get install -qq g++-7
elif [[ "$CC" == gcc-8 ]]; then
	travis_retry sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
	travis_retry sudo apt-get -qq update
	travis_retry sudo apt-get install -qq g++-8
fi

travis_retry sudo apt-get -qq install libboost-dev

WITHLANG=$alaqilLANG

case "$alaqilLANG" in
	"")     ;;
	"csharp")
		travis_retry sudo apt-get -qq install mono-devel
		;;
	"d")
		travis_retry wget http://downloads.dlang.org/releases/2014/dmd_2.066.0-0_amd64.deb
		travis_retry sudo dpkg -i dmd_2.066.0-0_amd64.deb
		;;
	"go")
		;;
	"javascript")
		case "$ENGINE" in
			"node")
				if [[ -z "$VER" ]]; then
					travis_retry sudo apt-get install -qq nodejs node-gyp
				else
					travis_retry wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.10/install.sh | bash
					export NVM_DIR="$HOME/.nvm"
					[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
					travis_retry nvm install ${VER}
					nvm use ${VER}
					travis_retry npm install -g node-gyp
				fi
				;;
			"jsc")
				travis_retry sudo apt-get install -qq libwebkitgtk-dev
				;;
			"v8")
				travis_retry sudo apt-get install -qq libv8-dev
				;;
		esac
		;;
	"guile")
		travis_retry sudo apt-get -qq install guile-2.0-dev
		;;
	"lua")
		if [[ -z "$VER" ]]; then
			travis_retry sudo apt-get -qq install lua5.2 liblua5.2-dev
		else
			travis_retry sudo add-apt-repository -y ppa:ubuntu-cloud-archive/mitaka-staging
			travis_retry sudo apt-get -qq update
			travis_retry sudo apt-get -qq install lua${VER} liblua${VER}-dev
		fi
		;;
	"mzscheme")
		travis_retry sudo apt-get -qq install racket
		;;
	"ocaml")
		# configure also looks for ocamldlgen, but this isn't packaged.  But it isn't used by default so this doesn't matter.
		travis_retry sudo apt-get -qq install ocaml ocaml-findlib
		;;
	"octave")
		if [[ -z "$VER" ]]; then
			travis_retry sudo apt-get -qq install liboctave-dev
		else
			# Travis adds external PPAs which contain newer versions of packages
			# than in baseline trusty. These newer packages prevent some of the
			# Octave packages in ppa:kwwette/octave, which rely on the older
			# packages in trusty, from installing. To prevent these kind of
			# interactions arising, clean out all external PPAs added by Travis
			# before installing Octave
			sudo rm -rf /etc/apt/sources.list.d/*
			travis_retry sudo apt-get -qq update
			travis_retry sudo add-apt-repository -y ppa:kwwette/octaves
			travis_retry sudo apt-get -qq update
			travis_retry sudo apt-get -qq install liboctave${VER}-dev
		fi
		;;
	"php")
		travis_retry sudo add-apt-repository -y ppa:ondrej/php
		travis_retry sudo apt-get -qq update
		travis_retry sudo apt-get -qq install php$VER-cli php$VER-dev
		;;
	"python")
		pip install --user pycodestyle
		if [[ "$PY3" ]]; then
			travis_retry sudo apt-get install -qq python3-dev
		fi
		WITHLANG=$alaqilLANG$PY3
		if [[ "$VER" ]]; then
			travis_retry sudo add-apt-repository -y ppa:deadsnakes/ppa
			travis_retry sudo apt-get -qq update
			travis_retry sudo apt-get -qq install python${VER}-dev
			WITHLANG=$alaqilLANG$PY3=$alaqilLANG$VER
		fi
		;;
	"r")
		travis_retry sudo apt-get -qq install r-base
		;;
	"ruby")
		if [[ "$VER" ]]; then
			travis_retry rvm install $VER
		fi
		;;
	"scilab")
		travis_retry sudo apt-get -qq install scilab
		;;
	"tcl")
		travis_retry sudo apt-get -qq install tcl-dev
		;;
esac

set +e # turn off exit on failure (same as +o errexit)
