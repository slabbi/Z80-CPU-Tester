# Z80 CPU Tester Model 1

The Z80 CPU Tester Model 1 is an easy to use CPU tester.

It has no other gimmicks and can therefore be programmed very easily.

<img src="/_pictures/z80cputester_v1.jpg" width="400">

## Some notes:

* If you want to test at 20 MHz, use fast memory components (normally you don't have to worry about it), e.g 70ns or faster.

### 74LS574

* The 74LS574 can be a LS or HCT type (HC should work too).
* You can even use the 74LS573 (the 74LS574 is clocked, the 74LS573 has a latch input). They both basically do the same thing, except that with the clock the values are accepted on the rising edge, with the latch on the falling edge. With the Z80 the data is present before and after the MREQ/IORQ, so both work.
* The circuit uses a 74LS574 (or 74HC(T)574). An alternative version using the 74LS374 (or 74HC(T)374) is also available.

### 27C256

* Instead of the 27256 EPROM you can also use a AT29C256 EEPROM.
* You can also use a Winbond W27C512. Note that Pin 1 is connected to Vcc, so when using a W27C512 you have to program the firmware at address 0x8000.

### SRAM 32k x 8

* The SRAM is a standard 32k x 8, e.g. 61256, 62256, 51256, 43256 or others.

[The files in this directory may be used freely for personal use. **Commercial use is not permitted.**

When you are interested in a PCB, please [contact me](https://8bit-museum.de/kontakt/).]

## Changelog Hardware 1.x

* 1.1 - official "github version"
* 1.2 - Vcc LED added, Jumper "Current Measurement" added (when removed the current of the CPU can be measured)
