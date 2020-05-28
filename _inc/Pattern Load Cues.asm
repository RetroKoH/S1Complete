; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------
ArtLoadCues:

ptr_PLC_Main:		dc.w PLC_Main-ArtLoadCues
ptr_PLC_Main2:		dc.w PLC_Main2-ArtLoadCues
ptr_PLC_Explode:	dc.w PLC_Explode-ArtLoadCues
ptr_PLC_GameOver:	dc.w PLC_GameOver-ArtLoadCues

PLC_Levels:
ptr_PLC_GHZ:		dc.w PLC_GHZ-ArtLoadCues
ptr_PLC_GHZ2:		dc.w PLC_GHZ2-ArtLoadCues
ptr_PLC_LZ:			dc.w PLC_LZ-ArtLoadCues
ptr_PLC_LZ2:		dc.w PLC_LZ2-ArtLoadCues
ptr_PLC_MZ:			dc.w PLC_MZ-ArtLoadCues
ptr_PLC_MZ2:		dc.w PLC_MZ2-ArtLoadCues
ptr_PLC_SLZ:		dc.w PLC_SLZ-ArtLoadCues
ptr_PLC_SLZ2:		dc.w PLC_SLZ2-ArtLoadCues
ptr_PLC_SYZ:		dc.w PLC_SYZ-ArtLoadCues
ptr_PLC_SYZ2:		dc.w PLC_SYZ2-ArtLoadCues
ptr_PLC_SBZ:		dc.w PLC_SBZ-ArtLoadCues
ptr_PLC_SBZ2:		dc.w PLC_SBZ2-ArtLoadCues
			zonewarning PLC_Levels,4

ptr_PLC_Boss:			dc.w PLC_Boss-ArtLoadCues
ptr_PLC_BossAlt:		dc.w PLC_BossAlt-ArtLoadCues ; Adjust this.
; In the future, we want different PLCs for every Boss
ptr_PLC_EndofAct:		dc.w PLC_EndofAct-ArtLoadCues
ptr_PLC_SpecialStage:	dc.w PLC_SpecialStage-ArtLoadCues

PLC_Animals:
ptr_PLC_GHZAnimals:	dc.w PLC_GHZAnimals-ArtLoadCues
ptr_PLC_LZAnimals:	dc.w PLC_LZAnimals-ArtLoadCues
ptr_PLC_MZAnimals:	dc.w PLC_MZAnimals-ArtLoadCues
ptr_PLC_SLZAnimals:	dc.w PLC_SLZAnimals-ArtLoadCues
ptr_PLC_SYZAnimals:	dc.w PLC_SYZAnimals-ArtLoadCues
ptr_PLC_SBZAnimals:	dc.w PLC_SBZAnimals-ArtLoadCues
			zonewarning PLC_Animals,2

ptr_PLC_SSResult:	dc.w PLC_SSResult-ArtLoadCues
ptr_PLC_Ending:		dc.w PLC_Ending-ArtLoadCues
ptr_PLC_TryAgain:	dc.w PLC_TryAgain-ArtLoadCues
ptr_PLC_EggmanSBZ2:	dc.w PLC_EggmanSBZ2-ArtLoadCues
ptr_PLC_FZBoss:		dc.w PLC_FZBoss-ArtLoadCues

plcm:	macro gfx,vram
	dc.l gfx
	dc.w vram
	endm

; ---------------------------------------------------------------------------
; Pattern load cues - standard block 1
; ---------------------------------------------------------------------------
PLC_Main:	dc.w ((PLC_Mainend-PLC_Main-2)/6)-1
		plcm	Nem_Hud,		ArtNem_HUD_locVRAM			; HUD
		plcm	Nem_Points,		ArtNem_Points_locVRAM	; points from enemy
	PLC_Mainend:
; ---------------------------------------------------------------------------
; Pattern load cues - standard block 2
; ---------------------------------------------------------------------------
PLC_Main2:	dc.w ((PLC_Main2end-PLC_Main2-2)/6)-1
		plcm	Nem_Lamp,		ArtNem_Lamppost_locVRAM		; lamppost
		plcm	Nem_Ring,		ArtNem_Ring_locVRAM 			; rings
		plcm	Nem_Monitors,	ArtNem_Monitors_locVRAM	; monitors
		plcm	Nem_Lives,		$FA80	; lives	counter
	PLC_Main2end:
