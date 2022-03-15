#!/bin/bash
export SCRIPT=$(readlink -f "$0")
export SCRIPT_DIR=$(dirname $SCRIPT)
export SCRIPT_NAME=$(basename $SCRIPT)
[ "X$DEBUG" = "XALL" -o "X${DEBUG#*$SCRIPT_NAME}" != "X$DEBUG" ] && echo "SCRIPT BEGIN $SCRIPT_NAME ${@:1}"
. $SCRIPT_DIR/common.sh

_pwd=$PWD

# Some boxen have multiple wireless interfaces.
# Removing wpasupplicate will just cause problems.
# Tell it to ignore the first (wlan0) interface instead.
# apt remove wpasupplicant -y
# [2022-03-15] This has been moved into the nexmon_builder playbook
# echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf

info "Downloading Nexmon"
git clone git@github.com:DuncanFyfe/nexmon.git
assert_directory nexmon
cd nexmon
git checkout python2
NEXDIR=$(pwd)
info "Done."

info "Build libISL"
assert_directory $NEXDIR/buildtools/isl-0.10
cd $NEXDIR/buildtools/isl-0.10
autoreconf -f -i
./configure
make
make install
assert_file /usr/local/lib/libisl.so
ln -s /usr/local/lib/libisl.so /usr/lib/arm-linux-gnueabihf/libisl.so.10
info "Done."

info "Building libMPFR"
assert_directory $NEXDIR/buildtools/mpfr-3.1.4
cd $NEXDIR/buildtools/mpfr-3.1.4
autoreconf -f -i
./configure
make
make install
assert_file /usr/local/lib/libmpfr.so
ln -s /usr/local/lib/libmpfr.so /usr/lib/arm-linux-gnueabihf/libmpfr.so.4
info "Done."

info "Setting up Build Environment"
cd $NEXDIR
source setup_env.sh
make
info "Done."

info "Downloading Nexmon_CSI"
cd $NEXDIR/patches/bcm43455c0/7_45_189/
git clone https://github.com/zeroby0/nexmon_csi.git
assert_directory nexmon_csi
info "Done."

info "Building and installing Nexmon_CSI"
cd nexmon_csi
git checkout pi-5.4.51-plus
make install-firmware
info "Done."

info "Installing makecsiparams"
cd utils/makecsiparams
make
assert_file $PWD/makecsiparams
cp $PWD/makecsiparams /usr/local/bin/mcp
info "Done."

info "Installing nexutil"
cd $NEXDIR/utilities/nexutil
make
make install
assert_file /usr/bin/nexutil
info "Done."

info "Setting up Persistance"
cd $NEXDIR/patches/bcm43455c0/7_45_189/nexmon_csi/
cd brcmfmac_5.4.y-nexmon
mv $(modinfo brcmfmac -n) ./brcmfmac.ko.orig
cp ./brcmfmac.ko $(modinfo brcmfmac -n)
depmod -a
info "Done."

info "Downloading additional scripts"
cd $_pwd
wget https://raw.githubusercontent.com/zeroby0/nexmon_csi/pi-5.4.51-plus/update.sh -O update.sh
info "Done."
info "Completed"
