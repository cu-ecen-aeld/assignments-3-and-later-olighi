#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.6.1
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
echo "testing"
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE mrproper
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE defconfig
    make -j4 ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE all
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE modules
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE dtbs

fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/$ARCH/boot/Image ${OUTDIR}

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories


echo "Creating rootfs into ${OUTDIR}"
cd "$OUTDIR"
mkdir rootfs
cd rootfs
mkdir bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log

if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
    make defconfig
else
    cd ${OUTDIR}/busybox
fi

# TODO: Make and install busybox
echo "Making busybox...."
make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE

echo "Installing busybox...."
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install


echo "Library dependencies"
cd ${OUTDIR}/rootfs
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
BASE_LIB_DIR=$(dirname $(which ${CROSS_COMPILE}gcc))/../aarch64-none-linux-gnu/libc
echo "Copy ld_linux"
sudo cp  ${BASE_LIB_DIR}/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib

echo "copy ${BASE_LIB_DIR}/lib64/libm.so.6 ${OUTDIR}/rootfs/lib"
sudo cp  ${BASE_LIB_DIR}/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64

echo "/lib64/libresolv.so.2"
sudo cp  ${BASE_LIB_DIR}/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64
echo "/lib64/libc.so.6 "
sudo cp  ${BASE_LIB_DIR}/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64
# TODO: Make device nodes

cd ${OUTDIR}/rootfs
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1
# TODO: Clean and build the writer utility
echo "Cleaning and making writer for target plateform"
cd ${FINDER_APP_DIR}
make ARCH=$ARCH CROSS_COMPILE=${CROSS_COMPILE} clean
make ARCH=$ARCH CROSS_COMPILE=${CROSS_COMPILE} all


# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs

DEST_DIR=${OUTDIR}/rootfs/home
cp ${FINDER_APP_DIR}/writer $DEST_DIR
cp ${FINDER_APP_DIR}/finder.sh $DEST_DIR
cp ${FINDER_APP_DIR}/finder-test.sh $DEST_DIR
cp ${FINDER_APP_DIR}/autorun-qemu.sh $DEST_DIR

#mkdir ${OUTDIR}/rootfs/home/conf
cp -r ${FINDER_APP_DIR}/conf ${OUTDIR}/rootfs
cp -r ${FINDER_APP_DIR}/conf ${OUTDIR}/rootfs/home

# TODO: Chown the root directory
cd ${OUTDIR}/rootfs
sudo chown -R root:root *

# TODO: Create initramfs.cpio.gz
cd ${OUTDIR}/rootfs
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
cd ${OUTDIR}
gzip -f initramfs.cpio
