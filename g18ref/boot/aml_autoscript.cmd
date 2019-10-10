setenv kernel_addr "0x82000000"
setenv initrd_addr "0x83000000"
setenv boot_start "bootm ${kernel_addr} ${initrd_addr}"
setenv bootargs "rdinit=/init imgpart=LABEL=volumio imgfile=/volumio_current.sqsh bootpart=LABEL=BOOT datapart=LABEL=volumio_data hwdevice=amlg18ref rootwait rw console=ttyS0,115200n8 console=tty0 no_console_suspend consoleblank=0 scaling_governor=ondemand mac=00:00:dd:6a:6b:c0 logo=osd1,0x84100000,720p scaling_min_freq=200000 scaling_max_freq=1512000"
if mmcinfo 0; then if fatload mmc 0 ${kernel_addr} uImage; then if fatload mmc 0 ${initrd_addr} uInitrd; then run boot_start; fi;fi;fi;
