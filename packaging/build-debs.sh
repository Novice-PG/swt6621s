#!/bin/bash
# Build the swt6621s-dkms and swt6621s-firmware Debian packages.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(sed -n 's/^PACKAGE_VERSION="\(.*\)"$/\1/p' "${ROOT}/dkms.conf")"
if [ -z "${VERSION}" ]; then
	echo "error: cannot determine version from ${ROOT}/dkms.conf" >&2
	exit 1
fi

BUILD="${ROOT}/.deb-build"
rm -rf "${BUILD}"
mkdir -p "${BUILD}"

MAINTAINER="Novice-PG <novice-pg@users.noreply.github.com>"

# ---------- swt6621s-dkms ----------
D="${BUILD}/swt6621s-dkms"
SRC="${D}/usr/src/swt6621s-${VERSION}"
mkdir -p "${SRC}" "${D}/DEBIAN"
cp -a "${ROOT}/src" "${SRC}/src"
cp -a "${ROOT}/dkms.conf" "${ROOT}/README.md" "${ROOT}/LICENSE" "${SRC}/"

# Never ship build artifacts, even if the working tree is dirty.
find "${SRC}" \( -name '*.ko' -o -name '*.o' -o -name '.*.cmd' -o -name '*.mod' \
	-o -name '*.mod.c' -o -name 'version.h' -o -name 'Module.symvers' \
	-o -name 'modules.order' \) -delete 2>/dev/null || true
rm -rf "${SRC}/src/.tmp_versions" 2>/dev/null || true

sed "s/@VERSION@/${VERSION}/g" "${ROOT}/packaging/swt6621s-dkms.postinst" > "${D}/DEBIAN/postinst"
sed "s/@VERSION@/${VERSION}/g" "${ROOT}/packaging/swt6621s-dkms.prerm" > "${D}/DEBIAN/prerm"
chmod 755 "${D}/DEBIAN/postinst" "${D}/DEBIAN/prerm"

cat > "${D}/DEBIAN/control" <<EOF
Package: swt6621s-dkms
Version: ${VERSION}
Architecture: all
Maintainer: ${MAINTAINER}
Depends: dkms
Section: kernel
Priority: optional
Description: DKMS source for the Seekwave SWT6621S SDIO WiFi/BT driver
 Out-of-tree (DKMS) build of the Seekwave SWT6621S SDIO WiFi/BT driver
 stack, as used on the KickPi K2B V2 (Allwinner H618).
 .
 Builds three modules against the installed kernel headers:
 skw_sdio_lite, swt6621s_wifi and skwbt.
EOF

dpkg-deb --root-owner-group -Zxz -b "${D}" "${ROOT}/swt6621s-dkms_${VERSION}_all.deb"

# ---------- swt6621s-firmware ----------
F="${BUILD}/swt6621s-firmware"
mkdir -p "${F}/lib/firmware" "${F}/DEBIAN"
cp -a "${ROOT}/firmware/." "${F}/lib/firmware/"

cat > "${F}/DEBIAN/control" <<EOF
Package: swt6621s-firmware
Version: ${VERSION}
Architecture: all
Maintainer: ${MAINTAINER}
Section: kernel
Priority: optional
Description: Firmware for the Seekwave SWT6621S WiFi/BT chip
 Vendor firmware (RAM patch, calibration and regulatory data) for the
 Seekwave SWT6621S SDIO WiFi/BT chip. Installs into /lib/firmware/.
EOF

dpkg-deb --root-owner-group -Zxz -b "${F}" "${ROOT}/swt6621s-firmware_${VERSION}_all.deb"

echo
echo "Built packages:"
ls -l "${ROOT}"/swt6621s-*_${VERSION}_all.deb
