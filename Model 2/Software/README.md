# Z80 CPU Tester Model 2

## Firmware

This firmware requires hardware for Model 2 with 32kb EPROM/EEPROM and 32kb SRAM and the additional input port.

The firmware is identical for both hardware models (Model 1 and Model 2), only a flag at the beginning changes the model of the hardware used.

Software features:
- CPU identification
- tests the functionality of a few commands (these tests are not really thorough and well thought out and should only be considered as proof of concept) and executes some more complex routines

A compiled firmware file is available ("*.bin").

## Performed tests

Following tests are performed:
1. memory access, load 16 bit register load
2. RL, RR, load register to register
3. ADD, SUB
4. PUSH, POP, SBC
5. ADD, SUB, INC, DEC
6. some 16 bit multiplications (ADD, RL)
7. some 32 bit multiplications (ADD, ADC, SBC, PUSH, POP, RRA, EX)
8. calculates some square roots (BIT, RL, ADD, SUB)
9. plays Towers of Hanoi (PUSH, POP, CALL)
10. calculates Pi (EX, EXX, IX, IY, INC, DEC, ADD, ADC, SBC, SRL, RR, PUSH, CALL)

Pi is calculated to 100 digits. This takes about 30 seconds at 4 Mhz.
When you test CPUs at lower speeds the number of calculated digits
should be reduced.

## Display of test results

### Port B

STATUS: `CU00tttt` (C = CMOS, U = UB880, tttt = type)

**Type (tttt)**
```
0000 - not used
0001 - Z180
0010 - Z280
0011 - EZ80 
0100 - U880 (newer; MME U880, Thesys Z80, Microelectronica MMN 80CPU)
0101 - U880 (older; MME U880, KR1858VM1)
0110 - SHARP LH5080
0111 - NMOS Z80 (Zilog Z80, Zilog Z08400 or similar NMOS CPU, Mosstek MK3880N, SGS/ST Z8400, Sharp LH0080A, KR1858VM1)
1000 - NEC D780C (NEC D780C, GoldStar Z8400, possibly KR1858VM1)
1001 - KR1858VM1 (overclocked)
1010 - Unknown NMOS Z80 Clone
1011 - CMOS Z80 (Zilog Z84C00)
1100 - Toshiba Z80 (Toshiba TMPZ84C00AP, ST Z84C00AB)
1101 - NEC D70008AC
1110 - Unknown CMOS Z80 Clone
1111 - NEC Z80 Clone (NMOS)
```

**CMOS-LED (C)**

* When "on", a CMOS CPU has been detected (`OUT (C),0 outputs $ff`).
* When "blinking", a CMOS CPU has been detected (`OUT (C),0 outputs $00`).
* When "off", a NMOS CPU has been detected (`OUT (C),0 outputs $00`).

Note: The Sharp LH5080A (CMOS version of LH0080A) "fails" the CMOS test, and the undocumented `OUT (C),0` instruction behaves the same way it does on NMOS CPUs. The CMOS-LED is blinking.

**U880-LED (U)**

When "on", a U880 CPU has been detected (U880, UA880, UB880 and similar), otherwise it is "off"
 
**Example**

An identified UB880 displays `0100 0100` (Port B).


### Port A

Counts the performed tests.

When testing is completed:
- the number of the failed test is displayed with a blinking bit 7, or 
- a running light shows a successful result (no error).

## Display XF results and XF/YF counters

The XY result and the XF/XF counters can be displayed by pressing the NMI button.

After pressing the NMI button, the CPU tester will - after a short time - blink three times (alternating "xxxxoooo ooooxxxx" patterns).
Then consecutively displays

- the XFRESULT (Port A)
- the XFCOUNTER (Port B/A)
- the YFCOUNTER (Port B/A)
- the FLAGS result (Port A) for `A = 0, F = FF` / (result can be `$00, $08, $20, $28`)

will be displayed.

The output will be pretty fast (depending on the CPU clock), so you should record the output with your mobile phone to analyze it later.

For more information visit [Sergey Kiselev repository](https://github.com/skiselev/z80-tests/blob/main/Results.md).

## XFRESULT encoding

- `A[7:6]` - YF result of `F = 0, A = C | 0x20 & 0xF7` (F.5 set, F.3 reset)
- `A[5:4]` - XF result of `F = 0, A = C | 0x08 & 0xDF` (F.3 set, F.5 reset)
- `A[3:2]` - YF result of `F = C | 0x20 & 0xF7, A = 0` (F.5 set, F.3 reset)
- `A[1:0]` - XF result of `F = C | 0x08 & 0xDF, A = 0` (F.3 set, F.5 reset)

Where the result bits set as follows:
- `00` - flag always set as 0
- `11` - flag always set as 1
- `01` - flag most of the time set as 0
- `10` - flag most of the time set as 1

Note: YF aka F.5, XF aka F.3

## Compilation of firmware

Use `zmac` to compile the assembler source:
```
zmac --oo cim,hex,lst <file>
```
The `cim`-File is a binary file that can be used to program a 27C256 EPROM or AT29C256 EEPROM.

In the folders a ready to use binary can be found.

## Using the Input/Output ports

If one of the input pins (port A) is pulled down (connected to GND) after NMI is pushed, the firmware starts an infinite loop that 
reads a pattern from port A and outputs that pattern to port B. The corresponding code is found at the beginning of "nmifunction" 
(checks if an input is pulled down) and "readAtoB" (reads from port A and outputs to port B). 

The ports can be used to control external hardware, e.g. a display.

## Examples

Zilog Z84C0020PEC from a Chinese marketplace. It is a U880 (running with 10 MHz):

<img src="/_pictures/Fake Zilog Z84C0020PEC - U880.jpg" width="200">
(picture shows Z80 CPU Tester Model 1)


[My files in that directory are published under MIT license, some files have a more permissive licensing.
Please check the file header regarding the used license.]
