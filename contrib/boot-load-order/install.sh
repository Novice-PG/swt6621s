#!/bin/sh
# Install (or remove) the delayed boot-time load order for the SWT6621S stack.
#
#   sudo ./install.sh            # install
#   sudo ./install.sh --remove   # revert to the plain modules-load.d behaviour
#
# Safe to re-run. It only touches the files listed here.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
UNIT_DIR=/etc/systemd/system
MODPROBE_DIR=/etc/modprobe.d
MODULES_LOAD_DIR=/etc/modules-load.d

MODULES="skw_sdio_lite swt6621s_wifi skwbt"

if [ "$(id -u)" -ne 0 ]; then
	echo "run as root" >&2
	exit 1
fi

if [ "${1:-}" = "--remove" ]; then
	systemctl disable --now swt6621s-wifi.timer 2>/dev/null || true
	rm -f "$UNIT_DIR/swt6621s-wifi.timer" "$UNIT_DIR/swt6621s-wifi.service"
	rm -f "$MODPROBE_DIR/blacklist-swt6621s.conf"
	systemctl daemon-reload 2>/dev/null || true
	echo "removed. Modules are no longer autoloaded at boot unless you add them"
	echo "back to $MODULES_LOAD_DIR (or load them manually with modprobe)."
	exit 0
fi

install -d "$UNIT_DIR" "$MODPROBE_DIR"
install -m 0644 "$HERE/blacklist-swt6621s.conf" "$MODPROBE_DIR/blacklist-swt6621s.conf"
install -m 0644 "$HERE/swt6621s-wifi.service" "$UNIT_DIR/swt6621s-wifi.service"
install -m 0644 "$HERE/swt6621s-wifi.timer" "$UNIT_DIR/swt6621s-wifi.timer"

# Stop modules-load.d from loading the stack ~1 s after boot. Comment the
# lines out instead of deleting other people's files.
if [ -d "$MODULES_LOAD_DIR" ]; then
	for f in "$MODULES_LOAD_DIR"/*.conf; do
		[ -f "$f" ] || continue
		for m in $MODULES; do
			sed -i -E "s|^[[:space:]]*${m}[[:space:]]*$|# ${m}  # moved to swt6621s-wifi.timer|" "$f"
		done
	done
fi

systemctl daemon-reload
systemctl enable swt6621s-wifi.timer

echo "installed. The modules load ~20 s after boot (systemd time base)."
echo "To load them right now without rebooting:"
echo "  modprobe skw_sdio_lite && modprobe swt6621s_wifi && modprobe skwbt"