; ---------------------------------------------------------------------------
; Pattern load cues - explosion
; ---------------------------------------------------------------------------
PLC_Explode:	dc.w ((PLC_Explodeend-PLC_Explode-2)/6)-1
		plcm	Nem_Explode,	ArtNem_Explosions_locVRAM	; explosion
	PLC_Explodeend:
; ---------------------------------------------------------------------------
; Pattern load cues - game/time	over
; ---------------------------------------------------------------------------
PLC_GameOver:	dc.w ((PLC_GameOverend-PLC_GameOver-2)/6)-1
		plcm	Nem_GameOver,	ArtNem_GameOver_locVRAM	; game/time over
	PLC_GameOverend:
; ---------------------------------------------------------------------------
; Pattern load cues - Green Hill
; ---------------------------------------------------------------------------
PLC_GHZ:	dc.w ((PLC_GHZ2-PLC_GHZ-2)/6)-1
		plcm	Nem_Stalk,		ArtNem_FlowerStalk_locVRAM	; flower stalk           ; (4 tiles)
		plcm	Nem_PplRock,	ArtNem_PurpleRock_locVRAM	; purple rock            ; (24 tiles)
		plcm	Nem_Crabmeat,	ArtNem_Crabmeat_locVRAM		; crabmeat enemy         ; (68 tiles)
		plcm	Nem_Buzz,		ArtNem_BuzzBomber_locVRAM	; buzz bomber enemy      ; (55 tiles)
		plcm	Nem_Chopper,	ArtNem_Chopper_locVRAM		; chopper enemy          ; (32 tiles)
		plcm	Nem_HSpring,	ArtNem_HSpring_locVRAM		; horizontal spring      ; (16 tiles)
		plcm	Nem_VSpring,	ArtNem_VSpring_locVRAM		; vertical spring        ; (14 tiles)
		plcm	Nem_Newtron,	ArtNem_Newtron_locVRAM		; newtron enemy
		plcm	Nem_Motobug,	ArtNem_Motobug_locVRAM		; motobug enemy
		plcm	Nem_Spikes,		ArtNem_Spikes_locVRAM		; spikes                 ; (8 tiles)

PLC_GHZ2:	dc.w ((PLC_GHZ2end-PLC_GHZ2-2)/6)-1
		plcm	Nem_GhzWall1,	ArtNem_GHZBreakWall_locVRAM	; breakable wall       ; (12 tiles)
		plcm	Nem_GhzWall2,	ArtNem_GHZEdgeWall_locVRAM	; edge wall            ; (12 tiles)
		plcm	Nem_Swing,		ArtNem_SwingPtform_locVRAM	; swinging platform
		plcm	Nem_Bridge,		ArtNem_Bridge_locVRAM		; bridge
		plcm	Nem_SpikePole,	ArtNem_GHZSpikePole_locVRAM	; spiked pole
		plcm	Nem_Ball,		ArtNem_GHZBall_locVRAM		; giant	ball           ; (38 tiles)
	PLC_GHZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Labyrinth
; ---------------------------------------------------------------------------
PLC_LZ:		dc.w ((PLC_LZ2-PLC_LZ-2)/6)-1
		plcm	Nem_LzBlock1,		ArtNem_LZBlock1_locVRAM		; block   (16 tiles)
		plcm	Nem_LzBlock2,		ArtNem_LZBlock2_locVRAM		; blocks (104 tiles)
		plcm	Nem_Waterfall,		ArtNem_LZWaterfall_locVRAM	; waterfalls (109 tiles)
;		plcm	Nem_Splash,			ArtNem_Splash_locVRAM		; water splash (35 tiles) Make uncompressed
		plcm	Nem_WaterSurface,	ArtNem_WaterSurface_locVRAM	; water	surface (16 tiles)
		plcm	Nem_LzSpikeBall,	ArtNem_LZSpikeball_locVRAM	; spiked ball (24 tiles)
		plcm	Nem_FlapDoor,		ArtNem_LZFlapDoor_locVRAM	; flapping door (32 tiles)
		plcm	Nem_Bubbles,		ArtNem_Bubbles_locVRAM		; bubbles and numbers, and bubbler (116 tiles)
		plcm	Nem_LzBlock3,		ArtNem_LZBlock3_locVRAM		; 32x16 block (8 tiles)
		plcm	Nem_LzDoor1,		ArtNem_LZDoor1_locVRAM		; vertical door (8 tiles)
		plcm	Nem_LzSwitch,		ArtNem_Switch_locVRAM		; switch
		plcm	Nem_Burrobot,		ArtNem_Burrobot_locVRAM		; burrobot enemy (90 tiles)

