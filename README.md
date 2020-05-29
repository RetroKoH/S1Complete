S1C_git
============

Sonic 1 Complete Project Files. Built from the Clownacy S1 Two-Eight Disassembly.
See: http://info.sonicretro.org/Disassemblies

This uses Sonic 2's 128x128 chunk and path-swapper systems. Modifications by MarkeyJester and Clownacy.
See: http://info.sonicretro.org/Project_Sonic_1:_Two-Eight

Hack To-Do List:

- I am aware of the drop dash, and would love the assistance. I was planning to leave it alone and figure it out myself later using the pseudo-code MainMemory posted, but if you are willing to help, I certainly won't refuse it.
- I agree about the sounds and visuals, though I'll probably keep it simple, in line with what the latest Sonic 1 re-release (Mega Play) did, though I'm curious to get your thoughts.
- The HUD issues I'm aware of. The former, I'm not sure exactly how to fix. This started happening after I ported the S2 non-object HUD and is part of the reason why the HUD now scrolls in and out of frame. The latter issue (which I just noticed earlier today while applying a change to special stages) I'm sure is a simple enough fix. I'll tackle that first.
- SBZ3's issue is a result of me porting the new art in via SonLvl. I don't wanna pin all the blame on that app, perhaps I made an error somewhere. It'll be a simple fix, just time-consuming... As for the points, I had no idea. Nice catch.
- On that note, Ralakimus pointed out a bug in that zone related to floor collision. IDK how that happened and plan on fixing it ASAP.
- Flower art is broken, AND palettes when NOT in normal mode. I will get to that later on.
- Cheers for pointing out the rings in the END screen. The level_started flag must not be getting cleared at the end of the credits. I'll look through that and get that fixed.

What is the difference between LevelSelect_PressStart and LevelSelect_StartZone?

* Fix bug with executing Peelout at the right edge of the screen (similar to the spindash bug)
	Noticable in bosses.
* Add underwater and cycling palettes for Easy/Hard Mode
* Fix minor palette errors (Buzz Bomber Missile, SLZ Boss spikeball)
* Finish Easy Mode layouts. Need feedback from others.
* Give Drop Dash proper physics

DISCLAIMER:
Any and all content presented in this repository is presented for informational and educational purposes only.
Commercial usage of the complete package or any parts therein is expressly prohibited.
