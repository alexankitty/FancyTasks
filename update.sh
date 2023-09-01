#!/bin/sh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
sh $SCRIPT_DIR/build.sh
kpackagetool5 -u $SCRIPT_DIR/release/FancyTasks.tar.gz
killall plasmashell
kstart5 plasmashell
cp ./package/FancyTasks.png ~/.local/share/icons/hicolor/256x256/apps/FancyTasks.png
