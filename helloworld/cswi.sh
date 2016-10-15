#!/bin/sh
vc4-elf-gcc swi.c -O2 -T vc4-teststub.ld -o swi.elf -save-temps
vc4-elf-objcopy -O binary swi.elf swi.bin
