#!/bin/sh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
kpackagetool5 -u $SCRIPT_DIR/package
kquitapp5 plasmashell
kstart5 plasmashell
cp ./FancyTasks.png ~/.local/share/icons/hicolor/256x256/apps/FancyTasks.png