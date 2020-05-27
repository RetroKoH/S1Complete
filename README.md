S1C_git
============

Sonic 1 Complete Project Files. Built from the Clownacy S1 Two-Eight Disassembly.
See: http://info.sonicretro.org/Disassemblies

This uses Sonic 2's 128x128 chunk and path-swapper systems. Modifications by MarkeyJester and Clownacy.
See: http://info.sonicretro.org/Project_Sonic_1:_Two-Eight

Hack To-Do List:
* Enable SLZ boss to be fought in SLZ2 Easy.
* Enable Final Zone boss to be fought in SBZ2 Easy.
* Add a second boss flag to tell the engine not to execute EndofAct subroutine instead of using Act #.
	This flag can be set in DLE's and cleared by the Got Through Flag (or start of next level)
* Ensure proper clearing of Speed Shoes. We only want fast boss music in Pinch mode
* Fix bug with executing Peelout at the right edge of the screen (similar to the spindash bug)
	Noticable in bosses.
* Add underwater and cycling palettes for Easy/Hard Mode
* Fix minor palette errors (Buzz Bomber Missile, SLZ Boss spikeball)
* Give Drop Dash proper physics

DISCLAIMER:
Any and all content presented in this repository is presented for informational and educational purposes only.
Commercial usage of the complete package or any parts therein is expressly prohibited.
