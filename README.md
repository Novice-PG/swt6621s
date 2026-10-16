# swt6621s

DKMS source and Debian packaging for the Seekwave SWT6621S (vs6621s) SDIO
WiFi/BT driver stack, as used on the KickPi K2B V2 (Allwinner H618).

## Contents

| Path | Description |
|---|---|
| `src/` | Driver source, adapted for out-of-tree builds |
| `firmware/` | Vendor firmware blobs (installed into `/lib/firmware/`) |
| `dkms.conf` | DKMS configuration (three modules) |
| `packaging/build-debs.sh` | Builds the `swt6621s-dkms` and `swt6621s-firmware` packages |

The three modules built by DKMS are:

- `skw_sdio_lite` - SDIO HAL backend
- `swt6621s_wifi` - cfg80211 WiFi driver
- `skwbt` - Bluetooth HCI driver

Symbols that the in-tree (upstream) build takes from its Kconfig are provided
for the out-of-tree build by `src/swt6621s-config.h`, which is force-included
by the per-directory Makefiles. Keep it in sync with the reference kernel
config when changing the build.

## Building the packages

```
./packaging/build-debs.sh
```

This produces `swt6621s-dkms_<version>_all.deb` and
`swt6621s-firmware_<version>_all.deb`. The version is read from `dkms.conf`.

## Building the modules manually

```
make -C /lib/modules/$(uname -r)/build M=$PWD/src modules
```

Then load them with the firmware package installed:

```
modprobe skw_sdio_lite
modprobe swt6621s_wifi
modprobe skwbt
```

## Provenance

The driver source was extracted from the vendor kernel tree shipped for the
KickPi K2B V2 and, apart from the out-of-tree build support, is unchanged.
The firmware blobs are redistributed as shipped by the board vendor.

The driver is licensed under the GPL-2.0 (see the SPDX headers in the source
files). The firmware blobs are copyright Seekwave Technology.
