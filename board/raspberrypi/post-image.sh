#!/bin/bash

set -e

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
GENIMAGE_CFG="${BOARD_DIR}/genimage-raspberrypi-generic.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
ROOTFS="rootfs.ext4"
SEDCMD_SDIMG=" -e '/{SDIMG_.*}/d' "

. ${BOARD_DIR}/${BOARD_NAME}.conf

for arg in "$@"
do
	case "${arg}" in
		--add-pi3-miniuart-bt-overlay)
		if ! grep -qE '^dtoverlay=' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			echo "Adding 'dtoverlay=pi3-miniuart-bt' to config.txt (fixes ttyAMA0 serial console)."
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# fixes rpi3 ttyAMA0 serial console
dtoverlay=pi3-miniuart-bt
__EOF__
		fi
		;;
		--aarch64)
		# Run a 64bits kernel (armv8)
		sed -e '/^kernel=/s,=.*,=Image,' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
		if ! grep -qE '^arm_64bit=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable 64bits support
arm_64bit=1
__EOF__
		fi

		# Enable uart console
		if ! grep -qE '^enable_uart=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable rpi3 ttyS0 serial console
enable_uart=1
__EOF__
		fi
		;;
		--gpu_mem_256=*|--gpu_mem_512=*|--gpu_mem_1024=*)
		# Set GPU memory
		gpu_mem="${arg:2}"
		sed -e "/^${gpu_mem%=*}=/s,=.*,=${gpu_mem##*=}," -i "${BINARIES_DIR}/rpi-firmware/config.txt"
		;;
		--file=*)
		FILES+=("${arg:7}")
		;;
		--rootfs=*)
		ROOTFS="${arg:9}"
		;;
		--skip-sdimg)
		SEDCMD_SDIMG=" -e '/{SDIMG_START}/,/{SDIMG_END}/d' "
		;;
	esac

done

for i in ${!FILES[*]}
do
	FILES[$i]=$(echo "\"${FILES[$i]}\"," | sed -e 's/[\/&]/\\&/g')
done
SEDCMD_BOOTFILES=" -e 's/{BOOT_FILES}/${FILES[*]}/' "
SEDCMD_ROOTFS=" -e 's/{ROOTFS}/${ROOTFS}/' "

eval "sed ${SEDCMD_BOOTFILES} ${SEDCMD_ROOTFS} ${SEDCMD_SDIMG} ${GENIMAGE_CFG}" > ${BUILD_DIR}/genimage.cfg

rm -rf "${GENIMAGE_TMP}"

genimage                           \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${BUILD_DIR}/genimage.cfg"

exit $?
