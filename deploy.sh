#!/bin/bash

cd /output
if [ ! -f boot.bin ]; then
echo "boot.bin is not present"
exit 1
fi

rm -rf new-boot.bin
mkdir -p /output/tmp
cd /output/tmp
if [ ! -f /output/tmp/kernel ]; then
echo "unpacking image"
magiskboot unpack /output/boot.bin
fi

echo "subsitute kernel"
rm /output/tmp/kernel
cp /kernel/out/arch/arm64/boot/Image kernel
echo "repacking image"
magiskboot repack /output/boot.bin
mv new-boot.img /output/new-boot.bin

echo "new image: new-boot.bin"
