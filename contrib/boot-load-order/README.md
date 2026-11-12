# Boot-time load order (SDIO early-load failure)

The three modules must not be loaded about one second after boot. On the KickPi
K2B V2 running mainline 6.18.x (sunxi-mmc), `modules-load.d` runs while the
SDIO controller is still settling:

```
[SKWSDIO ERROR] skw_sdio_sdma_write ret = -16       # -EBUSY, first CMD53 block write
[SKWSDIO ERROR] ... -110                             # timeouts afterwards
[SKWBOOT] sv6160lite probe failed with error -16
```

The driver treats that first failed block write as fatal, so the chip stays
wedged and the boot can hang near `basic.target` (no WiFi, no console login).
Loading the very same modules later by hand works perfectly — `boot cp pass`,
`wifi boot sucessfull`, `wlan0` scans.

Measured on real hardware (6.18.63, K2B V2.2): loading at ~1 s fails every
time; loading ~30 s after kernel start works every time.

## What this directory does

| File | Installed to | Purpose |
|---|---|---|
| `blacklist-swt6621s.conf` | `/etc/modprobe.d/` | stop udev alias autoload (`modprobe` by name still works) |
| `swt6621s-wifi.service` | `/etc/systemd/system/` | `modprobe skw_sdio_lite`, then `swt6621s_wifi`, then `skwbt` (refuses to run before 20 s uptime) |
| `swt6621s-wifi.timer` | `/etc/systemd/system/` | fire the service 20 s after systemd starts |
| `install.sh` | — | install/remove all of the above |

```
sudo ./install.sh
```

It also comments the module lines out of `/etc/modules-load.d/*.conf`.

## Timing

`OnBootSec=` is relative to the start of the system manager (PID 1), not to
power-on. On the K2B this measured as: kernel start → systemd ≈ 4 s, timer
elapse ≈ 24 s, modules actually loaded at kernel monotonic ≈ 31 s (the service
also waits for `systemd-udev-settle.service`, which takes a few more seconds
when activated on demand). In practice expect WiFi about 30–35 s after power-on.

Raising the value is harmless; lowering it below ~10 s is not tested and
reintroduces the failure window.

## First boot / WiFi presets

Because wlan0 only appears ~30 s after power-on, anything that configures WiFi
earlier will not see an interface. Armbian's `armbian-firstlogin` applies
Imager presets before it prompts for anything, and it silently skips a WiFi
preset when no wlan device exists yet.

If you ship images with WiFi presets, start the unit from a profile.d script
that runs before `armbian-check-first-login.sh` (both in `/etc/profile.d/`,
the `00-` name sorts first):

```sh
[ -r /root/.not_logged_in_yet ] || return 0
grep -q '^[[:space:]]*PRESET_NET_WIFI_ENABLED=1' /root/.not_logged_in_yet 2>/dev/null || return 0
for d in /sys/class/net/wlan*; do [ -e "$d" ] && return 0; done
systemctl start swt6621s-wifi.service >/dev/null 2>&1 || true
return 0
```

This cannot load too early: the unit's `ExecStartPre` waits for 20 s of
uptime regardless of who starts it. Interactive logins without a WiFi preset
are not delayed.
