# Z80 CPU Tester

Version 1.1

Requires hardware v1 with 32kb EPROM/EEPROM and 32kb SRAM

Software:
- CPU identification
- tests a few commands (these tests are not really thorough and well thought out and should only be considered as proof of concept)

After a successfull test it shows the result:

## Port B:

STATUS: CU00tttt (C = CMOS, U = UB880, tttt = type)

Z80= 0000, Z180= 0001, Z280= 0010, EZ80= 0011, U880= 0100, Clone= 0101

An identified UB880 displays [0100 0100}.

## Port A:

Counts the performed tests.

When done either 
- the number of the failed test is displayed with a blinking bit 7, or 
- a running light shows a successfull result.