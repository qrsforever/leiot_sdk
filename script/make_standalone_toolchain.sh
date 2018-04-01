#!/bin/bash

NDK_CMD=`which ndk-build`
if [[ x"$NDK_CMD" == x ]]
then
    echo "Error not set ndk-build path "
    exit -1
fi

NDK_DIR=`dirname $NDK_CMD`
SCRIPT_SHELL="${NDK_DIR}/build/tools/make_standalone_toolchain.py"

if [[ ! -x $SCRIPT_SHELL ]]
then
    echo "$SCRIPT_SHELL is not executable!"
    exit -1
fi

$SCRIPT_SHELL --api=$1 --arch=$2 --install-dir=$3
