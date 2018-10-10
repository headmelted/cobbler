#!/bin/bash
set -e;

#echo "Setting environment";
#. ~/kitchen/env/linux/setup.sh;

#echo "Checking for $COBBLER_GIT_ENDPOINT";
#if [ "$COBBLER_GIT_ENDPOINT" != "" ]; then
#  echo "Cobbler is pointed at a git endpoint";
#  . $COBBLER_HOME/kitchen/env/linux/cobbler_get_sources.sh;
#else
#  echo "Cobbler is not pointed at a git endpoint, assuming the current project is the one to build";
#fi;

build_command=". $COBBLER_HOME/kitchen/env/linux/cobbler_install_dependencies.sh && . /build.sh"

if [ "$COBBLER_STRATEGY" == "emulate" ]; then
  echo "Entering jail to start build in new bash shell";
  cobbler_jail /bin/bash -c "$build_command";
else
  echo "Starting build in new bash shell [$build_command]";
  /bin/bash -c "$build_command";
fi;
