#!/bin/bash
nasm -f bin boot.asm
FILESIZE=$(($(stat -c "%s" "boot")+62))
dd if=floppy_old.img of=floppy_start bs=62 count=1
dd if=floppy_old.img of=floppy_end bs=$FILESIZE skip=1
cat floppy_start boot floppy_end > floppy_all.img
