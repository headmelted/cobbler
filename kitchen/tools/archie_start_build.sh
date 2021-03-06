#!/bin/bash
set -e;

echo "Setting ARCHIE_HOME";
export ARCHIE_HOME=$HOME;

#echo "Setting environment";
#. ~/kitchen/env/linux/setup.sh;

#echo "Checking for $ARCHIE_GIT_ENDPOINT";
#if [ "$ARCHIE_GIT_ENDPOINT" != "" ]; then
#  echo "Archie is pointed at a git endpoint";
#  . $ARCHIE_HOME/kitchen/env/linux/archie_get_sources.sh;
#else
#  echo "Archie is not pointed at a git endpoint, assuming the current project is the one to build";
#fi;

. $ARCHIE_HOME/kitchen/env/setup.sh;

if [ "$ARCHIE_STRATEGY" == "emulate" ]; then
  echo "Entering jail to start build in new bash shell";
  . $ARCHIE_HOME/kitchen/tools/archie_jail.sh '/root/kitchen/tools/archie_build.sh';
else
  echo "Starting build in new bash shell [$build_command]";
  /bin/bash -c '/root/kitchen/tools/archie_build.sh';
fi;
