#!/bin/sh
vc4-elf-gcc hello.c -O2 -T vc4-sram.ld -o hello
vc4-elf-objcopy -O binary hello hello.bin
