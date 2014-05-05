#!/bin/bash

INPUT_PATH=$1
QEMU_BASENAME=$(basename "$INPUT_PATH")
QEMU_FILENAME="${QEMU_BASENAME%.*}"
OUTPUT_PATH=$2

cd xen*/tools/blktap2/vhd
export LD_LIBRARY_PATH=lib/
qemu-img convert -O raw $INPUT_PATH /tmp/$QEMU_FILENAME.raw

./vhd-util convert -s 0 -t 1 -i /tmp/$QEMU_FILENAME.raw -o /tmp/0_$QEMU_FILENAME.vhd
./vhd-util convert -s 1 -t 2 -i /tmp/0_$QEMU_FILENAME.vhd -o $OUTPUT_PATH/$QEMU_FILENAME.vhd

rm -rf /tmp/*$QEMU_FILENAME*
