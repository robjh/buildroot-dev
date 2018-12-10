#¬/bin/bash

SNAP_NAME="linux-$(date +%y%m%d)"
MNT_DIR='./output/mnt'
#SNAP_DIR="${MNT_DIR}/snapshots"
BTRFS_RAW='./output/images/rootfs.btrfs' 
BTRFS_EXE='./output/host/bin/btrfs'
OUTPUT="./output/images/os.btrfss"
WHOAMI=`whoami`

# mount the rootfs image.
mkdir -p ${MNT_DIR}
echo Attempting to mount the btrfs image
mount ${BTRFS_RAW} ${MNT_DIR} 


# create a new snapshot of the rootfs in the right place (ie; linux-`date`)
#mkdir -p ${SNAP_DIR}
${BTRFS_EXE} subvol snapshot -r ${MNT_DIR} ${MNT_DIR}/${SNAP_NAME}

# create the stream with btrfs-send
${BTRFS_EXE} send ${MNT_DIR}/${SNAP_NAME} > ${OUTPUT}

# cleanup
${BTRFS_EXE} subvol delete ${MNT_DIR}/${SNAP_NAME}

umount ${MNT_DIR}
