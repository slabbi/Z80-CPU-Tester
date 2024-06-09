# Z80 CPU Tester

Version 1.1

Requires hardware v1 with 32kb EPROM/EEPROM and 32kb SRAM

Software:
- CPU identification
- tests a few commands (these tests are not really thorough and well thought out and should only be considered as proof of concept)

**Display of test results:**

**Port B:**

STATUS: `CU00tttt` (C = CMOS, U = UB880, tttt = type)

Type: Z80= `0000`, Z180= `0001`, Z280= `0010`, EZ80= `0011`, U880= `0100`, Clone= `0101`

An identified UB880 displays `0100 0100`.

**Port A:**

Counts the performed tests.

When testing is completed:
- the number of the failed test is displayed with a blinking bit 7, or 
- a running light shows a successfull result (no error).

## Performed tests

1. test memory access, 16 bit register load
2. test RL, RR, register to register load
3. test ADD, SUB
4. test PUSH, POP, 16 bit SBC
5. test sub, add, inc, dec
6. test some 16 bit multiplication
7. test some 64 bit multiplication
8. test some square toots (BIT, RL, ADD, SUB)
9. calculate Pi

Pi is calculated to 100 digits. This takes about 30 seconds at 4 Mhz.
When you test CPUs at lower speeds the number of calculated digits
should be reduced.
