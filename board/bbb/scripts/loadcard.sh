#!/bin/bash

usage() {
	echo "Usage: $0 <drive> <img_dir>"
	exit 1;
}

fail() {
	echo "$1"
	exit 1;
}

if [ $# -ne 2 ]; then
	usage
fi

DISK="$1"
IMGDIR="$2"

# Make sure SD card is not mounted
umount "${DISK}"*

# Copy boot files to boot partition
mkdir mnt_boot || fail "Could not make mnt_boot"
mount "${DISK}1" mnt_boot || fail "Could not mount mnt_boot"
cp "${IMGDIR}/MLO" mnt_boot || fail "Could not copy U-Boot SPL"
cp "${IMGDIR}/u-boot.img" mnt_boot || fail "Could not copy U-Boot"
cp "${IMGDIR}/uEnv.txt" mnt_boot || fail "Could not copy uEnv.txt"
cp "${IMGDIR}/zImage" mnt_boot || fail "Could not copy kernel"
cp "${IMGDIR}/am335x-boneblack.dtb" mnt_boot || fail "Could not copy device tree"
sync
umount mnt_boot || fail "Failure unmounting mnt_boot"
rm -fr mnt_boot

# Copy squashfs to rootfs partition
dd if="${IMGDIR}/rootfs.squashfs" of="${DISK}2" bs=32M || \
	fail "Could not copy rootfs"
sync
