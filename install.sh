#!/bin/sh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
sh $SCRIPT_DIR/package/translate/merge
sh $SCRIPT_DIR/package/translate/build
kpackagetool5 -i $SCRIPT_DIR/package
mkdir -p ~/.local/share/icons/hicolor/256x256/apps/
cp ./FancyTasks.png ~/.local/share/icons/hicolor/256x256/apps/FancyTasks.png
