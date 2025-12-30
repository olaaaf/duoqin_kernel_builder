# Android kernel build + boot image repack container

I made this as a quick start to build duoqin_f21pro kernel from https://github.com/JamiKettunen/android_kernel_duoqin_mt6761.
Building a kernel on mac os is hard, this container should get you started.

This repo gives you a reproducible Ubuntu 24.04 (amd64) environment with:
- AArch64 GCC cross toolchain (`aarch64-none-linux-gnu-`)
- Clang toolchain (for Android kernel builds)
- `repo`, build deps, and `magiskboot` (extracted from Magisk APK)
- A `deploy` helper that repacks the freshly built kernel into an image.

It’s designed to be used with **Podman Compose** or **Docker Compose**.
I'm using podman :), although if you want to connect with vscode id recommend docker.

## Prerequisites

### Choose one runtime
- **podman** + `podman compose`
- **docker** + `docker compose` (or legacy `docker-compose`)

### Host folder for outputs
The compose file expects this path on your host:
- `~/Desktop/output` <- create that folder beforehand!

! btw you can change it in docker-compose.yml

It will appear in the container as:
- `/output`

Change it if you want to!! You should put your pulled `boot_a` partition into that folder on your host machine.

## Build the image

### Podman
```bash
podman compose build
```

### Docker

```bash
docker compose build
# or: docker-compose build
```

## Start an interactive shell in the container

### Podman

```bash
podman compose run --rm android
```

### Docker

```bash
docker compose run --rm android
# or: docker-compose run --rm android
```

You’ll land in a `bash` shell inside the container.

## Kernel source setup

Inside the container:

1. Clone your kernel source into `/kernel`:

```bash
# clone the kernel
cd /kernel
git clone https://github.com/JamiKettunen/android_kernel_duoqin_mt6761.git .
# create the output directory
mkdir -p /kernel/out
```

## Build workflow

### About `${ARGS}`

It's always in env, so no need to worry about setting those values.
The build command string sets:

* `-C /kernel` - which is the source directory
* `O=/kernel/out` - output directory
* `ARCH=arm64` - target architecture
* `CROSS_COMPILE=aarch64-none-linux-gnu` - prefix for the cross compile toolchain
* `CC=/toolchain/clang/bin/clang` - clang compiler :) 
* `CLANG_TRIPLE=aarch64-none-linux-gnu-` - target architecture to compile for
* `-j$(nproc)` - number of processors make will use, really important

### Clean + configure

```bash
make ${ARGS} clean
make ${ARGS} mrproper
make ${ARGS} k61v1_64_bsp_defconfig duoqin_f21pro.config
```

### Build

Pick the build target you normally use. Common examples:

```bash
make ${ARGS}
```

After a successful build, your kernel Image should be at:

```text
/kernel/out/arch/arm64/boot/Image
```

## Repack the boot image (deploy)

### 1) Put `boot.bin` into the host output folder

On the host machine, pull the device boot partition (I pulled boot_a).
Then move it to the output folder (default `~/Desktop/output/boot.bin`):
I hardcoded `boot.bin` so you're going to have to rename it.

### 2) Run `deploy` inside the container

Inside the container:

```bash
deploy
```

What it does:

* checks `/output/boot.bin`
* unpacks it with `magiskboot` into `/output/tmp`
* replaces the unpacked `kernel` with your newly built `/kernel/out/.../Image`
* repacks the boot image
* writes the result to:

```text
/output/new-boot.bin
```

## tldr

```bash
# host
podman compose build
podman compose run --rm android

# container
cd /kernel
git clone https://github.com/JamiKettunen/android_kernel_duoqin_mt6761.git .
mkdir -p /kernel/out
make ${ARGS} clean
make ${ARGS} mrproper
make ${ARGS} k61v1_64_bsp_defconfig duoqin_f21pro.config
make ${ARGS}

# host: place boot image here:
# ~/Repos/projects/outputs/boot.bin

# container
deploy

# host: flash ~/Repos/projects/outputs/new-boot.bin (device-specific)
```
