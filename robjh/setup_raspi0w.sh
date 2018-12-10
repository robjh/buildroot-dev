#!/bin/bash

# Get the pre-set arguments, and the post build scripts, to the post script
POST_SCRIPT_ARGS=$(grep BR2_ROOTFS_POST_SCRIPT_ARGS ./configs/raspberrypi0w_defconfig | sed -e 's/[\/&]/\\&/g')
POST_BUILD_SCRIPTS=$(grep BR2_ROOTFS_POST_BUILD_SCRIPT ./configs/raspberrypi0w_defconfig | sed -e 's/[\/&]/\\&/g')

eval ${POST_SCRIPT_ARGS}
eval ${POST_BUILD_SCRIPTS}
mkdir -p output/build
echo ${BR2_ROOTFS_POST_SCRIPT_ARGS}
echo ${BR2_ROOTFS_POST_BUILD_SCRIPT}
sed \
	-e "s/{POST_SCRIPT_ARGS_DEFAULT}/${BR2_ROOTFS_POST_SCRIPT_ARGS}/" \
	-e "s/{POST_BUILD_SCRIPTS}/${BR2_ROOTFS_POST_BUILD_SCRIPT}/" \
	./robjh/fragment_buildroot > output/build/fragment_buildroot

#cp -a system/skeleton/* output/build/skel/
#tar xzvf robjh/fsskel_generic.tar.gz -C output/build/skel/

support/kconfig/merge_config.sh ./configs/raspberrypi0w_defconfig ./output/build/fragment_buildroot
