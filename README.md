# Z80-CPU-Tester

<img src="/_pictures/z80cputester_v1.jpg" width="400">

## General info

This project allows you to test a Z80 CPU.

It tries
1. to identify the CPU technology (NMOS/CMOS),
2. to identify the CPU manufacturer,
3. to test whether the CPU is still functional,

and helps

4. to find out the max. supported clock rate.

The above results will help to identify fake CPUs.

It does not test
* Interrupts
* WAIT and HALT inputs signals
* M1 and RFSH output signals
* BUSRQ and BUSACK signals

The hardware has following features:
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

[Please check the licence files in the relevant directories. When you are interested in a PCB, please [contact me](https://8bit-museum.de/kontakt/).]

## Technologies

The project uses [KiCAD](https://www.kicad.org/) and [zmac](http://48k.ca/zmac.html).

## Sub-projects

The repository has been divided into several sub-projects.

The required hardware files can be found in the HARDWARE folder.

The required firmware is stored in the SOFTWARE folder.

## Examples

Zilog Z84C0020PEC from a Chinese marketplace. It is a U880 (running with 10 MHz):

<img src="/_pictures/Fake Zilog Z84C0020PEC - U880.jpg" width="200">
(picture shows hardware v1)

