#!/bin/sh
vc4-elf-gcc -fsingle-precision-constant piapprox.c -O2 -T vc4-teststub.ld -o piapprox.elf
vc4-elf-objcopy -O binary piapprox.elf piapprox.bin
