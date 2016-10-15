#!/bin/sh
vc4-elf-gcc divzero.c -O -T vc4-teststub.ld -o divzero.elf
vc4-elf-objcopy -O binary divzero.elf divzero.bin
