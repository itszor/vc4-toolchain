#!/bin/sh
vc4-elf-gcc helloworld.c -O2 -T vc4-teststub.ld -o helloworld.elf -save-temps
vc4-elf-objcopy -O binary helloworld.elf helloworld.bin
