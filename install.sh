#!/bin/sh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
kpackagetool5 -i $SCRIPT_DIR
mkdir -p ~/.local/share/icons/hicolor/256x256/apps/
cp ./FancyTasks.png ~/.local/share/icons/hicolor/256x256/apps/FancyTasks.png
