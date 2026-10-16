# SPDX-License-Identifier: GPL-2.0
#
# Seekwave SWT6621S WiFi (cfg80211) driver.
# Out-of-tree build.

ccflags-y += -include $(src)/../swt6621s-config.h
ccflags-y += -I$(src)/../include
ccflags-y += -I$(src)/../include/linux/platform_data

obj-m += swt6621s_wifi.o
swt6621s_wifi-objs += skw_core.o
swt6621s_wifi-objs += skw_core_dbg.o
swt6621s_wifi-objs += skw_iface.o
swt6621s_wifi-objs += skw_cfg80211.o
swt6621s_wifi-objs += skw_msg.o
swt6621s_wifi-objs += skw_rx.o
swt6621s_wifi-objs += skw_tx.o
swt6621s_wifi-objs += skw_regd.o
swt6621s_wifi-objs += skw_mlme.o
swt6621s_wifi-objs += skw_timer.o
swt6621s_wifi-objs += skw_log.o
swt6621s_wifi-objs += skw_iw.o
swt6621s_wifi-objs += skw_work.o
swt6621s_wifi-objs += skw_mbssid.o
swt6621s_wifi-objs += skw_dentry.o
swt6621s_wifi-objs += skw_util.o
swt6621s_wifi-objs += skw_config.o
swt6621s_wifi-objs += skw_recovery.o
swt6621s_wifi-objs += skw_vendor.o
swt6621s_wifi-objs += trace.o
swt6621s_wifi-objs += skw_db.o

# DFS and TDLS are disabled, as in the reference in-tree build:
# swt6621s_wifi-$(CONFIG_SWT6621S_DFS_MASTER) += skw_dfs.o
# swt6621s_wifi-$(CONFIG_SWT6621S_TDLS) += skw_tdls.o

ccflags-y += -DCONFIG_SWT6621S_STA_SME_EXT
ccflags-y += -DCONFIG_SWT6621S_SAP_SME_EXT
ccflags-y += -DCONFIG_SWT6621S_SCAN_RANDOM_MAC
ccflags-y += -DCONFIG_SWT6621S_TX_WORKQUEUE
ccflags-y += -DCONFIG_SWT6621S_HIGH_PRIORITY
ccflags-y += -DCONFIG_SWT6621S_CALIB_APPEND_BUS_ID
ccflags-y += -DCONFIG_SWT6621S_CALIB_APPEND_MODULE_ID

CFLAGS_trace.o := -I$(src)

$(obj)/skw_core.o : $(obj)/version.h

skw_abs_path := $(abspath $(src))
$(obj)/version.h: $(skw_abs_path)/genver.pl
	@$(PERL) -s $(skw_abs_path)/genver.pl $@

clean-files := version.h
