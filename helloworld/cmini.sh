#!/bin/sh
vc4-elf-as mini.s -o mini.o
vc4-elf-gcc -nostartfiles -T vc4-teststub.ld mini.o -o mini.elf
vc4-elf-objcopy -O binary mini.elf mini.bin
