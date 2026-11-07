Driver (DKMS) and firmware packages for the Seekwave SWT6621S SDIO WiFi/BT
chip, as used on the KickPi K2B V2 and other SDIO/UART-connected boards.

Changes in @VERSION@:

- Add kernel API compatibility for Linux 6.1 through 7.3 and migrate platform
  GPIO handling to the descriptor API. Existing boards using `gpio_host_wake`,
  `gpio_chip_wake`, `gpio_chip_en` or the `chip_enable` module parameter must
  migrate to the `*-gpios` properties described in README.md.
- Support a firmware subdirectory and board-specific firmware filenames.
- Preserve supported compiler alignment flags throughout module builds; use
  compatible flags when the module compiler lacks support.
- Fix 12-bit RX reorder sequence-number wraparound.
- Report firmware-rejected interface changes correctly and register the
  dumpframe debug netdev without cfg80211. This does not enable monitor mode
  in firmware that rejects it.

Assets:

- `swt6621s-dkms_@VERSION@_all.deb` - DKMS source package; builds
  `skw_sdio_lite`, `swt6621s_wifi` and `skwbt` against the installed kernel
  headers.
- `swt6621s-firmware_@VERSION@_all.deb` - vendor firmware, installed into
  `/lib/firmware/`.
