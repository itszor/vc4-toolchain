#!/bin/bash

set -e

SCRIPTDIR="$(dirname "$0")"
HERE="$(readlink -f "$SCRIPTDIR")"
PARALLEL="-j 2"

echo
echo "*********************"
echo "* Building binutils *"
echo "*********************"
echo

rm -rf binutils-build
mkdir binutils-build
pushd binutils-build
../binutils-vc4/configure --target=vc4-elf --prefix="$HERE"/prefix --disable-werror --enable-cgen-maint
make $PARALLEL
make $PARALLEL install
popd

echo
echo "************************"
echo "* Building stage 1 GCC *"
echo "************************"
echo

rm -rf gcc-build
mkdir gcc-build
pushd gcc-build
../gcc-vc4/configure --target=vc4-elf --prefix="$HERE"/prefix --disable-nls \
  --disable-ssp --enable-languages=c --without-headers --with-newlib \
  --disable-decimal-float --disable-threads --disable-libatomic \
  --disable-libitm --disable-libsanitizer --disable-libquadmath \
  --disable-lto --enable-sjlj-exceptions
make $PARALLEL
make $PARALLEL install
popd

echo
echo "*****************************"
echo "* Building Newlib C library *"
echo "*****************************"
echo

rm -rf newlib-build
mkdir newlib-build
pushd newlib-build
export PATH="$HERE"/prefix/bin:$PATH
../newlib/configure --target=vc4-elf --prefix="$HERE"/prefix
make $PARALLEL
make $PARALLEL install
popd

echo
echo "************************"
echo "* Building stage 2 GCC *"
echo "************************"
echo

rm -rf gcc-build-2
mkdir gcc-build-2
pushd gcc-build-2
../gcc-vc4/configure --target=vc4-elf --prefix="$HERE"/prefix --disable-nls \
  --disable-ssp --enable-languages=c --disable-decimal-float \
  --disable-threads --disable-libatomic --disable-libitm \
  --disable-libsanitizer --disable-libquadmath --disable-lto \
  --enable-sjlj-exceptions
make $PARALLEL
make $PARALLEL install
popd
