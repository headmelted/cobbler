#!/bin/bash

COBBLER_TAG_SETTINGS=(${COBBLER_DOCKER_TAG//-/ });

echo "Setting Cobbler strategy and arch from tag";
export COBBLER_STRATEGY=${COBBLER_TAG_SETTINGS[0]};
export COBBLER_ARCH=${COBBLER_TAG_SETTINGS[1]};

echo "Setting Cobbler environment for all architectures";
export COBBLER_OS_DISTRIBUTION_NAME=debian;
export COBBLER_OS_RELEASE_NAME=stretch;

echo "Setting Cobbler environment for [$COBBLER_ARCH]"
. ~/kitchen/env/linux/$COBBLER_ARCH.sh;

echo "Setting cleanroom paths";
if [ $COBBLER_STRATEGY == "hybrid" ]; then
  export COBBLER_CLEANROOM_ROOT_DIRECTORY=/etc/qemu-binfmt/$COBBLER_QEMU_PACKAGE_ARCH/cleanroom;
else
  export COBBLER_CLEANROOM_ROOT_DIRECTORY=/root/kitchen/cleanroom;
fi;

export COBBLER_CLEANROOM_RELEASE_DIRECTORY=$COBBLER_CLEANROOM_ROOT_DIRECTORY/$COBBLER_OS_RELEASE_NAME;
export COBBLER_CLEANROOM_DIRECTORY=$COBBLER_CLEANROOM_RELEASE_DIRECTORY/$COBBLER_ARCH;

echo "Setting code and output paths";
export COBBLER_OUTPUT_DIRECTORY=~/output;
export COBBLER_CODE_DIRECTORY=~/code;

echo "Matching npm_config_arch to npm_config_target_arch. THIS MAY BE WRONG - CONTACT ME IF THIS IS THE CASE."
export npm_config_arch=$npm_config_target_arch;

echo "Setting compiler configuration for [$COBBLER_STRATEGY]";

COBBLER_CROSS_LIB_PATH="/usr/lib/$COBBLER_GNU_TRIPLET";

pkg_config_path=""
linkage_list=""

if [ $COBBLER_STRATEGY == "cross" ]; then
  linkage_list="-L $COBBLER_CROSS_LIB_PATH -I/usr/include/$COBBLER_GNU_TRIPLET";
  pkg_config_path="/usr/share/pkgconfig:$COBBLER_CROSS_LIB_PATH/pkgconfig";
  for package in $COBBLER_TARGET_DEPENDENCIES; do
    linkage_list="$linkage_list -I/usr/lib/$COBBLER_GNU_TRIPLET/$package/include"
  done
else
  if [ "$COBBLER_STRATEGY" == "hybrid" ]; then
    linkage_list="--sysroot=$COBBLER_CLEANROOM_DIRECTORY -L $COBBLER_CLEANROOM_DIRECTORY$COBBLER_CROSS_LIB_PATH -I$COBBLER_CLEANROOM_DIRECTORY/usr/include/$COBBLER_GNU_TRIPLET"
    pkg_config_path="$COBBLER_CLEANROOM_DIRECTORY/usr/share/pkgconfig:$COBBLER_CLEANROOM_DIRECTORY$COBBLER_CROSS_LIB_PATH/pkgconfig";
    for package in $COBBLER_TARGET_DEPENDENCIES; do
      linkage_list="$linkage_list -I$COBBLER_CLEANROOM_DIRECTORY/usr/lib/$COBBLER_GNU_TRIPLET/$package/include -I$COBBLER_CLEANROOM_DIRECTORY/usr/include/$package"
    done
  else
    echo "TODO: OTHER STRATEGY LINKING";
  fi;
fi;

echo "Setting CC and CXX with linking for [$COBBLER_STRATEGY]";
if [ "$COBBLER_ARCH" == "i386" ]; then
  cc_compiler="x86_64-linux-gnu-gcc -m32";
  cxx_compiler="x86_64-linux-gnu-g++ -m32";
else
  cc_compiler="$COBBLER_GNU_TRIPLET-gcc";
  cxx_compiler="$COBBLER_GNU_TRIPLET-g++";
fi;

echo "CC is [$cc_compiler]";
echo "CXX is [$cxx_compiler]";

export CC="$cc_compiler $linkage_list";
export CXX="$cxx_compiler $linkage_list";

echo "Setting package config path";
export PKG_CONFIG_PATH=$pkg_config_path;

echo "Setting TARGETCC and TARGETCXX to CC and CXX";
export TARGETCC=$CC;
export TARGETCXX=$CXX;
 
if [ $COBBLER_STRATEGY == "cross" ]; then
  echo "Setting HOSTCC and HOSTCXX to x86_64 for cross";
  export HOSTCC='x86_64-linux-gnu-gcc';
  export HOSTCXX='x86_64-linux-gnu-g++';
else
  echo "Setting HOSTCC and HOSTCXX to CC and CXX";
  export HOSTCC=$CC;
  export HOSTCXX=$CXX;
fi;

echo "Linking Options ----------------------------------------------"
echo $linkage_list;
echo "--------------------------------------------------------------"
