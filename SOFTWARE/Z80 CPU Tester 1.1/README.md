# Z80 CPU Tester

Version 1.1

This firmware requires hardware v1 with 32kb EPROM/EEPROM and 32kb SRAM.

Software features:
- CPU identification
- tests the functionality of a few commands (these tests are not really thorough and well thought out and should only be considered as proof of concept) and executes some more complex routines

## Performed tests

Following tests are performed:
1. memory access, load 16 bit register load, load register to register
2. RL, RR
3. ADD, SUB, SBC, INC, DEC
4. PUSH, POP
5. some 16 bit multiplications (ADD, RL)
6. some 32 bit multiplications (ADD, ADC, SBC, PUSH, POP, RRA, EX)
7. calculates some square roots (BIT, RL, ADD, SUB)
8. plays Towers of Hanoi (PUSH, POP, CALL)
9. calculates Pi (EX, EXX, IX, IY, INC, DEC, ADD, ADC, SBC, SRL, RR, PUSH, CALL)

Pi is calculated to 100 digits. This takes about 30 seconds at 4 Mhz.
When you test CPUs at lower speeds the number of calculated digits
should be reduced.

## Display of test results

**Port B:**

STATUS: `CU00tttt` (C = CMOS, U = UB880, tttt = type)

Type:
```
0000 - not used
0001 - Z180
0010 - Z280
0011 - EZ80 
0100 - U880 (newer; MME U880, Thesys Z80, Microelectronica MMN 80CPU)
0101 - U880 (older; MME U880)
0110 - SHARP LH5080A
0111 - NMOS Z80 (Zilog Z80, Zilog Z08400 or similar NMOS CPU, Mosstek MK3880N, SGS/ST Z8400, Sharp LH0080A, KR1858VM1)
1000 - NEC D780C (NEC D780C, GoldStar Z8400, possibly KR1858VM1)
1001 - KR1858VM1 (overclocked)
1010 - Unknown NMOS Z80 Clone
1011 - CMOS Z80 (Zilog Z84C00)
1100 - Toshiba Z80 (Toshiba TMPZ84C00AP, ST Z84C00AB)
1101 - NEC D70008AC
1110 - Unknown CMOS Z80 Clone
1111 - NEC Z80 Clone
```

An identified UB880 displays `0100 0100` (Port B).

Some Notes:
- Sharp LH5080A - the CMOS Sharp Z80 variant "fails" the CMOS test, and the undocumented OUT (C),0 instruction behaves the same way it does on NMOS CPUs.

**Port A:**

Counts the performed tests.

When testing is completed:
- the number of the failed test is displayed with a blinking bit 7, or 
- a running light shows a successfull result (no error).

## Display XF results and XF/YF counters

The XY result and the XF/XF counters can be displayed by pressing the NMI button.

After pressing the NMI button, the CPU tester will - after a short time - blink three times (alternating "xxxxoooo ooooxxxx" pattern).
Then consecutively

- the XF result (Port A)
- the XF counter (Port B/A)
- the YF counter (Port B/A)

will be displayed.

The output will be pretty fast (depending on the CPU clock), so you should record the output with your mobile phone to analyze it later.

For more information visit [Sergey Kiselev repository](https://github.com/skiselev/z80-tests/blob/main/Results.md).
