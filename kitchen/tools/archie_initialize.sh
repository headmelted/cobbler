#!/bin/bash

echo "Setting ARCHIE_HOME";
export ARCHIE_HOME=$HOME;

echo "Initializing environment for [${ARCHIE_STRATEGY}/${ARCHIE_ARCH}]";
. $ARCHIE_HOME/kitchen/env/setup.sh;

if [ "${ARCHIE_STRATEGY}" == "hybrid" ] || [ "${ARCHIE_STRATEGY}" == "emulate" ]; then

  echo "Creating cleanroom [$ARCHIE_CLEANROOM_DIRECTORY]";
  mkdir "$ARCHIE_CLEANROOM_DIRECTORY";
  
  echo "Updating APT";
  apt-get update -yq;
  
  echo "Forcing RUNLEVEL to 1 for binfmt-support";
  export RUNLEVEL=1;
  
  echo "Installing wget, qemu-user-static and binfmt-support for prebootstrap";
  apt-get install -y wget qemu-user-static binfmt-support;
  
  echo "Emulators available:";
  update-binfmts --display;
  
  echo "Downloading rootfs from prebootstrap for [${ARCHIE_STRATEGY}] image";
  wget -c "https://github.com/headmelted/prebootstrap/releases/download/Oct-18/prebootstrap_stretch_minbase_${ARCHIE_ARCH}_rootfs.tar.gz" -O - | tar -xz -C "${ARCHIE_CLEANROOM_DIRECTORY}/";
  
  echo "Copying QEMU-${ARCHIE_QEMU_ARCH}-static into jail";
  cp "/usr/bin/qemu-${ARCHIE_QEMU_ARCH}-static" "${ARCHIE_CLEANROOM_DIRECTORY}/usr/bin";
  
  echo "Testing binfmt-support in jail";
  chroot $ARCHIE_CLEANROOM_DIRECTORY apt-get update -yq;
  
  echo "Testing architecture in jail";
  chroot $ARCHIE_CLEANROOM_DIRECTORY dpkg --print-architecture;
  
fi;

chmod +x $ARCHIE_HOME/kitchen/tools/*.sh;
chmod +x $ARCHIE_HOME/kitchen/env/setup.sh;

if [ "$ARCHIE_STRATEGY" == "emulate" ]; then
  echo "Entering jail to start build in new bash shell";
  . $ARCHIE_HOME/kitchen/tools/archie_jail.sh /bin/bash -c '/root/kitchen/tools/archie_install_dependencies.sh';
else
  echo "Starting build in new bash shell [$build_command]";
  /bin/bash -c '/root/kitchen/tools/archie_install_dependencies.sh';
fi;
