# Z80 CPU Tester Model 2

The Z80 CPU Tester Model 2 uses some additional components compared to Model 1.
These components add an additional input and output ports for own experiments.

It is a little bit more complex to program because the signal is inverted when read.

<img src="/_pictures/z80cputester_v2.jpg" width="400">

## Some notes:

* If you want to test at 20 MHz, use fast memory components (normally you don't have to worry about it), e.g 70ns or faster.
* When you do not want to do experiements with the inout and output ports, you must not assemble: J1, J2 (input port); J3, J13 (output ports); J12, J14, J15 (Power).

### 74HC04

* The 74HC04 can be a HC or HCU type (HCT can work but usually it is not recommended). The 74HCU04 is the best choice for the Pierce Oscillator but when you don't already have it try a 74HC04 first.
* When you have problems with the 16/20 MHz clock (can be measured at pin 1/3 of JP1), replace R4 (for 20 MHz) and/or R3 (for 16 MHz) with 100 Ohm (instead of 1k Ohm).
### 74LS574

* The 74LS574 can be a LS or HCT type (HC should work too).
* You can even use the 74LS573 (the 74LS574 is clocked, the 74LS573 has a latch input). They both basically do the same thing, except that with the clock the values are accepted on the rising edge, with the latch on the falling edge. With the Z80 the data is present before and after the MREQ/IORQ, so both work.

### 74LS573

* The 74LS573 can be LS or HCT (HC should work too).
* The 74LS573 *cannot* be replaced by a 74LS574.

### 27C256

* Instead of the 27256 EPROM you can also use an AT29C256 Flash Memory (the AT28C256 is *not* pin compatible).
* You can also use a Winbond W27C512. Note that Pin 1 is connected to Vcc, so when using a W27C512 you have to program the firmware at address 0x8000.

### SRAM 32k x 8

* The SRAM is a standard 32k x 8, e.g. 61256, 62256, 51256, 43256 or others.

[The files in this directory may be used freely for personal use. **Commercial use is not permitted.** When you are interested in a PCB, please [contact me](https://8bit-museum.de/kontakt/).]

## Changelog Hardware 2.x

* 2.5 - official "github version"