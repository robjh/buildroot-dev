#!/bin/bash

SECTOR_SIZE=512
TARGET=/dev/sdb
TARGET_BOOT=1
TARGET_ROOTFS=2
BOOT_IMG=output/images/boot.vfat
BOOT_SIZE=$(stat --printf="%s" ${BOOT_IMG})
BOOT_SECTORS=$((${BOOT_SIZE}/${SECTOR_SIZE}))
ROOT_START=$((${BOOT_SECTORS}+1))
#SFDISK=./output/host/sbin/sfdisk
SFDISK=sfdisk
MKFSBTRFS=./output/host/usr/bin/mkfs.btrfs
BTRFS=./output/host/usr/bin/btrfs
BTRFS_OPTS="compress"
MOUNT_POINT=./output/mnt

if [ ! -f ./output/images/os.btrfss ];
then
	./robjh/make_btrfs_stream.sh
fi

${SFDISK} -q ${TARGET} << EOF
start=1,size=${BOOT_SECTORS},type=c,bootable
type=83
EOF
blockdev --rereadpt ${TARGET}
ls -alh ${TARGET}*

dd if=${BOOT_IMG} of=${TARGET}${TARGET_BOOT}
${MKFSBTRFS} -f ${TARGET}${TARGET_ROOTFS}

mkdir -p ${MOUNT_POINT}


mount -o "${BTRFS_OPTS}" ${TARGET}${TARGET_ROOTFS} ${MOUNT_POINT}
${BTRFS} subvol create ${MOUNT_POINT}/\@snap/
${BTRFS} subvol create ${MOUNT_POINT}/\@conf/
echo "buildroot_rpi0w" > ${MOUNT_POINT}/\@conf/hostname
cat ./output/images/os.btrfss | ${BTRFS} receive ${MOUNT_POINT}/\@snap/
SNAPSHOT=`${BTRFS} subvol list -r  ${MOUNT_POINT}/\@snap/ | awk '{print $9}'`

${BTRFS} subvol snapshot ${MOUNT_POINT}/\@snap/${SNAPSHOT} ${MOUNT_POINT}/@a

umount ${TARGET}${TARGET_ROOTFS}
