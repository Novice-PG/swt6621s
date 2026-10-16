#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
#
# Compiler shim used by the DKMS MAKE command (and by the top-level module
# Makefile for manual builds).
#
# Kernels configured by a compiler that supports -fmin-function-alignment
# (gcc >= 14) carry CONFIG_CC_HAS_MIN_FUNCTION_ALIGNMENT=y, and the kernel
# build system then passes -fmin-function-alignment=8 to out-of-tree module
# builds unconditionally -- including the .mod.o finalize stage
# (scripts/Makefile.modfinal), which runs outside the module Makefile's reach.
# Older compilers (e.g. Ubuntu 24.04's gcc-13) reject the option.
#
# Strip the option for such compilers; pass everything through unchanged
# otherwise.
set -u

real_cc="${SWT_REAL_CC:-${CROSS_COMPILE:-}gcc}"
major="$("${real_cc}" -dumpversion 2>/dev/null | cut -d. -f1)"

if [[ "${major}" =~ ^[0-9]+$ ]] && ((major < 14)); then
	args=()
	for arg in "$@"; do
		case "${arg}" in
			-fmin-function-alignment=*) ;;
			*) args+=("${arg}") ;;
		esac
	done
	exec "${real_cc}" "${args[@]}"
fi

exec "${real_cc}" "$@"
