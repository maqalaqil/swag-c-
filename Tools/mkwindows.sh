#!/bin/sh

# Build Windows distribution (alaqilwin-2.0.x.zip) from source tarball (alaqil-2.0.x.tar.gz)
# Requires running in either:
# - MinGW environment
# - Linux using MinGW cross compiler
# - Cygwin using MinGW compiler

# path to zip program
zip=

# options for configure
extraconfigureoptions=
compileflags="-O2 -Wall -Wextra"

if test x$1 != x; then
    version=$1
    if test x$2 != x; then
        zip=$2;
        echo zip: $zip;
    fi
else
    echo "Usage: mkwindows.sh version [zip]"
    echo "       Build alaqil Windows distribution from source tarball. Works on Cygwin, MinGW or Linux"
    echo "       version should be 2.0.x"
    echo "       zip is full path to zip program - default is /c/cygwin/bin/zip on MinGW, zip on Linux and Cygwin"
    exit 1
fi

uname=`uname -a`
mingw=`echo "$uname" | grep -i mingw`
linux=`echo "$uname" | grep -i linux`
cygwin=`echo "$uname" | grep -i cygwin`
if test "$mingw"; then
  echo "Building native Windows executable on MinGW";
  if test x$zip = x; then
    zip=/c/cygwin/bin/zip
  fi
else 
  if test "$linux"; then
    echo "Building native Windows executable on Linux"
    if test x$zip = x; then
      zip=zip
    fi
    echo "Checking that mingw 32-bit gcc is installed/available"
    if test -n "`which i686-w64-mingw32-gcc`" ; then
      i686-w64-mingw32-gcc --version || exit 1
      i686-w64-mingw32-g++ --version || exit 1
      extraconfigureoptions="--host=i686-w64-mingw32 --build=i686-linux"
      # Statically link so that libstdc++-6.dll and libgcc_s_sjlj-1.dll don't have to be shipped
      compileflags="$compileflags -static-libgcc -static-libstdc++"
    elif test -n "`which i586-mingw32msvc-gcc`" ; then
      i586-mingw32msvc-gcc --version || exit 1
      i586-mingw32msvc-g++ --version || exit 1
      extraconfigureoptions="--host=i586-mingw32msvc --build=i686-linux"
    else
      echo "Could not detect mingw gcc - please install mingw-w64 package."
      exit 1;
    fi
  else 
    if test "$cygwin"; then
      echo "Building native Windows executable on Cygwin"
      if test x$zip = x; then
        zip=zip
      fi
      compileflags="$compileflags -mno-cygwin"
    else
      echo "Unknown platform. Requires either Linux or MinGW."
      exit 1;
    fi
  fi
fi

export CFLAGS="$compileflags"
export CXXFLAGS="$compileflags"

alaqilbasename=alaqil-$version
alaqilwinbasename=alaqilwin-$version
tarball=$alaqilbasename.tar.gz
pcre_tarball=`ls pcre-*.tar.*`

if ! test -f "$pcre_tarball"; then
  echo "Could not find PCRE tarball. Please download a PCRE source tarball from http://www.pcre.org"
  echo "and place in the same directory as the alaqil tarball."
  exit 1
fi

if test -f "$tarball"; then
    builddir=build-$version
    if test -e $builddir; then
      echo "Deleting directory $builddir..."
      rm -rf $builddir
    fi
    echo "Creating directory $builddir..."
    mkdir $builddir
    cd $builddir
    echo "Unzipping tarball..."
    tar -zxf ../$tarball
    sleep 2 # fix strange not finding newly created directory
    if test -d $alaqilbasename; then
      mv $alaqilbasename $alaqilwinbasename
      tar -zxf ../$tarball
      cd $alaqilbasename
      (cd ../.. && cp $pcre_tarball $builddir/$alaqilbasename)
      echo Running: Tools/pcre-build.sh $extraconfigureoptions
      ./Tools/pcre-build.sh $extraconfigureoptions
      echo Running: ./configure $extraconfigureoptions --without-alllang
      ./configure $extraconfigureoptions --without-alllang
      echo "Compiling (quietly)..."
      make > build.log
      echo "Simple check to see if alaqil.exe runs..."
      env LD_LIBRARY_PATH= PATH= ./alaqil.exe -version || exit 1
      echo "Simple check to see if ccache-alaqil.exe runs..."
      env LD_LIBRARY_PATH= PATH= ./CCache/ccache-alaqil.exe -V || exit 1
      echo "Creating $alaqilwinbasename.zip..."
      cd ..
      cp $alaqilbasename/alaqil.exe $alaqilwinbasename
      cp $alaqilbasename/CCache/ccache-alaqil.exe $alaqilwinbasename/CCache
      cp $alaqilbasename/Lib/alaqilwarn.swg $alaqilwinbasename/Lib
      sleep 2 # fix strange not finding alaqil.exe
      echo "Unzip into a directory of your choice. Please read the README file as well as Doc\Manual\Windows.html for installation instructions." > alaqil_windows_zip_comments.txt
      rm -f ../$alaqilwinbasename.zip
      $zip -q -r -9 -z < alaqil_windows_zip_comments.txt ../$alaqilwinbasename.zip $alaqilwinbasename
      rm -f alaqil_windows_zip_comments.txt
      echo "Cleaning up..."
      cd ..
      rm -rf $builddir
      echo "Finished building $alaqilwinbasename.zip"
    else
      echo "Expecting tarball to create directory: $alaqilbasename but it does not exist"
      exit 1
    fi
else
    echo tarball missing: $tarball 
    exit 1
fi

exit 0
