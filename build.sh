#!/bin/bash
if [ $# -eq 1 ]; then
    tag=$1
else
    echo "please provide image tag"
    exit 9
fi

export CUR_DIR=$(cd "$(dirname "$0")";pwd)
export WORK_DIR=/work

rm -rf $CUR_DIR/_install

docker run \
    -e http_proxy=http://web-proxy.x.net:8080 \
    -e https_proxy=http://web-proxy.x.net:8080 \
    -v $CUR_DIR:$WORK_DIR \
    -w $WORK_DIR \
    ubuntu:16.04 \
    /bin/bash /work/builder.sh
if [ $? -ne 0 ]; then
    exit 1
fi

rm -f $CUR_DIR/_install/bin/busybox
rm -f $CUR_DIR/_install/bin/ash

docker build -t localhost:5000/busybox:$tag .
if [ $? -ne 0 ]; then
    exit 2
fi



