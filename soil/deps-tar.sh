#!/usr/bin/env bash
#
# Usage:
#   ./deps-tar.sh <function name>

set -o nounset
set -o pipefail
set -o errexit

source build/common.sh  # $PREPARE_DIR, $PY27

REPO_ROOT=$(cd $(dirname $0)/.. && pwd)
readonly REPO_ROOT

DEPS_DIR=$REPO_ROOT/../oil_DEPS
readonly DEPS_DIR

#
# re2c dependency
#

download-re2c() {
  # local cache of remote files
  mkdir -p _cache
  wget --no-clobber --directory _cache \
    https://github.com/skvadrik/re2c/releases/download/1.0.3/re2c-1.0.3.tar.gz
}

build-re2c() {
  cd $REPO_ROOT/_cache
  tar -x -z < re2c-1.0.3.tar.gz

  mkdir -p $DEPS_DIR/re2c
  cd $DEPS_DIR/re2c
  $REPO_ROOT/_cache/re2c-1.0.3/configure
  make
}

#
# cmark dependency
#

readonly CMARK_VERSION=0.29.0
readonly CMARK_URL="https://github.com/commonmark/cmark/archive/$CMARK_VERSION.tar.gz"

download-cmark() {
  mkdir -p $REPO_ROOT/_cache
  wget --no-clobber --directory $REPO_ROOT/_cache $CMARK_URL
}

extract-cmark() {
  pushd $REPO_ROOT/_cache
  tar -x -z < $(basename $CMARK_URL)
  popd
}

build-cmark() {
  mkdir -p $DEPS_DIR/cmark
  pushd $DEPS_DIR/cmark

  # Configure
  cmake $REPO_ROOT/_cache/cmark-0.29.0/

  # Compile
  make

  # This tests with Python 3, but we're using cmark via Python 2.
  # It crashes on some systems due to the renaming of cgi.escape -> html.escape
  # (issue 792)
  # The 'demo-ours' test is good enough for us.
  #make test

  popd

  # Binaries are in build/src
}

symlink-cmark() {
  #sudo make install
  ln -s -f -v $DEPS_DIR/cmark/src/libcmark.so $DEPS_DIR/
  ls -l $DEPS_DIR/libcmark.so
}

#
# CPython dependency for 'make'
#

configure-python() {
  local dir=${1:-$PREPARE_DIR}

  rm -r -f $dir
  mkdir -p $dir

  local conf=$PWD/$PY27/configure 

  pushd $dir 
  time $conf
  popd
}

# Clang makes this faster.  We have to build all modules so that we can
# dynamically discover them with py-deps.
#
# Takes about 27 seconds on a fast i7 machine.
# Ubuntu under VirtualBox on MacBook Air with 4 cores (3 jobs): 1m 25s with
# -O2, 30 s with -O0.  The Make part of the build is parallelized, but the
# setup.py part is not!

readonly NPROC=$(nproc)
readonly JOBS=$(( NPROC == 1 ? NPROC : NPROC-1 ))

build-python() {
  local dir=${1:-$PREPARE_DIR}
  local extra_cflags=${2:-'-O0'}

  pushd $dir
  make clean
  # Speed it up with -O0.
  # NOTE: CFLAGS clobbers some Python flags, so use EXTRA_CFLAGS.

  time make -j $JOBS EXTRA_CFLAGS="$extra_cflags"
  #time make -j 7 CFLAGS='-O0'
  popd
}

#
# Layer Definitions
#

layer-cmark() {
  download-cmark
  extract-cmark
  build-cmark
  symlink-cmark
}

layer-re2c() {
  download-re2c
  build-re2c
}

layer-cpython() {
  configure-python
  build-python
}

"$@"
