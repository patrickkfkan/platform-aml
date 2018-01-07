#!/bin/sh

echo "Start copy Volumio."

IMAGE_KERNEL="/boot/zImage"
IMAGE_INITRD="/boot/uInitrd"
IMAGE_DTB="/boot/dtb.img"
PART_ROOT="/dev/system"
PART_DATA="/dev/data"
PART_BOOT="/dev/cache"
DIR_INSTALL="/tmp/install"

if [ ! -f $IMAGE_KERNEL ] ; then
    echo "Not KERNEL.  STOP install !!!"
    return
fi

if [ ! -f $IMAGE_INITRD ] ; then
    echo "Not INITRD.  STOP install !!!"
    return
fi

if grep -q $PART_ROOT /proc/mounts ; then
  echo "Unmounting SYSTEM partiton."
  umount -f $PART_ROOT
fi

echo "Formatting SYSTEM partition..."
mke2fs -F -q -t ext4 -m 0 $PART_ROOT
e2fsck -n $PART_ROOT
echo "done."

if grep -q $PART_DATA /proc/mounts ; then
  echo "Unmounting DATA partiton."
  umount -f $PART_DATA
fi

echo "Formatting DATA partition..."
mke2fs -F -q -t ext4 -m 0 $PART_DATA
e2fsck -n $PART_DATA
echo "done."

if grep -q $PART_BOOT /proc/mounts ; then
  echo "Unmounting BOOT partiton."
  umount -f $PART_BOOT
fi

echo "Formatting BOOT partition..."
mkfs.vfat -I $PART_BOOT
echo "done."

echo "Copying ROOTFS."

if [ -d $DIR_INSTALL ] ; then
    rm -rf $DIR_INSTALL
fi

mkdir -p $DIR_INSTALL
mount -o rw $PART_ROOT $DIR_INSTALL
cp /imgpart/volumio_current.sqsh $DIR_INSTALL
sync
umount $DIR_INSTALL

echo "Writing new kernel image..."

mount -o rw $PART_BOOT $DIR_INSTALL
cp /boot/zImage $DIR_INSTALL
cp /boot/uInitrd $DIR_INSTALL
cp /boot/volumio_emmc.scr $DIR_INSTALL/emmc_autoscript
if [ -f $IMAGE_DTB ] ; then
    cp $IMAGE_DTB $DIR_INSTALL
fi
sync
umount $DIR_INSTALL

#mkdir -p $DIR_INSTALL/aboot
#cd $DIR_INSTALL/aboot
#dd if=/dev/boot of=boot.backup.img
#abootimg -i /dev/boot > aboot.txt
#abootimg -x /dev/boot
#abootimg -u /dev/boot -k $IMAGE_KERNEL
#abootimg -u /dev/boot -r $IMAGE_INITRD

echo "done."

#if [ -f $IMAGE_DTB ] ; then
#    echo "Writing new dtb ..."
#    dd if="$IMAGE_DTB" of="/dev/dtb" bs=262144 status=none && sync
#    echo "done."
#fi

echo "Write env bootargs"
#fw_setenv initargs "imgpart=/dev/system imgfile=/volumio_current.sqsh bootpart=/dev/boot datapart=/dev/data rootwait rw logo=osd1,loaded,0x3d800000,\${hdmimode} vout=\${hdmimode},enable console=ttyS0,115200n8 console=tty0 no_console_suspend consoleblank=0 mac=\${mac}"
fw_setenv bootcmd "run start_autoscript; run bootvolumio; run storeboot;"
fw_setenv bootvolumio "if fatload mmc 1:2 1020000 emmc_autoscript; then autoscr 1020000; fi;"


echo "******************************"
echo "Complete copy Volumio to eMMC "
echo "******************************"
