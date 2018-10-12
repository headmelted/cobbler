#!/bin/bash
set -e;

echo "Setting COBBLER_HOME";
export COBBLER_HOME=$HOME;

echo "COBBLER_HOME is $COBBLER_HOME";

if [ "$COBBLER_ARCH" == "amd64" ]; then
  echo "Installing base gcc and g++ for amd64";
  packages_to_install="gcc g++";
else
  echo "Installing [$COBBLER_GNU_TRIPLET] gcc and g++";
  packages_to_install="gcc-$COBBLER_GNU_TRIPLET g++-$COBBLER_GNU_TRIPLET";
  
  if [ "$COBBLER_STRATEGY" == "cross" ] || [ "$COBBLER_STRATEGY" == "hybrid" ] ; then
  
    echo "Adding cross-compilation target of [$COBBLER_ARCH]";
    dpkg --add-architecture $COBBLER_ARCH;
 
    if [ "$COBBLER_ARCH" == "i386" ] ; then
      packages_to_install="$packages_to_install g++-multilib";
    else
      packages_to_install="$packages_to_install dpkg-cross";
    fi;
    
  fi;
  
fi;

echo "Updating APT caches prior to dependency installation";
apt-get update -yq;

echo "Preparing to install dependencies";
packages_to_install="$packages_to_install $COBBLER_HOST_DEPENDENCIES";

for cobbler_dependency_package in $COBBLER_TARGET_DEPENDENCIES; do
  if [ "$COBBLER_STRATEGY" == "cross" ] ; then
    cobbler_dependency_package="$cobbler_dependency_package:$COBBLER_ARCH";
  fi;
  packages_to_install="$packages_to_install $cobbler_dependency_package";
done;

echo "Packages to install:";
echo $packages_to_install;
  
if [ "$COBBLER_STRATEGY" == "cross" ] || [ "$COBBLER_STRATEGY" == "virtualize" ] ; then
  echo "Installing dependency packages";
  apt-get install -y $packages_to_install;
else
  echo "Installing dependency packages in jail for [$COBBLER_ARCH]";
  $COBBLER_HOME/kitchen/env/linux/cobbler_jail.sh apt-get install -y $packages_to_install;
fi;

echo "[$HOME] is where the ♥ is";

echo "Dependencies installed";

echo "CC -----------------------"
eval "$cc_compiler -v";
echo "CXX -----------------------"
eval "$cxx_compiler -v";
echo "---------------------------"
