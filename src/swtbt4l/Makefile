# SPDX-License-Identifier: GPL-2.0
#
# Seekwave SWT6621S Bluetooth HCI driver.
# Out-of-tree build.

ccflags-y += -include $(src)/../swt6621s-config.h
ccflags-y += -I$(src)/../include
ccflags-y += -I$(src)/../include/linux/platform_data

ccflags-y += -DINCLUDE_NEW_VERSION=1

obj-m += skwbt.o
skwbt-y := skw_btdriver.o
skwbt-y += skw_btsnoop.o
skwbt-y += skw_log.o
skwbt-y += skw_common.o
skwbt-y += skw_btlog.o