PLC_LZ2:	dc.w ((PLC_LZ2end-PLC_LZ2-2)/6)-1
		plcm	Nem_LzPole,			ArtNem_LZPole_locVRAM		; pole that breaks (8 tiles)
		plcm	Nem_LzDoor2,		ArtNem_LZDoor2_locVRAM		; large	horizontal door (16 tiles)
		plcm	Nem_LzWheel,		ArtNem_LZWheel_locVRAM		; conveyor wheel (72 tiles)
		plcm	Nem_Gargoyle,		ArtNem_LZGargoyle_locVRAM	; gargoyle head and fireballs (17 tiles)
		plcm	Nem_LzPlatfm,		ArtNem_LZPlatfm_locVRAM		; rising platform (24 tiles)
		plcm	Nem_Orbinaut,		ArtNem_Orbinaut_locVRAM		; orbinaut enemy
		plcm	Nem_Jaws,			ArtNem_Jaws_locVRAM			; jaws enemy
		plcm	Nem_Harpoon,		ArtNem_LZHarpoon_locVRAM	; harpoon (18 tiles)
		plcm	Nem_Cork,			ArtNem_LZCork_locVRAM		; cork block
		plcm	Nem_HSpring,		ArtNem_HSpring_locVRAM		; horizontal spring      ; (16 tiles)
		plcm	Nem_VSpring,		ArtNem_VSpring_locVRAM		; vertical spring        ; (14 tiles)
		plcm	Nem_Spikes,			ArtNem_Spikes_locVRAM		; spikes
	PLC_LZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Marble
; ---------------------------------------------------------------------------
PLC_MZ:		dc.w ((PLC_MZ2-PLC_MZ-2)/6)-1
		plcm	Nem_MzMetal,		ArtNem_MZMetal_locVRAM		; metal	blocks
		plcm	Nem_MzFire,			ArtNem_Fireball_locVRAM		; fireballs
		plcm	Nem_Swing,			ArtNem_SwingPtform_locVRAM	; swinging platform
		plcm	Nem_MzGlass,		ArtNem_MZGlass_locVRAM		; green	glassy block
		plcm	Nem_Lava,			ArtNem_MZLavaGeyser_locVRAM	; lava geysers
		plcm	Nem_Buzz,			ArtNem_BuzzBomber_locVRAM	; buzz bomber enemy      ; (55 tiles)
		plcm	Nem_Basaran,		ArtNem_Basaran_locVRAM		; basaran enemy
		plcm	Nem_Cater,			ArtNem_Caterkiller_locVRAM	; caterkiller enemy

PLC_MZ2:	dc.w ((PLC_MZ2end-PLC_MZ2-2)/6)-1
		plcm	Nem_MzSwitch,		ArtNem_Switch_locVRAM	; switch
		plcm	Nem_MzBlock,		ArtNem_MZBlock_locVRAM	; green	stone block
		plcm	Nem_Yadrin,			ArtNem_Yadrin_locVRAM	; Yadrin badnik
		plcm	Nem_HSpring,		ArtNem_HSpring_locVRAM	; horizontal spring      ; (16 tiles)
		plcm	Nem_VSpring,		ArtNem_VSpring_locVRAM	; vertical spring        ; (14 tiles)
		plcm	Nem_Spikes,			ArtNem_Spikes_locVRAM	; spikes
	PLC_MZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Star Light
; ---------------------------------------------------------------------------
PLC_SLZ:	dc.w ((PLC_SLZ2-PLC_SLZ-2)/6)-1
		plcm	Nem_Bomb,			ArtNem_Bomb_locVRAM			; bomb enemy
		plcm	Nem_Orbinaut,		ArtNem_Orbinaut_locVRAM		; orbinaut enemy
		plcm	Nem_MzFire,			ArtNem_Fireball_locVRAM		; fireballs
		plcm	Nem_SlzBlock,		ArtNem_SLZBlock_locVRAM		; block
		plcm	Nem_SlzWall,		ArtNem_SLZBreakWall_locVRAM	; breakable wall

