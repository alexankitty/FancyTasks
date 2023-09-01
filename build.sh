#!/bin/sh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR/package/translate/
sh ./merge
sh ./build
cd $SCRIPT_DIR
mkdir $SCRIPT_DIR/build
mkdir $SCRIPT_DIR/release
cp -r $SCRIPT_DIR/package/contents $SCRIPT_DIR/build
cp $SCRIPT_DIR/package/metadata.json $SCRIPT_DIR/build
cp $SCRIPT_DIR/package/FancyTasks.png $SCRIPT_DIR/build
cd $SCRIPT_DIR/build
tar cf $SCRIPT_DIR/release/FancyTasks.tar.gz .
cd $SCRIPT_DIR
rm -rf $SCRIPT_DIR/build