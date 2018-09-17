#!/bin/bash
set -e;

# get.sh
#
# Clone $COBBLER_GIT_ENDPOINT into the code folder, and make the executing
# user the owner of the folder.

echo "Remove .code folder if it exists"
rm -rf $COBBLER_CLEANROOM_CODE_DIRECTORY;

echo "Creating .code folder";
mkdir $COBBLER_CLEANROOM_CODE_DIRECTORY;

echo "Retrieving code from git endpoint [$COBBLER_GIT_ENDPOINT] into [$COBBLER_CLEANROOM_CODE_DIRECTORY]";
git clone $COBBLER_GIT_ENDPOINT $COBBLER_CLEANROOM_CODE_DIRECTORY;
  
echo "Setting current owner as owner of code folder";
chown ${USER:=$(/usr/bin/id -run)}:$USER -R $COBBLER_CLEANROOM_CODE_DIRECTORY;