PLC_SLZ2:	dc.w ((PLC_SLZ2end-PLC_SLZ2-2)/6)-1
		plcm	Nem_Seesaw,			ArtNem_SLZSeesaw_locVRAM	; seesaw
		plcm	Nem_Fan,			ArtNem_SLZFan_locVRAM		; fan
		plcm	Nem_Pylon,			ArtNem_SLZPylon_locVRAM		; foreground pylon
		plcm	Nem_SlzSwing,		ArtNem_SLZSwing_locVRAM		; swinging platform
		plcm	Nem_SlzCannon,		ArtNem_SLZCannon_locVRAM	; fireball launcher
		plcm	Nem_SlzSpike,		ArtNem_SLZSpike_locVRAM		; spikeball
		plcm	Nem_HSpring,		ArtNem_HSpring_locVRAM		; horizontal spring      ; (16 tiles)
		plcm	Nem_VSpring,		ArtNem_VSpring_locVRAM		; vertical spring        ; (14 tiles)
		plcm	Nem_Spikes, 		ArtNem_Spikes_locVRAM		; spikes
	PLC_SLZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Spring Yard
; ---------------------------------------------------------------------------
PLC_SYZ:	dc.w ((PLC_SYZ2-PLC_SYZ-2)/6)-1
		plcm	Nem_Crabmeat,	ArtNem_Crabmeat_locVRAM		; crabmeat enemy         ; (68 tiles)
		plcm	Nem_Buzz,		ArtNem_BuzzBomber_locVRAM	; buzz bomber enemy      ; (55 tiles)
		plcm	Nem_Yadrin, 	ArtNem_Yadrin_locVRAM	; yadrin enemy
		plcm	Nem_SyzSpike1,	ArtNem_SYZSpike_locVRAM	; large	spikeball
		plcm	Nem_SyzSpike2,	ArtNem_SYZSmallSpike_locVRAM	; small	spikeball
		plcm	Nem_Roller,		ArtNem_Roller_locVRAM	; roller enemy

PLC_SYZ2:	dc.w ((PLC_SYZ2end-PLC_SYZ2-2)/6)-1
		plcm	Nem_Bumper,		ArtNem_Bumper_locVRAM	; bumper
		plcm	Nem_LzSwitch,	ArtNem_Switch_locVRAM	; switch
		plcm	Nem_Cater,		ArtNem_Caterkiller_locVRAM	; caterkiller enemy
		plcm	Nem_HSpring,	ArtNem_HSpring_locVRAM	; horizontal spring      ; (16 tiles)
		plcm	Nem_VSpring,	ArtNem_VSpring_locVRAM	; vertical spring        ; (14 tiles)
		plcm	Nem_Spikes,		ArtNem_Spikes_locVRAM	; spikes
	PLC_SYZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Scrap Brain
; ---------------------------------------------------------------------------
PLC_SBZ:	dc.w ((PLC_SBZ2-PLC_SBZ-2)/6)-1
		plcm	Nem_Stomper,	ArtNem_SBZStomper_locVRAM	; moving platform and stomper
		plcm	Nem_SbzDoor1,	ArtNem_SBZDoor1_locVRAM	; small vertical door
		plcm	Nem_Girder,		ArtNem_SBZGirder_locVRAM	; girder
		plcm	Nem_BallHog,	ArtNem_Ballhog_locVRAM	; ball hog enemy
		plcm	Nem_SbzWheel1,	ArtNem_SBZWheel1_locVRAM	; spot on large	wheel
		plcm	Nem_SbzWheel2,	ArtNem_SBZWheel2_locVRAM	; wheel	that grabs Sonic
		plcm	Nem_SyzSpike1,	ArtNem_SBZSpike_locVRAM	; large	spikeball
		plcm	Nem_Cutter,		ArtNem_SBZCutter_locVRAM	; pizza	cutter
		plcm	Nem_FlamePipe,	ArtNem_SBZFlamepipe_locVRAM	; flaming pipe
		plcm	Nem_SbzFloor,	ArtNem_SBZFloor1_locVRAM	; collapsing floor
		plcm	Nem_SbzFloor,	ArtNem_SBZFloor2_locVRAM	; collapsing floor

