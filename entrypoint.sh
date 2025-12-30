#!/bin/bash

export ARGS="-C /kernel O=/kernel/out -j$(nproc) ARCH=arm64 CROSS_COMPILE=${BUILD_CROSS_COMPILE} CC=${BUILD_CC} CLANG_TRIPLE=aarch64-none-linux-gnu- KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y"
