/* SPDX-License-Identifier: GPL-2.0 */
/*
 * Configuration for the out-of-tree (DKMS) build of the Seekwave
 * SWT6621S WiFi/BT driver stack.
 *
 * These defines mirror the Kconfig symbols that were enabled for the
 * reference in-tree build of this driver. Keep them in sync with the
 * reference kernel config when changing the build.
 */

#ifndef __SWT6621S_CONFIG_H
#define __SWT6621S_CONFIG_H

/* Built-in symbols */
#define CONFIG_SEEKWAVE_BSP_DRIVERS	1

/* Modules */
#define CONFIG_SKW_SDIOHAL_MODULE	1
#define CONFIG_WLAN_VENDOR_SWT6621S_MODULE	1
#define CONFIG_SKW_BSP_UCOM_MODULE	1
#define CONFIG_SKW_BSP_BOOT_MODULE	1
#define CONFIG_SKW_BT_MODULE	1

/* Architecture / feature flags */
#define CONFIG_64BIT	1
#define CONFIG_BT_SEEKWAVE	1

/* Driver options */
#define CONFIG_SWT6621S_RX_REORDER_TIMEOUT	100
#define CONFIG_SWT6621S_LOG_ERROR	1
#define CONFIG_SWT6621S_REGD_SELF_MANAGED	1
#define CONFIG_SWT6621S_PROJECT_NAME	"SEEKWAVE"
#define CONFIG_SWT6621S_DEFAULT_COUNTRY	""
#define CONFIG_SWT6621S_CHIP_ID	""

#endif /* __SWT6621S_CONFIG_H */
