#!/bin/bash
set -e;

echo "Marking kitchen env scripts executable";
chmod +x ~/kitchen/env/linux/*.sh;

echo "Marking kitchen steps scripts executable";
chmod +x ~/kitchen/steps/*.sh;

. ~/kitchen/env/linux/setup.sh;
. ~/kitchen/env/linux/display.sh;

echo "------------ DEPENDENCY PACKAGE INSTALL LIST ------------"
echo "${COBBLER_DEPENDENCY_PACKAGES}"
echo "---------------------------------------------------------"

echo "Starting compilation inside build jail";
. /root/kitchen/steps/cook.sh;