PLC_SBZ2:	dc.w ((PLC_SBZ2end-PLC_SBZ2-2)/6)-1
		plcm	Nem_Cater,		ArtNem_Caterkiller_locVRAM	; caterkiller enemy
		plcm	Nem_Bomb,		ArtNem_Bomb_locVRAM		; bomb enemy
		plcm	Nem_SlideFloor,	ArtNem_SBZSlideFloor_locVRAM	; floor	that slides away
		plcm	Nem_SbzDoor2,	ArtNem_SBZDoor2_locVRAM	; horizontal door
		plcm	Nem_Electric,	ArtNem_SBZElectric_locVRAM	; electric orb
		plcm	Nem_TrapDoor,	ArtNem_SBZTrapdoor_locVRAM	; trapdoor
		plcm	Nem_SpinPform,	ArtNem_SBZSpinPlatfm_locVRAM	; small	spinning platform
		plcm	Nem_SbzBlock,	ArtNem_SBZBlock_locVRAM	; vanishing block
		plcm	Nem_LzSwitch,	ArtNem_Switch_locVRAM	; switch
		plcm	Nem_HSpring,	ArtNem_HSpring_locVRAM	; horizontal spring      ; (16 tiles)
		plcm	Nem_VSpring,	ArtNem_VSpring_locVRAM	; vertical spring        ; (14 tiles)
		plcm	Nem_Spikes,		ArtNem_Spikes_locVRAM	; spikes
	PLC_SBZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - act 3 boss
; ---------------------------------------------------------------------------
PLC_Boss:	dc.w ((PLC_Bossend-PLC_Boss-2)/6)-1
		plcm	Nem_Eggman,		ArtNem_Eggman_locVRAM	; Eggman main patterns
		plcm	Nem_Weapons,	ArtNem_Weapons_locVRAM	; Eggman's weapons
		plcm	Nem_Prison,		ArtNem_Prison_locVRAM	; prison capsule
		plcm	Nem_Bomb,		ArtNem_SLZWeapons_locVRAM	; bomb enemy (gets overwritten, shrapnel is used for SLZ boss)
		plcm	Nem_SlzSpike,	ArtNem_SLZWeapons_locVRAM	; spikeball (SLZ boss)
		plcm	Nem_Exhaust,	ArtNem_Exhaust_locVRAM	; exhaust flame
	PLC_Bossend:

PLC_BossAlt:	dc.w ((PLC_BossAltend-PLC_BossAlt-2)/6)-1
		plcm	Nem_Eggman_Alt,	ArtNem_Eggman_locVRAM	; Eggman main patterns
		plcm	Nem_Prison,		ArtNem_Prison_locVRAM	; prison capsule
		plcm	Nem_Bomb,		ArtNem_SLZWeapons_locVRAM	; bomb enemy (gets overwritten, shrapnel is used for SLZ boss)
		plcm	Nem_SlzSpike,	ArtNem_SLZWeapons_locVRAM	; spikeball (SLZ boss)
	PLC_BossAltend:
; ---------------------------------------------------------------------------
; Pattern load cues - act 1/2 end (Signpost is uncompressed)
; ---------------------------------------------------------------------------
PLC_EndofAct:	dc.w ((PLC_EndofActend-PLC_EndofAct-2)/6)-1
		plcm	Nem_Bonus, $96C0	; hidden bonus points
		plcm	Nem_BigFlash, $8C40	; giant	ring flash effect
	PLC_EndofActend:
; ---------------------------------------------------------------------------
; Pattern load cues - special stage
; ---------------------------------------------------------------------------
PLC_SpecialStage:	dc.w ((PLC_SpeStageend-PLC_SpecialStage-2)/6)-1
		plcm	Nem_SSBgCloud, 0	; bubble and cloud background
		plcm	Nem_SSBgFish, $A20	; bird and fish	background
		plcm	Nem_Ring, $2A40         ; Special Stage Rings
		plcm	Nem_Hud_SS, $3EA0	; HUD
		plcm	Nem_SSBumper, $4760	; bumper
		plcm	Nem_SSGOAL, $4A20	; GOAL block
		plcm	Nem_SSUpDown, $4C60	; UP and DOWN blocks
		plcm	Nem_SSRBlock, $5E00	; R block
		plcm	Nem_SS1UpBlock, $6E00	; 1UP block
		plcm	Nem_SSEmStars, $7E00	; emerald collection stars
		plcm	Nem_SSRedWhite, $8E00	; red and white	block
		plcm	Nem_SSGhost, $9E00	; ghost	block
		plcm	Nem_SSGlass, $BE00	; glass	block
		plcm	Nem_SSEmerald, $EE00	; emeralds
		plcm	Nem_Lives, $4560	; lives ; use a seperate PLC for this part of HUD
	PLC_SpeStageend:
