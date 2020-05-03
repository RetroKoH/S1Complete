@echo off

IF EXIST S1C.bin move /Y S1C.bin S1C.prev.bin >NUL
asm68k /k /p /o ae- sonic.asm, S1C.bin >errors.txt, S1C.sym, S1C.lst
convsym S1C.lst S1C.bin -input asm68k_lst -inopt "/localSign=@ /localJoin=. /ignoreMacroDefs+ /ignoreMacroExp- /addMacrosAsOpcodes+" -a
fixheadr.exe S1C.bin