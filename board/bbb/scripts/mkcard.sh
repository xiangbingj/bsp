#!/bin/bash

usage() {
	echo "Usage: $0 <drive>"
	exit 1;
}

if [ $# -ne 1 ]; then
	usage
fi

DISK="$1"

# Make sure SD card is not mounted
umount "${DISK}*"

# Erase SD card
# Erasing a full card can be slow; only erase partially into last partition
dd if=/dev/zero of="${DISK}" bs=32M count=400

# AM335x can boot from SD via two methods:
# 1. Raw Mode: booting image expected at one of four specific locations
# 2. FAT Mode: 'MLO' file found in root directory on an active primary
#              partition of type FAT 12/16 or FAT32
#
# We will be using FAT Mode

# Assumes sfdisk >= 2.26.x
# partition table type: dos
# partition table identifier: FAT32 with LBA
# 1st partition: 50MiB FAT32
# 2nd partition: 256MiB Linux (any Linux file system; will hold squashfs)
# 3rd partition: remaining space, Linux (writeable user partition)
# 4th partition: none
{
	echo "label: dos"
	echo "label-id: 0x0C"
	echo "start=1MiB,size=50MiB,bootable,type=c"
	echo "size=256MiB,type=83"
	echo "type=83"
	echo "write"
} | sfdisk "${DISK}"

# Format boot (FAT32) partition
# FAT32 must have at least 65,527 clusters
# At one sector per cluster and 512 bytes per sector, minimum 32 MiB
mkfs.vfat -F 32 -s 1 -S 512 -n "boot" "${DISK}1"
# Format user partition
mkfs.ext4 -L userfs "${DISK}3"
# For mkfs.ext4 >= 1.43:
# Supposedly U-Boot can't currently handle metadata_csum and 64bit
# ext4 options, so disable for now.
#mkfs.ext4 -L userfs -O ^metadata_csum,^64bit "${DISK}3"

sync
