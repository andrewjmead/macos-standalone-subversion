#!/bin/bash

log_header() {
    local input_string="$1"
    echo "--"
    echo "$input_string"
    echo "--"
}

SCRIPT_DIR=$(dirname "$(realpath "$0")")

rm -rf source
mkdir source

rm -rf build
mkdir build

log_header "Downloading APR"
curl https://dlcdn.apache.org//apr/apr-1.7.4.tar.gz -o source/apr-1.7.4.tar.gz
tar -xvzf source/apr-1.7.4.tar.gz -C source

log_header "Downloading APR-Util"
curl https://dlcdn.apache.org//apr/apr-util-1.6.3.tar.gz -o source/apr-util-1.6.3.tar.gz
tar -xvzf source/apr-util-1.6.3.tar.gz -C source

log_header "Downloading OpenSSL"
curl https://openssl.org/source/openssl-3.3.0.tar.gz -o source/openssl-3.3.0.tar.gz
tar -xvzf source/openssl-3.3.0.tar.gz -C source

log_header "Downloading SQLite"
curl https://www.sqlite.org/2024/sqlite-autoconf-3460000.tar.gz -o source/sqlite-autoconf-3460000.tar.gz
tar -xvzf source/sqlite-autoconf-3460000.tar.gz -C source

log_header "Downloading Serf"
curl https://www.apache.org/dist/serf/serf-1.3.10.tar.bz2 -o source/serf-1.3.10.tar.bz2 -L
bunzip2 source/serf-1.3.10.tar.bz2
tar -xvzf source/serf-1.3.10.tar -C source

log_header "Downloading Subversion"
curl https://dlcdn.apache.org/subversion/subversion-1.14.3.tar.gz -o source/subversion-1.14.3.tar.gz
tar -xvzf source/subversion-1.14.3.tar.gz -C source

log_header "Installing APR"
pushd .
cd source/apr-1.7.4
./Configure --enable-static --disable-shared --prefix="$SCRIPT_DIR/build/apr"
make
make install
popd

log_header "Installing APR-Util"
pushd .
cd source/apr-util-1.6.3
./Configure --enable-static --disable-shared --prefix="$SCRIPT_DIR/build/apu" --with-apr="$SCRIPT_DIR/build/apr"
make
make install
popd

log_header "Installing OpenSSL"
pushd .
cd source/openssl-3.3.0
./Configure darwin64-arm64-cc no-shared --prefix="$SCRIPT_DIR/build/openssl"
make
make install
popd

log_header "Installing SQLite"
pushd .
cd source/sqlite-autoconf-3460000
./Configure --enable-static --disable-shared --prefix="$SCRIPT_DIR/build/sqlite"
make
make install
popd

log_header "Installing Serf"
pushd .
cd source/serf-1.3.10
scons APR="$SCRIPT_DIR/build/apr" APU="$SCRIPT_DIR/build/apu" OPENSSL="$SCRIPT_DIR/build/openssl" PREFIX="$SCRIPT_DIR/build/serf" APR_STATIC=yes
scons install
popd

log_header "Installing Subversion"
pushd .
cd source/subversion-1.14.3
./Configure  --enable-static --disable-shared --prefix="$SCRIPT_DIR/build/subversion" --with-serf="$SCRIPT_DIR/build/serf" --with-sqlite="$SCRIPT_DIR/build/sqlite" --with-apr="$SCRIPT_DIR/build/apr" --with-apr-util="$SCRIPT_DIR/build/apu" --with-lz4=internal --with-utf8proc=internal
make
make install
popd
