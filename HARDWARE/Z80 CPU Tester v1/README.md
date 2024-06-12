# Z80 CPU Tester

Hardware Version 1.1

> [!NOTE]
>
> Instead of the 27256 EPROM you can also use a AT29C256 EEPROM.

Some more notes:

The circuit uses a 74LS574 (or 74HC(T)574). An alternative version using the 74LS374 (or 74HC(T)374) is also available.

The 74LS574 can be LS or HCT (HC should work too).

You can even use the 74LS573 (the 74LS574 is clocked, the 74LS573 has a latch input). They both basically do the same thing, except that with the clock the values ​​are accepted on the rising edge, with the latch on the falling edge. With the Z80 the data is present before and after the MREQ/IORQ, so both work.
