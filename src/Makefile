# SPDX-License-Identifier: GPL-2.0
#
# Out-of-tree (DKMS) build for the Seekwave SWT6621S WiFi/BT stack.
#
# Builds three modules against the target kernel tree:
#   skw_sdio_lite  - SDIO HAL backend
#   swt6621s_wifi  - cfg80211 WiFi driver
#   skwbt          - Bluetooth HCI driver

obj-m += seekwaveplatform_lite/
obj-m += swt6621s_wifi/
obj-m += swtbt4l/

# Kernels configured by a compiler that supports -fmin-function-alignment carry
# CONFIG_CC_HAS_MIN_FUNCTION_ALIGNMENT=y and add the flag unconditionally for
# out-of-tree module builds. Older target-distro compilers (e.g. Ubuntu 24.04's
# gcc-13) reject it, so drop it when building the modules.
KBUILD_CFLAGS := $(filter-out -fmin-function-alignment=%,$(KBUILD_CFLAGS))
