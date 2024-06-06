# Z80 CPU Tester

Version 1.2

Requires hardware v1 with 32kb EPROM/EEPROM and 32kb SRAM

Software:
- CPU identification
- includes Frank Cringle's Z80 instruction set exerciser

> [!IMPORTANT]
> **THIS FIRMWARE DOES NOT WORK PROPERLY**
>
> The CPU identification works fine. After that "Frank Cringle's Z80 
> instruction set exerciser" code is copied to address $8000 and started.
> The first test starts but the CPU "hangs" after starting the first test.
> To make the code compatible the BDOS call has been removed. Instead of
> displaying the test name, the test number is displayed on port A.


**After a successfull test it shows the result:**

**Port B:**

STATUS: `CU00tttt` (C = CMOS, U = UB880, tttt = type)

Type: Z80= `0000`, Z180= `0001`, Z280= `0010`, EZ80= `0011`, U880= `0100`, Clone= `0101`

An identified UB880 displays `0100 0100`.

**Port A:**

Counts the performed tests.

When testing is completed:
- the number of the failed test is displayed with a blinking bit 7, or 
- a running light shows a successfull result (no error).

> [!IMPORTANT]
> **THIS FIRMWARE DOES NOT WORK PROPERLY**
> 
> The program hangs showing `00000001` (first test).
