#!/bin/bash
if [ $# -eq 1 ]; then
    tag=$1
else
    echo "please provide image tag"
    exit 9
fi

export CUR_DIR=$(cd "$(dirname "$0")";pwd)

rm -rf $CUR_DIR/_install

docker run -v $CUR_DIR:/busybox-src -w /busybox-src lxc968/ubuntu-dev:2.1 make
if [ $? -ne 0 ]; then
    exit 1
fi

docker run -v $CUR_DIR:/busybox-src -w /busybox-src lxc968/ubuntu-dev:2.1 make install
if [ $? -ne 0 ]; then
    exit 1
fi

rm -f $CUR_DIR/_install/bin/busybox
rm -f $CUR_DIR/_install/bin/ash

docker build -t busybox-v.1.28.3:$tag .
if [ $? -ne 0 ]; then
    exit 2
fi