; ---------------------------------------------------------------------------
; Pattern load cues - GHZ animals
; ---------------------------------------------------------------------------
PLC_GHZAnimals:	dc.w ((PLC_GHZAnimalsend-PLC_GHZAnimals-2)/6)-1
		plcm	Nem_Rabbit, $B000	; rabbit
		plcm	Nem_Flicky, $B240	; flicky
	PLC_GHZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - LZ animals
; ---------------------------------------------------------------------------
PLC_LZAnimals:	dc.w ((PLC_LZAnimalsend-PLC_LZAnimals-2)/6)-1
		plcm	Nem_BlackBird, $B000	; blackbird
		plcm	Nem_Seal, $B240		; seal
	PLC_LZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - MZ animals
; ---------------------------------------------------------------------------
PLC_MZAnimals:	dc.w ((PLC_MZAnimalsend-PLC_MZAnimals-2)/6)-1
		plcm	Nem_Squirrel, $B000	; squirrel
		plcm	Nem_Seal, $B240		; seal
	PLC_MZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - SLZ animals
; ---------------------------------------------------------------------------
PLC_SLZAnimals:	dc.w ((PLC_SLZAnimalsend-PLC_SLZAnimals-2)/6)-1
		plcm	Nem_Pig, $B000		; pig
		plcm	Nem_Flicky, $B240	; flicky
	PLC_SLZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - SYZ animals
; ---------------------------------------------------------------------------
PLC_SYZAnimals:	dc.w ((PLC_SYZAnimalsend-PLC_SYZAnimals-2)/6)-1
		plcm	Nem_Pig, $B000		; pig
		plcm	Nem_Chicken, $B240	; chicken
	PLC_SYZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - SBZ animals
; ---------------------------------------------------------------------------
PLC_SBZAnimals:	dc.w ((PLC_SBZAnimalsend-PLC_SBZAnimals-2)/6)-1
		plcm	Nem_Rabbit, $B000		; rabbit
		plcm	Nem_Chicken, $B240	; chicken
	PLC_SBZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - special stage results screen
; ---------------------------------------------------------------------------
PLC_SSResult:dc.w ((PLC_SpeStResultend-PLC_SSResult-2)/6)-1
		plcm	Nem_ResultEm, $A820	; emeralds
		plcm	Nem_MiniSonic, $AA20	; mini Sonic
	PLC_SpeStResultend:
; ---------------------------------------------------------------------------
; Pattern load cues - ending sequence
; ---------------------------------------------------------------------------
PLC_Ending:	dc.w ((PLC_Endingend-PLC_Ending-2)/6)-1
		plcm	Nem_Stalk, $6B00	; flower stalk
		plcm	Nem_EndFlower, $7400	; flowers
		plcm	Nem_EndEm, $78A0	; emeralds
		plcm	Nem_EndSonic, $7C20	; Sonic
		plcm	Nem_Rabbit, $AA60	; rabbit
		plcm	Nem_Chicken, $ACA0	; chicken
		plcm	Nem_BlackBird, $AE60	; blackbird
		plcm	Nem_Seal, $B0A0		; seal
		plcm	Nem_Pig, $B260		; pig
		plcm	Nem_Flicky, $B4A0	; flicky
		plcm	Nem_Squirrel, $B660	; squirrel
		plcm	Nem_EndStH, $B8A0	; "SONIC THE HEDGEHOG"
	PLC_Endingend:
; ---------------------------------------------------------------------------
; Pattern load cues - "TRY AGAIN" and "END" screens
; ---------------------------------------------------------------------------
PLC_TryAgain:	dc.w ((PLC_TryAgainend-PLC_TryAgain-2)/6)-1
		plcm	Nem_EndEm, $78A0	; emeralds
		plcm	Nem_TryAgain, $7C20	; Eggman
		plcm	Nem_CreditText, $B400	; credits alphabet
	PLC_TryAgainend:
