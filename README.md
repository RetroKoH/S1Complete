S1C_git
============

Sonic 1 Complete Project Files. Built from the Clownacy S1 Two-Eight Disassembly.
See: http://info.sonicretro.org/Disassemblies

This uses Sonic 2's 128x128 chunk and path-swapper systems. Modifications by MarkeyJester and Clownacy.
See: http://info.sonicretro.org/Project_Sonic_1:_Two-Eight

Hack To-Do List:

- Add sounds and visuals to the drop dash, in line with what the latest Sonic 1 re-release (Mega Play) did.
- Fix garbled HUD that occurs when going from level to special stage and vice versa. Can fix by scrolling it out.
- SBZ3's issue is a result of me porting the new art in via SonLvl. I don't wanna pin all the blame on that app, perhaps I made an error somewhere. It'll be a simple fix, just time-consuming... As for the points, I had no idea. Nice catch.
- On that note, Ralakimus pointed out a bug in that zone related to floor collision. IDK how that happened and plan on fixing it ASAP.
- Flower art is broken, AND palettes when NOT in normal mode. I will get to that later on.
- Fix the rings in the ENDGAME screen. The level_started flag must not be getting cleared at the end of the credits.
* Fix bug with executing Peelout at the right edge of the screen (similar to the spindash bug)
	Noticable in bosses.
* Add underwater and cycling palettes for Easy/Hard Mode
* Finish Easy Mode layouts. Need feedback from others.
* Improve Drop Dash physics

DISCLAIMER:
Any and all content presented in this repository is presented for informational and educational purposes only.
Commercial usage of the complete package or any parts therein is expressly prohibited.
