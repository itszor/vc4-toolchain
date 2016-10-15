#!/bin/sh
vc4-elf-gcc -I../../rpi-open-firmware -I../../rpi-open-firmware/bcm2708_chip timeout.c -O -T vc4-teststub.ld -o timeout.elf -save-temps
vc4-elf-objcopy -O binary timeout.elf timeout.bin
