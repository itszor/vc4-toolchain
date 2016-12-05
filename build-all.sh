#!/bin/bash

set -e

SCRIPTDIR="$(dirname "$0")"
HERE="$(cd "$SCRIPTDIR" && pwd)"
PARALLEL="-j 2"

# Remove this if you don't want to mess with CGEN.
WITHCGEN="--enable-cgen-maint"
# WITHCGEN=

# Set this to false to disable C++ (speed up build a bit).
WITHCXX=true

in_list () {
  local needle=$1
  local haystackname=$2
  local -a haystack
  eval "haystack=( "\${$haystackname[@]}" )"
  for x in "${haystack[@]}"; do
    if [ "$x" = "$needle" ]; then
      return 0
    fi
  done
  return 1
}

declare -a BUILDLIST
BUILDLIST=()

while [ $# -gt 0 ]; do
  case "$1" in
    binutils|gcc1|newlib|gcc2)
      BUILDLIST=( "${BUILDLIST[@]}" $1 )
      ;;
    -no-c++)
      WITHCXX=false
      ;;
    *)
      echo "Unknown option '$1'."
      exit 1
      ;;
  esac
  shift
done

if [ "${#BUILDLIST}" -eq 0 ]; then
  BUILDLIST=("binutils" "gcc1" "newlib" "gcc2")
fi

if [ "$WITHCGEN" ] && ! [ -h "$HERE"/binutils-vc4/cgen ]; then
  echo "Setting symlink for CGEN..."
  pushd "$HERE/binutils-vc4"
  ln -s ../cgen/cgen .
  popd
fi

if $WITHCXX; then
  LANGUAGES="c,c++"
  EXTRABUILD2OPTS="--with-newlib"
else
  LANGUAGES="c"
  EXTRABUILD2OPTS=
fi

if in_list binutils BUILDLIST; then
echo
echo "*********************"
echo "* Building binutils *"
echo "*********************"
echo

rm -rf binutils-build
mkdir binutils-build
pushd binutils-build
../binutils-vc4/configure --target=vc4-elf --prefix="$HERE"/prefix --disable-werror $WITHCGEN
make $PARALLEL
make $PARALLEL install
popd
fi

if in_list gcc1 BUILDLIST; then
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
fi

if in_list newlib BUILDLIST; then
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
fi

if in_list gcc2 BUILDLIST; then
echo
echo "************************"
echo "* Building stage 2 GCC *"
echo "************************"
echo

rm -rf gcc-build-2
mkdir gcc-build-2
pushd gcc-build-2
../gcc-vc4/configure --target=vc4-elf --prefix="$HERE"/prefix --disable-nls \
  --disable-ssp --enable-languages=$LANGUAGES --disable-decimal-float \
  --enable-threads --disable-libatomic --disable-libsanitizer \
  --disable-libquadmath --disable-lto --enable-sjlj-exceptions $EXTRABUILD2OPTS
make $PARALLEL
make $PARALLEL install
popd
fi
