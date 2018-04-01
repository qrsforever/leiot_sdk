#!/bin/bash

# Called by cmake

echo "--- $@"
if (( $# != 3 ))
then
    echo "make iotsdk parameters error!"
fi

PROTOP_DIR=$1
ROOTFS_DIR=$2
VERSION=$3

rm -rf $ROOTFS_DIR
mkdir -p $ROOTFS_DIR

if [ -d bin ]
then
    cp -aprf bin $ROOTFS_DIR
fi

if [ -d lib ]
then
    cp -aprf lib $ROOTFS_DIR
fi

if [ -d $PROTOP_DIR/include ]
then
    cp -aprf $PROTOP_DIR/include $ROOTFS_DIR
fi

CMD=`which tar`

if [[ x$CMD != x ]]
then
    tar zcf ${ROOTFS_DIR}.${VERSION}.tar.gz $ROOTFS_DIR
else
    CMD=`which zip`
    if [[ x$CMD != x ]]
    then
        $CMD -q -r ${ROOTFS_DIR}.${VERSION}.zip $ROOTFS_DIR
    fi
fi