; ---------------------------------------------------------------------------
; Pattern load cues - Eggman on SBZ 2
; ---------------------------------------------------------------------------
PLC_EggmanSBZ2:	dc.w ((PLC_EggmanSBZ2end-PLC_EggmanSBZ2-2)/6)-1
		plcm	Nem_SbzBlock, $A300	; block
		plcm	Nem_Sbz2Eggman, $8000	; Eggman
		plcm	Nem_LzSwitch, $9400	; switch
	PLC_EggmanSBZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - final boss
; ---------------------------------------------------------------------------
PLC_FZBoss:	dc.w ((PLC_FZBossend-PLC_FZBoss-2)/6)-1
		plcm	Nem_FzEggman, $7400	; Eggman after boss
		plcm	Nem_FzBoss, $6000	; FZ boss
		plcm	Nem_Eggman, $8000	; Eggman main patterns
		plcm	Nem_Sbz2Eggman, $8E00	; Eggman without ship
		plcm	Nem_Exhaust, $A540	; exhaust flame
	PLC_FZBossend:
		even

; ---------------------------------------------------------------------------
; Pattern load cue IDs
; ---------------------------------------------------------------------------
plcid_Main:			equ (ptr_PLC_Main-ArtLoadCues)/2		; 0
plcid_Main2:		equ (ptr_PLC_Main2-ArtLoadCues)/2		; 1
plcid_Explode:		equ (ptr_PLC_Explode-ArtLoadCues)/2		; 2
plcid_GameOver:		equ (ptr_PLC_GameOver-ArtLoadCues)/2	; 3
plcid_GHZ:			equ (ptr_PLC_GHZ-ArtLoadCues)/2			; 4
plcid_GHZ2:			equ (ptr_PLC_GHZ2-ArtLoadCues)/2		; 5
plcid_LZ:			equ (ptr_PLC_LZ-ArtLoadCues)/2			; 6
plcid_LZ2:			equ (ptr_PLC_LZ2-ArtLoadCues)/2			; 7
plcid_MZ:			equ (ptr_PLC_MZ-ArtLoadCues)/2			; 8
plcid_MZ2:			equ (ptr_PLC_MZ2-ArtLoadCues)/2			; 9
plcid_SLZ:			equ (ptr_PLC_SLZ-ArtLoadCues)/2			; $A
plcid_SLZ2:			equ (ptr_PLC_SLZ2-ArtLoadCues)/2		; $B
plcid_SYZ:			equ (ptr_PLC_SYZ-ArtLoadCues)/2			; $C
plcid_SYZ2:			equ (ptr_PLC_SYZ2-ArtLoadCues)/2		; $D
plcid_SBZ:			equ (ptr_PLC_SBZ-ArtLoadCues)/2			; $E
plcid_SBZ2:			equ (ptr_PLC_SBZ2-ArtLoadCues)/2		; $F
plcid_Boss:			equ (ptr_PLC_Boss-ArtLoadCues)/2		; $11
plcid_BossAlt:		equ (ptr_PLC_BossAlt-ArtLoadCues)/2
plcid_EndofAct:		equ (ptr_PLC_EndofAct-ArtLoadCues)/2	; $12
plcid_SpecialStage:	equ (ptr_PLC_SpecialStage-ArtLoadCues)/2 ; $14
plcid_GHZAnimals:	equ (ptr_PLC_GHZAnimals-ArtLoadCues)/2	; $15
plcid_LZAnimals:	equ (ptr_PLC_LZAnimals-ArtLoadCues)/2	; $16
plcid_MZAnimals:	equ (ptr_PLC_MZAnimals-ArtLoadCues)/2	; $17
plcid_SLZAnimals:	equ (ptr_PLC_SLZAnimals-ArtLoadCues)/2	; $18
plcid_SYZAnimals:	equ (ptr_PLC_SYZAnimals-ArtLoadCues)/2	; $19
plcid_SBZAnimals:	equ (ptr_PLC_SBZAnimals-ArtLoadCues)/2	; $1A
plcid_SSResult:		equ (ptr_PLC_SSResult-ArtLoadCues)/2	; $1B
plcid_Ending:		equ (ptr_PLC_Ending-ArtLoadCues)/2		; $1C
plcid_TryAgain:		equ (ptr_PLC_TryAgain-ArtLoadCues)/2	; $1D
plcid_EggmanSBZ2:	equ (ptr_PLC_EggmanSBZ2-ArtLoadCues)/2	; $1E
plcid_FZBoss:		equ (ptr_PLC_FZBoss-ArtLoadCues)/2		; $1F
