#!/bin/bash

get_test_results_dir () {
  local base
  local n=1
  base="testresults-$(date +%F)"
  while [ -d "$base-$n" ]; do
    n=$(( n + 1 ))
  done
  mkdir "$base-$n"
  echo "$base-$n"
}

thisdir="$(dirname "$0")"
thisdir="$(readlink -f "$thisdir")"

if ! [ -x "$thisdir"/resim/vc4emul/vc4emul ]; then
  set -e
  echo "Building vc4emul..."
  pushd "$thisdir"/resim
  cmake -G "Unix Makefiles"
  make -j 2
  popd
  echo "Done."
fi

pushd "$thisdir"/gcc-build-2 >& /dev/null
sed "s,BOARD_DIR_LOCATION,$thisdir/resim/vc4emul," < "$thisdir/resim/vc4emul/site-orig.exp" > "$thisdir/resim/vc4emul/site.exp"
export DEJAGNU="$thisdir/resim/vc4emul/site.exp"
export PATH="$thisdir/resim/vc4emul":$PATH
make check-gcc RUNTESTFLAGS="--target_board=vc4-sim $*"
popd >& /dev/null
resdir=$(get_test_results_dir)
echo "Copying results to $resdir"
cp "$thisdir/gcc-build-2/gcc/testsuite/gcc/gcc.sum" "$thisdir/gcc-build-2/gcc/testsuite/gcc/gcc.log" "$resdir"
