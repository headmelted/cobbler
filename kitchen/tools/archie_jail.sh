#!/bin/bash
set -e;

#echo "Kernel capabilities "
#echo "capsh --print | grep "Current:" | cut -d' ' -f3";

echo "Preparing jail";
echo "QEMU Interception Mode: ${ARCHIE_QEMU_INTERCEPTION_MODE}";

if [ "${ARCHIE_QEMU_INTERCEPTION_MODE}" == "binfmt_misc" ]; then
  
  #check_if_bind_mounts_exist=$(mount | grep "proc on ${ARCHIE_CLEANROOM_DIRECTORY}/proc type proc");

  echo "Checking cleanroom mounts for [binfmt_misc]";
  if [[ $(findmnt -M "$ARCHIE_CLEANROOM_DIRECTORY/dev/") ]]; then
  
    echo "Cleanroom has already been mounted.";
    
  else
  
    echo "Binding mounts for [${ARCHIE_ARCH}] cleanroom (for binfmt_misc/chroot method)";
  
    echo "Mounting /dev into cleanroom [$ARCHIE_CLEANROOM_DIRECTORY]";
    mount --bind /dev "$ARCHIE_CLEANROOM_DIRECTORY/dev/";
  
    echo "Mounting /sys into cleanroom [$ARCHIE_CLEANROOM_DIRECTORY]";
    mount --bind /sys "$ARCHIE_CLEANROOM_DIRECTORY/sys/";
  
    echo "Mounting /proc into cleanroom [$ARCHIE_CLEANROOM_DIRECTORY]";
    mount --bind /proc "$ARCHIE_CLEANROOM_DIRECTORY/proc/";
  
    echo "Mounting /dev/pts into cleanroom [$ARCHIE_CLEANROOM_DIRECTORY]";
    mount --bind /dev/pts "$ARCHIE_CLEANROOM_DIRECTORY/dev/pts/";
    
    if [ -d "$ARCHIE_CLEANROOM_DIRECTORY/root/kitchen/" ]; then
      echo "kitchen already exists in chroot, will not create (but will mount)";
    else
      echo "Creating kitchen inside chroot";
      mkdir "$ARCHIE_CLEANROOM_DIRECTORY/root/kitchen/";
    fi;
  
    echo "Mounting /root/kitchen into cleanroom [$ARCHIE_CLEANROOM_DIRECTORY]";
    mount --bind /root/kitchen "$ARCHIE_CLEANROOM_DIRECTORY/root/kitchen/";
    
    if [ -d "$ARCHIE_CLEANROOM_DIRECTORY/root/build/" ]; then
      echo "build already exists in chroot, will not create (but will mount)";
    else
      echo "Creating build inside chroot";
      mkdir "$ARCHIE_CLEANROOM_DIRECTORY/root/build/";
    fi;
  
    echo "Mounting /root/build into cleanroom [$ARCHIE_CLEANROOM_DIRECTORY]";
    mount --bind /root/build "$ARCHIE_CLEANROOM_DIRECTORY/root/build/";
    
    if [ -d "$ARCHIE_CLEANROOM_DIRECTORY/root/output/" ]; then
      echo "output already exists in chroot, will not create (but will mount)";
    else
      echo "Creating output inside chroot";
      mkdir "$ARCHIE_CLEANROOM_DIRECTORY/root/output/";
    fi;
  
    echo "Mounting /root/output into cleanroom [$ARCHIE_CLEANROOM_DIRECTORY]";
    mount --bind /root/output "$ARCHIE_CLEANROOM_DIRECTORY/root/output/";
    
  fi;

  echo "Executing command [$@] in [$ARCHIE_ARCH] cleanroom (with binfmt_misc/chroot method)";
  chroot $ARCHIE_CLEANROOM_DIRECTORY /bin/bash -c "export ARCHIE_ARCH=$ARCHIE_ARCH && . /root/kitchen/env/setup.sh && cd /root && $@";
  
elif [ "${ARCHIE_QEMU_INTERCEPTION_MODE}" == "ptrace" ]; then
  echo "Executing command in [$ARCHIE_ARCH] cleanroom (with proot method)";
  proot -b /root/kitchen:/home/kitchen -R $ARCHIE_CLEANROOM_DIRECTORY -q qemu-$ARCHIE_QEMU_ARCH-static "$@";
else
  echo "ERROR: No QEMU call interception mode specified for jail!";
fi

#echo "Testing fakechroot at ($ARCHIE_CLEANROOM_DIRECTORY)";
#fakechroot fakeroot chroot $ARCHIE_CLEANROOM_DIRECTORY /usr/bin/qemu-$ARCHIE_QEMU_ARCH-static -L $ARCHIE_CLEANROOM_DIRECTORY pwd;

#echo "Entering [$ARCHIE_ARCH] cleanroom ($ARCHIE_CLEANROOM_DIRECTORY) to debug fakeroot";
#fakechroot fakeroot chroot $ARCHIE_CLEANROOM_DIRECTORY /usr/bin/qemu-$ARCHIE_QEMU_ARCH-static -L $ARCHIE_CLEANROOM_DIRECTORY -D ~/kitchen/qemu.log readelf -d /bin/bash

#echo "Entering [$ARCHIE_ARCH] cleanroom ($ARCHIE_CLEANROOM_DIRECTORY) via (fakeroot) to execute command";
#fakechroot fakeroot /usr/sbin/chroot $ARCHIE_CLEANROOM_DIRECTORY /usr/bin/qemu-$ARCHIE_QEMU_ARCH-static -L $ARCHIE_CLEANROOM_DIRECTORY -D ~/kitchen/qemu.log /bin/bash -c "$@";

#echo "QEMU log:"
#cat ~/kitchen/qemu.log
