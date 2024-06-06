# Z80 CPU Tester Firmware

Firmware for Hardware v1:
* v1.1: CPU identification, tests a few commands (proof of concept)
* v1.2: CPU identification, uses "Frank Cringle's Z80 instruction set exerciser"

Use `zmac` to compile the assembler source:
```
zmac --oo cim,hex,lst <file>
```
The `cim`-File is a binary file that can be used to program a 27C256 EPROM or AT29C256 EEPROM.
