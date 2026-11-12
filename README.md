# swt6621s

DKMS source and Debian packaging for the Seekwave SWT6621S (vs6621s) SDIO
WiFi/BT driver stack, as used on the KickPi K2B V2 (Allwinner H618). It can
also be used on other boards, such as the KickPi K3B.

## Contents

| Path | Description |
|---|---|
| `src/` | Driver source, adapted for out-of-tree builds |
| `firmware/` | Vendor firmware blobs (installed into `/lib/firmware/`) |
| `dkms.conf` | DKMS configuration (three modules) |
| `packaging/build-debs.sh` | Builds the `swt6621s-dkms` and `swt6621s-firmware` packages |
| `packaging/RELEASE-NOTES.md` | Release notes, `@VERSION@` is replaced by the tag |
| `contrib/boot-load-order/` | Delayed-load fix for boards where loading at boot wedges the chip |
| `.github/workflows/release.yml` | Builds and publishes the packages for a tag |

The three modules built by DKMS are:

- `skw_sdio_lite` - SDIO HAL backend
- `swt6621s_wifi` - cfg80211 WiFi driver
- `skwbt` - Bluetooth HCI driver

Symbols that the in-tree (upstream) build takes from its Kconfig are provided
for the out-of-tree build by `src/swt6621s-config.h`, which is force-included
by the per-directory Makefiles. Keep it in sync with the reference kernel
config when changing the build.

## GPIO configuration

The descriptor-based GPIO interface replaces the old `gpio_host_wake`,
`gpio_chip_wake` and `gpio_chip_en` DT properties with `host-wake-gpios`,
`chip-wake-gpios` and `chip-en-gpios`. Update board DTS files that use the old
names; the GPIO polarity is taken from each `*-gpios` specifier. The old
`chip_enable=<GPIO number>` module parameter is no longer supported. Describe
that signal with `chip-en-gpios` in the device tree instead. Boards without
these GPIO connections need no new properties.

KickPi K3B and K2B V2 do not use these GPIO properties and require no GPIO
configuration changes.

## Firmware lookup

Each of `skw_sdio_lite`, `swt6621s_wifi` and `skwbt` accepts its own optional
`firmware_dir` module parameter. To look under `/lib/firmware/seekwave/`,
configure all three modules, for example in a modprobe configuration file:

```conf
options skw_sdio_lite firmware_dir=seekwave
options swt6621s_wifi firmware_dir=seekwave
options skwbt firmware_dir=seekwave
```

The driver first looks for `<name>.<root-compatible>.<extension>` in that
directory, then falls back to the generic `<name>` there. With the default
empty `firmware_dir`, both lookups use the normal firmware search paths.
The bundled firmware package installs generic files directly under
`/lib/firmware/`; configure a subdirectory only when the required files are
present there.

## Building the packages

```
./packaging/build-debs.sh
```

This produces `swt6621s-dkms_<version>_all.deb` and
`swt6621s-firmware_<version>_all.deb`. The version is read from `dkms.conf`.

## Releasing

Bump `PACKAGE_VERSION` in `dkms.conf`, commit, then push a matching tag:

```
git tag 1.0.3
git push origin main 1.0.3
```

`.github/workflows/release.yml` builds both packages on the runner, refuses a
tag that does not match `dkms.conf`, and publishes them as release assets.

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

## Boot-time load order

Do not load these modules from `modules-load.d` by default. On the KickPi K2B V2
with mainline 6.18 kernels the module loader runs about one second after boot,
while the SDIO controller is still settling. The first CMD53 block write of the
firmware download then fails with `-EBUSY`, the chip stays wedged
(`sv6160lite probe failed with error -16`) and the boot can stall.

Load the stack ~20 s after boot instead, with udev autoload suppressed:

```
sudo contrib/boot-load-order/install.sh
```

See [`contrib/boot-load-order/README.md`](contrib/boot-load-order/README.md)
for the log signatures and the measured timings.

## Provenance

The driver source was extracted from the vendor kernel tree shipped for the
KickPi K2B V2.
The firmware blobs are redistributed as shipped by the board vendor.

The driver is licensed under the GPL-2.0 (see the SPDX headers in the source
files). The firmware blobs are copyright Seekwave Technology.
