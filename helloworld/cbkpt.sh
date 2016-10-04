#!/bin/sh
vc4-elf-gcc breakpoint.c -O2 -T vc4-teststub.ld -o breakpoint.elf -save-temps
vc4-elf-objcopy -O binary breakpoint.elf breakpoint.bin
