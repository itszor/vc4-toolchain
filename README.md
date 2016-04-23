# vc4-toolchain
A port of the GNU toolchain to the Raspberry Pi's VideoCore4 processor, based on the work of several people, and hacked around a bit until it works.

Note that this has only really been tested with `resim`, so your milage may (and probably will) vary running code on actual hardware.

Building
--------

You can build the toolchain as a cross-compiler. I've only tried doing this from Debian. To get the prerequisites try something like:

```bash
$ apt-get build-dep gcc-6
```

The binutils port is now based on CGEN: to work with that, you'll need guile-1.8 also. For the simulator, you'll need to install cmake.

Now run the following command to retrieve all the submodules you need:

```bash
$ git clone --recursive https://github.com/puppeh/vc4-toolchain.git
```

Then build the compiler with:

```bash
$ ./build-all.sh 2>&1 | tee build.log
```

This will give you a vc4-targeting toolchain in `$(pwd)/prefix/bin`.

Running tests
-------------

Test your newly-built compiler with:

```bash
$ ./check.sh 2>&1 | tee check.log
```

There should only be a handful of failures (~30 or so).

Compiling stuff
---------------

Try the standard "hello world" program:

```c
#include <stdio.h>

int main(int argc, char* argv[])
{
  printf("Hello world!\n");
  return 0;
}
```

```bash
$ vc4-elf-gcc hello.c -O2 -T vc4-sim.ld -o hello
$ vc4-elf-objcopy -O binary hello hello.bin
$ resim/vc4emul/vc4emul hello.bin 0 0
Hello world!
```

Console output uses an emulated mini-UART, so in theory might work on real hardware also, if you have the right serial cable.

Thanks
------

Herman Hermitage for RE'ing stuff.
Mark Marshall, Mathias Gottschlag and Tiernan Hubble for binutils bits.
David Given for GCC bits.
Mathias Gottschlag for resim.

plus probably loads of other people involved in the VideoCore4 reverse-engineering effort.

Can I use this to do XYZ with my Raspberry Pi?
----------------------------------------------

Probably not without significant effort... good luck!
