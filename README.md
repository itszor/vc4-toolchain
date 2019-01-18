# vc4-toolchain
A port of the GNU toolchain to the Raspberry Pi's VideoCore4 processor, based on the work of several people, and hacked around a bit until it works.

Most early testing was with the included `resim` simulator, but the compiler has also been tested against a real Raspberry Pi running a modified version of Kristina Brooks's open firmware.

Building
--------

You can build the toolchain as a cross-compiler. I've only tried doing this from Debian. To get the prerequisites try something like:

```bash
$ apt-get build-dep gcc-6
$ apt-get install cmake guile-1.8 libqt4-dev
$ apt-get install texinfo libgmp-dev libmpc-dev libmpfr-dev flex bison
```

The binutils port is now based on CGEN: to work with that, you'll need Guile 1.8 also. For the simulator, you'll need to install `cmake` (and maybe QT4 development libraries).

Now run the following command to retrieve all the submodules you need:

```bash
$ git clone --recursive https://github.com/itszor/vc4-toolchain.git
```

Then build the compiler with:

```bash
$ ./build-all.sh 2>&1 | tee build.log
```

This will give you a vc4-targeted toolchain in `$(pwd)/prefix/bin`. Compilers for both C and C++ should have been built.

Running tests on the simulator
------------------------------

You can test your newly-built compiler with the simulator:

```bash
$ ./check.sh 2>&1 | tee check.log
```

There will be a number of failures: many of these are due to simulator bugs, and a few are compiler bugs. At present results from simulator testing are considerably worse than those from hardware testing (see below).

```
                === gcc Summary ===

# of expected passes            62075
# of unexpected failures        417
# of unexpected successes       6
# of expected failures          95
# of unsupported tests          1439

                === g++ Summary ===

# of expected passes            74899
# of unexpected failures        830
# of expected failures          253
# of unresolved testcases       3
# of unsupported tests          3730
```


Compiling stuff for the simulator
---------------------------------

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

Compiling stuff to run from SRAM
--------------------------------

Console output uses an emulated mini-UART, so will work on real
hardware also, if you have the right serial cable. To test that, use the
`vc4-sram.ld` linker script (or see the "helloworld" directory alongside
this README file):

```bash
$ vc4-elf-gcc hello.c -O2 -T vc4-sram.ld -o hello
$ vc4-elf-objcopy -O binary hello hello.bin
$ cp hello.bin /path/to/sdcard/bootcode.bin
```

Now plug in your serial cable, SD card and power, open a terminal emulator, and see the output. Note that there is only 128Kb of RAM to use if you compile code with this method.

Running code on hardware via serial cable/test stub
---------------------------------------------------

You can also run VC4 code using the full amount of SDRAM on a Raspberry Pi. I've mostly tested with a 1b board, but others may work too. You'll have to perform several additional steps to do this.

Firstly, obtain and build the `rpi-open-firmware`, and check out the `gcc-teststub` branch:

```bash
$ git clone https://github.com/christinaa/rpi-open-firmware
$ cd rpi-open-firmware
$ git checkout gcc-teststub
```

You need this toolchain, and also an ARM EABI bare-metal cross compiler. Build the code, and copy the resulting `bootcode.bin` to your SD card.

The gcc teststub uses the open firmware's SDRAM initialisation code, and executes a basic shell over the serial connection for downloading/running VC4 code (from that SDRAM). So, test programs can use the full amount of memory in the Pi, and you can run several programs successively without swapping SD cards. At present, the board is rebooted between each program invocation.

Next, install prerequisites (for the `sx` xmodem tool):

```bash
$ apt-get install lrzsz
```

Then build the host-side code that communicates with the test stub:

```bash
$ cd rpirun
$ ./compile.sh
```

Next, compile some code to run on the test stub:

```bash
$ vc4-elf-gcc hello.c -O2 -T vc4-teststub.ld -o hello
```

Lastly, plug in your USB serial/UART cable and SD card, turn on your Pi, and do:

```bash
$ rpirun/do-rpirun ./hello
```

Your program should be transferred over the serial cable, execute on the hardware, and send its (line-buffered) output back to your console. (The `do-rpirun` script is a wrapper that runs `vc4-elf-objcopy` to turn the ELF executable into a flat binary then runs the real `rpirun` program.)

It's also possible to communicate "manually" with the test stub via a terminal emulator (e.g. `minicom`). Commands (from the host to the test stub) are in the form of single characters, as follows:

 * `?`: Query connection. Test stub should respond "OK.".
 
 * `L`: Load a file via XMODEM. The test stub will wait for the terminal emulator to start the transfer, and return to the shell when the transfer has completed.
 
 * `G`: Go. Execute the code in SDRAM. A "failsafe" is performed that just looks to see if the first instruction in the binary is the expected one before running code.
 
 * `T`: Initiate timeout countdown. This is currently fixed at 297 seconds (i.e., just under 5 minutes). This is used to catch programs that hang (and is used automatically by the GCC test harness), and reboots the board when it reaches zero.
 
 * `R`: Reset, reboots the board.

Running GCC tests via the test stub
-----------------------------------

Edit `check.sh` so that `TARGETBOARD` is set to `vc4-teststub`:

```bash
#TARGETBOARD=vc4-sim
TARGETBOARD=vc4-teststub
```

Then run `check.sh` as above. A test run with the C and C++ testsuites will take a number of hours, mostly due to the time taken to transfer binaries over the serial cable. Results should be along the lines of:

```
                === gcc Summary ===

# of expected passes            62382
# of unexpected failures        110
# of unexpected successes       6
# of expected failures          95
# of unsupported tests          1439

                === g++ Summary ===

# of expected passes            75643
# of unexpected failures        60
# of expected failures          253
# of unresolved testcases       3
# of unsupported tests          3743

```

These failures look mostly harmless - a number of them are due to apparent missing denormals or non-IEEE 754 conformant signed-zero handling in the floating-point hardware, for instance.

Thanks
------

Herman Hermitage for RE'ing stuff.

Kristina Brooks for the open firmware project.

Mark Marshall, Mathias Gottschlag and Tiernan Hubble for binutils bits.

David Given for GCC bits.

Mathias Gottschlag for resim.

plus probably loads of other people involved in the VideoCore4 reverse-engineering effort!

Can I use this to do XYZ with my Raspberry Pi?
----------------------------------------------

Probably not without significant effort... good luck!
