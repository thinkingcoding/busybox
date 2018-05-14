#!/bin/bash

export BUILDROOT_VERSION=2018.02
export BUSYBOX_VERSION=1.28.3

export BUILDROOT_DIR=/usr/src/buildroot
export BUSYBOX_DIR=/usr/src/busybox
export WORK_DIR=/work

apt-get update && apt-get install -y \
		bzip2 \
		curl \
		gcc \
		gnupg dirmngr \
		make \
		bc \
		cpio \
		dpkg-dev \
		g++ \
		patch \
		perl \
		python \
		rsync \
		unzip \
		wget
if [ $? -ne 0 ]; then
    exit 1
fi
rm -rf /var/lib/apt/lists/*

mkdir -p $BUILDROOT_DIR
cd $BUILDROOT_DIR
curl -fsSL "http://buildroot.uclibc.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz" -o buildroot.tar.bz2
curl -fsSL "http://buildroot.uclibc.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz.sign" -o buildroot.tar.bz2.sign
tar -xf buildroot.tar.bz2 -C $BUILDROOT_DIR --strip-components 1
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys AB07D806D2CE741FB886EE50B025BA8B59C36319
gpg --verify buildroot.tar.bz2.sign
if [ $? -ne 0 ]; then
    exit 1
fi
rm buildroot.tar.bz2*
cp $WORK_DIR/buildroot.config  $BUILDROOT_DIR/.config
export gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
make clean && time make HOST_GMP_CONF_OPTS="--build='"$gnuArch"'" -j "$(nproc)" toolchain
if [ $? -ne 0 ]; then
    exit 1
fi

export PATH=$BUILDROOT_DIR/output/host/usr/bin:$PATH

mkdir -p $BUSYBOX_DIR
cd $BUSYBOX_DIR
curl -fsSL "http://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2" -o busybox.tar.bz2
curl -fsSL "http://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2.sign" -o busybox.tar.bz2.sign
tar -xf busybox.tar.bz2 -C $BUSYBOX_DIR --strip-components 1
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys C9E9416F76E610DBD09D040F47B70C55ACC9965B
gpg --verify busybox.tar.bz2.sign
if [ $? -ne 0 ]; then
    exit 1
fi
rm busybox.tar.bz2*
cp $WORK_DIR/busybox.config  $BUSYBOX_DIR/.config
#CROSS_COMPILE=$(cd $BUILDROOT_DIR/output/host/usr && ls -d -1 *-buildroot-linux-uclibc)-
make clean && time make -j "$(nproc)" CROSS_COMPILE="$(basename /usr/src/buildroot/output/host/usr/*-buildroot-linux-uclibc*)-" busybox
time make install -j "$(nproc)" CROSS_COMPILE="$(basename /usr/src/buildroot/output/host/usr/*-buildroot-linux-uclibc*)-" busybox
if [ $? -ne 0 ]; then
    exit 1
fi

$BUSYBOX_DIR/_install/bin/busybox --help
if [ $? -ne 0 ]; then
    exit 2
fi

cp -R $BUSYBOX_DIR/_install $WORK_DIR/_install
if [ $? -ne 0 ]; then
    exit 2
fi
