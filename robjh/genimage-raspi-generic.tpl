image boot.vfat {
  vfat {
    files = {
      "rpi-firmware/bootcode.bin",
      "rpi-firmware/cmdline.txt",
      "rpi-firmware/config.txt",
      "rpi-firmware/fixup.dat",
      "rpi-firmware/start.elf",
      "rpi-firmware/overlays",
      "${DTB}",
      "${KERNEL}"
    }
  }
  size = 32M
}
