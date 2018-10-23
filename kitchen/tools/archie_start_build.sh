#!/bin/bash
set -e;

#echo "Setting environment";
#. ~/kitchen/env/linux/setup.sh;

#echo "Checking for $ARCHIE_GIT_ENDPOINT";
#if [ "$ARCHIE_GIT_ENDPOINT" != "" ]; then
#  echo "Archie is pointed at a git endpoint";
#  . $ARCHIE_HOME/kitchen/env/linux/archie_get_sources.sh;
#else
#  echo "Archie is not pointed at a git endpoint, assuming the current project is the one to build";
#fi;

chmod +x $ARCHIE_HOME/kitchen/tools/*.sh;
chmod +x $ARCHIE_HOME/build/build.sh;

if [ "$ARCHIE_STRATEGY" == "emulate" ]; then
  echo "Entering jail to start build in new bash shell";
  . $ARCHIE_HOME/kitchen/tools/archie_jail.sh '/root/kitchen/tools/archie_install_dependencies.sh';
  . $ARCHIE_HOME/kitchen/tools/archie_jail.sh '/root/kitchen/env/setup.sh && /root/build/build.sh';
else
  echo "Starting build in new bash shell [$build_command]";
  /bin/bash -c "/root/kitchen/tools/archie_install_dependencies.sh"
  /bin/bash -c "/root/kitchen/env/setup.sh && /root/build/build.sh";
fi;
