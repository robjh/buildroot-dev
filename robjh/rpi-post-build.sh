#!/bin/sh

cat <<EOF >> ${TARGET_DIR}/etc/fstab
/dev/mmcblk0p1  /boot/esp       vfat    defaults,ro           0 0
/dev/mmcblk0p2  /.snap          btrfs   defaults,subvol=@snap 0 0
/dev/mmcblk0p2  /etc/conf       btrfs   defaults,subvol=@conf 0 0
EOF

cat <<EOF > ${TARGET_DIR}/etc/profile.d/ps1.sh
# Overwrite the PS1 set in /etc/profile
PS1='\${debian_chroot:+(\$debian_chroot)}\u@\h:\w\\$ '
EOF

mkdir -p \
	${TARGET_DIR}/boot/esp
	${TARGET_DIR}/etc/conf \
	${TARGET_DIR}/.snap

rm ${TARGET_DIR}/etc/hostname
echo raspi_generic > ${TARGET_DIR}/etc/conf/hostname
ln -sfr ${TARGET_DIR}/etc/conf/hostname ${TARGET_DIR}/etc/hostname
