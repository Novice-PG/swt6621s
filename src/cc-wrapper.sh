#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
#
# Use as Kbuild's command-line CC so every module compilation, including
# Makefile.modfinal, uses the same compatibility handling. SWT_REAL_CC can
# select a compiler other than ${CROSS_COMPILE}gcc.
#
# A prebuilt kernel can require -fmin-function-alignment even when the module
# compiler lacks it. Preserve all flags when supported; otherwise use ordinary
# function alignment and disable patchable entries. Ordinary alignment does
# not guarantee the alignment required by arm64 ftrace call-ops.
set -u

real_cc="${SWT_REAL_CC:-${CROSS_COMPILE:-}gcc}"

needs_alignment=false
for arg in "$@"; do
	case "$arg" in
		-fmin-function-alignment=*) needs_alignment=true; break ;;
	esac
done

if [[ "$needs_alignment" == false ]]; then
	exec "$real_cc" "$@"
fi

if "$real_cc" -Werror -fmin-function-alignment=8 -x c -c /dev/null \
	-o /dev/null >/dev/null 2>&1; then
	exec "$real_cc" "$@"
fi

args=()
for arg in "$@"; do
	case "$arg" in
		-fmin-function-alignment=*)
			args+=("-falign-functions=${arg#*=}")
			;;
		-fpatchable-function-entry=*)
			args+=("-fpatchable-function-entry=0")
			;;
		*) args+=("$arg") ;;
	esac
done

exec "$real_cc" "${args[@]}"
