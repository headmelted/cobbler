#!/bin/bash

# This script should be imported at the root level in order
# to retain /kitchen as the current directory, which Cobbler
# depends on to reconcile further steps in the build process.

echo "Running all cook steps (get, build, package, test)";
. ./steps/cook.sh get build package test;
