#!/bin/sh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
sh $SCRIPT_DIR/build.sh
kpackagetool5 -u $SCRIPT_DIR/release/FancyTasks.tar.gz
QML_DISABLE_DISK_CACHE=true plasmawindowed alexankitty.fancytasks