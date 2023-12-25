#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/platform/soc/soc.ap-ahb/20600000.sdio/by-name/recovery:36700160:7a6504eeab20a7c552e0bbe95acf9a5518a0b9cd; then
  applypatch -b /system/etc/recovery-resource.dat EMMC:/dev/block/platform/soc/soc.ap-ahb/20600000.sdio/by-name/boot:36700160:433a71ee53ea74ac6920748e676c885dc513ce64 EMMC:/dev/block/platform/soc/soc.ap-ahb/20600000.sdio/by-name/recovery 7a6504eeab20a7c552e0bbe95acf9a5518a0b9cd 36700160 433a71ee53ea74ac6920748e676c885dc513ce64:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
