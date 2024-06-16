# Z80-CPU-Tester

<img src="/HARDWARE/pictures/z80cputester_v1.jpg" width="400">

## General info

This project allows you to test a Z80 CPU.

It tries
1. to identify the CPU,
2. to test whether the CPU is still functional

and has following features:
* 32kb EPROM (27C256), alternatively an EEPROM can be used (AT29C256)
* 32kb SRAM
* 2 output ports (1x unidirectional, 1x read-back) with 16 LEDs
* RESET and NMI button
* 16 MHz / 20 MHz switchable
* 1, 1/2, 1/4, 1/8, 1/16 multiplicator (1-16 MHz / 1.25-20 MHz)
* USB powered

This project is based on an idea of 
* https://oshwlab.com/vitalian1980/z80-tester (Hardware, Public Domain)

and additionally based on ideas of
* https://bitbucket.org/rudolff/z80-tester (Software, No license)
* https://github.com/djtersteegc/z80-cmos-nmos-tester (MIT license)
* https://github.com/skiselev/z80-tests (Software, GPL-3.0 license)
* https://github.com/EtchedPixels/FUZIX/blob/master/Applications/util/cpuinfo-z80.S (Software, GPL-2.0 license)
* https://groups.google.com/g/retro-comp/c/rhKeKpXmAXM (Software)
* https://www.malinov.com/sergeys-blog/z80-type-detection.html

and finally Frank Cringle's Z80 instruction set exerciser
* https://github.com/begoon/z80exer  (Software, GPL-2.0 license)

[My files are published under MIT license, some files have more permissive licensing.
Please check the licence files in the relevant directories. When you are interested in
a PCB, please [contact me](https://8bit-museum.de/kontakt/).]

## Technologies

The project uses [KiCAD](https://www.kicad.org/) and [zmac](http://48k.ca/zmac.html).

## Sub-projects

The repository has been divided into several sub-projects.

The required hardware can be found in the HARDWARE folder. There is currently only one hardware version (v1).

The required firmware is stored in the SOFTWARE folder. The versioning is as follows:

X.Y:
* X = for hardware version X
* Y = firmware no. Y

Version 1.2 is firmware 2 for hardware 1.

A higher version number does not automatically mean a newer or better firmware.

## Examples

Zilog Z84C0020PEC from a Chinese marketplace. It is a U880 (runs with 10 MHz):

<img src="/HARDWARE/pictures/Fake Zilog Z84C0020PEC - U880.jpg" width="200">

