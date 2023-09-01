#!/bin/sh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR/package/translate/
sh ./merge
sh ./build
cd $SCRIPT_DIR
kpackagetool5 -i $SCRIPT_DIR/package
mkdir -p ~/.local/share/icons/hicolor/256x256/apps/
cp ./package/FancyTasks.png ~/.local/share/icons/hicolor/256x256/apps/FancyTasks.png
