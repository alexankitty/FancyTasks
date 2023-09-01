#!/bin/sh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR/package/translate/
sh ./merge
sh ./build
cd $SCRIPT_DIR
kpackagetool5 -u $SCRIPT_DIR/package
killall plasmashell
kstart5 plasmashell
cp ./package/FancyTasks.png ~/.local/share/icons/hicolor/256x256/apps/FancyTasks.png
