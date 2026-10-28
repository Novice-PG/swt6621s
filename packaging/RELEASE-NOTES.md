Driver (DKMS) and firmware packages for the Seekwave SWT6621S SDIO WiFi/BT
chip, as used on the KickPi K2B V2 (Allwinner H618).

Changes in @VERSION@:

- Build the three modules without ftrace entry points
  (`KCFLAGS=-fpatchable-function-entry=0` in `dkms.conf`). On arm64 kernels
  configured with `CONFIG_DYNAMIC_FTRACE_WITH_CALL_OPS` loading them used to
  take the boot down: the kernel patches a per-module ftrace trampoline at
  load time, the patch landed outside the module text as the loader sees it,
  and `patch_map()` hit `BUG()` in `ftrace_init_nop`, leaving
  `systemd-modules-load` dead and the system in RCU stalls. System-wide ftrace
  now stays enabled.

Assets:

- `swt6621s-dkms_@VERSION@_all.deb` - DKMS source package; builds
  `skw_sdio_lite`, `swt6621s_wifi` and `skwbt` against the installed kernel
  headers.
- `swt6621s-firmware_@VERSION@_all.deb` - vendor firmware, installed into
  `/lib/firmware/`.
