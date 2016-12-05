#!/bin/bash

# DO_TESTS=("check-c" "check-c++")
DO_TESTS=("check-c" "check-gcc-c++")
# DO_TESTS=("check-gcc-c++" "check-target-libstdc++-v3")
# DO_TESTS=("check-gcc-c++")

TARGETBOARD=vc4-sim
#TARGETBOARD=vc4-teststub

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
export PATH="$thisdir/rpirun":"$thisdir/resim/vc4emul":"$thisdir/prefix/bin":$PATH
make -k "${DO_TESTS[@]}" RUNTESTFLAGS="--target_board=$TARGETBOARD $*"
popd >& /dev/null
resdir=$(get_test_results_dir)
echo "Copying results to $resdir"
for res in "${DO_TESTS}"; do
  case "$res" in
    check-c)
      cp -f "$thisdir/gcc-build-2/gcc/testsuite/gcc/gcc.sum" "$thisdir/gcc-build-2/gcc/testsuite/gcc/gcc.log" "$resdir"
      ;;
    check-c++|check-gcc-c++|check-target-libstdc++-v3)
      cp -f "$thisdir/gcc-build-2/gcc/testsuite/g++/g++.sum" "$thisdir/gcc-build-2/gcc/testsuite/g++/g++.log" "$resdir"
      cp -f "$thisdir/gcc-build-2/vc4-elf/libstdc++-v3/testsuite/libstdc++.sum" "$thisdir/gcc-build-2/vc4-elf/libstdc++-v3/testsuite/libstdc++.log" "$resdir"
      ;;
    *)
      ;;
  esac
done

