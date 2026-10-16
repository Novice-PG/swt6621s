# SPDX-License-Identifier: GPL-2.0
#
# Seekwave platform (SDIO HAL) driver.
# Out-of-tree build.

ccflags-y += -include $(src)/../swt6621s-config.h
ccflags-y += -I$(src)/skwutil
ccflags-y += -I$(src)/sdio
ccflags-y += -I$(src)/../include
ccflags-y += -I$(src)/../include/linux/platform_data

obj-m += skw_sdio_lite.o
skw_sdio_lite-y := ./sdio/skw_sdio_main.o
skw_sdio_lite-y += ./sdio/skw_sdio_rx.o
skw_sdio_lite-y += ./sdio/skw_sdio_debugfs.o
skw_sdio_lite-y += ./sdio/skw_sdio_log.o
skw_sdio_lite-y += ./sdio/skw_sdio_host.o
skw_sdio_lite-y += ./skwutil/skw_user_com.o
skw_sdio_lite-y += ./skwutil/skw_log_to_file.o
skw_sdio_lite-y += ./skwutil/skw_boot.o
skw_sdio_lite-y += ./skwutil/skw_btlog.o
