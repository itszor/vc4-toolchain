#!/bin/sh
vc4-elf-gcc -I../../rpi-open-firmware -I../../rpi-open-firmware/bcm2708_chip sandbox.c -O -T vc4-teststub.ld -o sandbox.elf -save-temps
vc4-elf-objcopy -O binary sandbox.elf sandbox.bin
