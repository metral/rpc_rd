#!/bin/bash

EXPECTEDARGS=2
if [ $# -lt $EXPECTEDARGS ]; then
    echo "Usage: $0 <QCOW_INPUT_PATH> <VHD_OUTPUT_PATH>"
    exit 0
fi

INPUT_PATH=`readlink -f $1`
QEMU_BASENAME=$(basename "$INPUT_PATH")
QEMU_FILENAME="${QEMU_BASENAME%.*}"
OUTPUT_PATH=`readlink -f $2`

# Get to dir where vhd-util is located & setup env
pushd xen*/tools/blktap2/vhd
export LD_LIBRARY_PATH=lib/

# First, convert the qcow to a raw image
qemu-img convert -O raw $INPUT_PATH /tmp/$QEMU_FILENAME.raw

# Next, convert the raw image to vhd
./vhd-util convert -s 0 -t 1 -i /tmp/$QEMU_FILENAME.raw -o /tmp/0_$QEMU_FILENAME.vhd
./vhd-util convert -s 1 -t 2 -i /tmp/0_$QEMU_FILENAME.vhd -o $OUTPUT_PATH/$QEMU_FILENAME.vhd

# Cleanup
rm -rf /tmp/*$QEMU_FILENAME*
popd
