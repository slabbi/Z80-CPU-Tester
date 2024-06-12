# Z80 CPU Tester

Version 1.1

This firmware requires hardware v1 with 32kb EPROM/EEPROM and 32kb SRAM.

Software features:
- CPU identification
- tests the functionality of a few commands (these tests are not really thorough and well thought out and should only be considered as proof of concept) and executes some more complex routines

## Performed tests

1. test memory access, 16 bit register load
2. test RL, RR, register to register load
3. test ADD, SUB
4. test PUSH, POP, SBC
5. test SUB, ADD, INC, DEC
6. test some 16 bit multiplication (ADD, RL)
7. test some 32 bit multiplication (ADD, ADC, SBC, PUSH, POP, RRA, EX)
8. test some square toots (BIT, RL, ADD, SUB)
9. play Towers of Hanoi (PUSH, POP, CALL)
10. calculate Pi (EX, EXX, IX, IY, INC, DEC, ADD, ADC, SBC, SRL, RR, PUSH, CALL)

Pi is calculated to 100 digits. This takes about 30 seconds at 4 Mhz.
When you test CPUs at lower speeds the number of calculated digits
should be reduced.

## Display of test results

**Port B:**

STATUS: `CU00tttt` (C = CMOS, U = UB880, tttt = type)

Type:
```
`0000` ---
`0001` Z180
`0010` Z280
`0011` EZ80 
`0100` U880 (new)
`0101` U880 (old)
`0110` SHARP LH5080A
`0111` NMOS Z80
`1000` NEC D780C
`1001` KR1858VM1
`1010` NMOS unknown
`1011` CMOS Z80
`1100` Toshiba Z80
`1101` NEC D70008AC
`1110` CMOS unknown
`1111` NEC Clone
```

An identified UB880 displays `0100 0100`.

**Port A:**

Counts the performed tests.

When testing is completed:
- the number of the failed test is displayed with a blinking bit 7, or 
- a running light shows a successfull result (no error).
