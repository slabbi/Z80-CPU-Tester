# Z80 CPU Tester Firmware

Firmware for Hardware v1:
* v1.1: CPU identification (very detailed), tests some commands, performs extensive functional tests

Use `zmac` to compile the assembler source:
```
zmac --oo cim,hex,lst <file>
```
The `cim`-File is a binary file that can be used to program a 27C256 EPROM or AT29C256 EEPROM.

[My files in that directory are published under MIT license, some files have a more permissive licensing. Please check the file header regarding the used license.]
