; ---------------------------------------------------------------------------
; Constants
; ---------------------------------------------------------------------------

Size_of_SegaPCM:		equ $6978

; VDP addressses
vdp_data_port:			equ $C00000
vdp_control_port:		equ $C00004
vdp_counter:			equ $C00008

psg_input:				equ $C00011

; Z80 addresses
z80_ram:				equ $A00000	; start of Z80 RAM
z80_dac3_pitch:			equ $A000EA
z80_dac_status:			equ $A01FFD
z80_dac_sample:			equ $A01FFF
z80_ram_end:			equ $A02000	; end of non-reserved Z80 RAM
z80_version:			equ $A10001
z80_port_1_data:		equ $A10002
z80_port_1_control:		equ $A10008
z80_port_2_control:		equ $A1000A
z80_expansion_control:	equ $A1000C
z80_bus_request:		equ $A11100
z80_reset:				equ $A11200
ym2612_a0:				equ $A04000
ym2612_d0:				equ $A04001
ym2612_a1:				equ $A04002
ym2612_d1:				equ $A04003

security_addr:			equ $A14000

; Sound driver constants
TrackPlaybackControl:	equ 0		; All tracks
TrackVoiceControl:	equ 1		; All tracks
TrackTempoDivider:	equ 2		; All tracks
TrackDataPointer:	equ 4		; All tracks (4 bytes)
TrackTranspose:		equ 8		; FM/PSG only (sometimes written to as a word, to include TrackVolume)
TrackVolume:		equ 9		; FM/PSG only
TrackAMSFMSPan:		equ $A		; FM/DAC only
TrackVoiceIndex:	equ $B		; FM/PSG only
TrackVolEnvIndex:	equ $C		; PSG only
TrackStackPointer:	equ $D		; All tracks
TrackDurationTimeout:	equ $E		; All tracks
TrackSavedDuration:	equ $F		; All tracks
TrackSavedDAC:		equ $10		; DAC only
TrackFreq:		equ $10		; FM/PSG only (2 bytes)
TrackNoteTimeout:	equ $12		; FM/PSG only
TrackNoteTimeoutMaster:equ $13		; FM/PSG only
TrackModulationPtr:	equ $14		; FM/PSG only (4 bytes)
TrackModulationWait:	equ $18		; FM/PSG only
TrackModulationSpeed:	equ $19		; FM/PSG only
TrackModulationDelta:	equ $1A		; FM/PSG only
TrackModulationSteps:	equ $1B		; FM/PSG only
TrackModulationVal:	equ $1C		; FM/PSG only (2 bytes)
TrackDetune:		equ $1E		; FM/PSG only
TrackPSGNoise:		equ $1F		; PSG only
TrackFeedbackAlgo:	equ $1F		; FM only
TrackVoicePtr:		equ $20		; FM SFX only (4 bytes)
TrackLoopCounters:	equ $24		; All tracks (multiple bytes)
TrackGoSubStack:	equ TrackSz	; All tracks (multiple bytes. This constant won't get to be used because of an optimisation that just uses zTrackSz)

TrackSz:	equ $30

; VRAM data
vram_fg:	equ $C000	; foreground namespace
vram_bg:	equ $E000	; background namespace
vram_sonic:	equ $F000	; Sonic graphics
vram_sprites:	equ $F800	; sprite table
vram_hscroll:	equ $FC00	; horizontal scroll table

; Game modes
id_Sega:		equ ptr_GM_Sega-GameModeArray			; $00
id_Title:		equ ptr_GM_Title-GameModeArray			; $04
id_Demo:		equ ptr_GM_Demo-GameModeArray			; $08
id_Level:		equ ptr_GM_Level-GameModeArray			; $0C
id_Special:		equ ptr_GM_Special-GameModeArray		; $10
id_Continue:	equ ptr_GM_Cont-GameModeArray			; $14
id_Ending:		equ ptr_GM_Ending-GameModeArray			; $18
id_Credits:		equ ptr_GM_Credits-GameModeArray		; $1C
id_Bonus:		equ ptr_GM_BonusStage-GameModeArray		; $20
id_MenuScreen:	equ ptr_GM_MenuScreen-GameModeArray		; $24

; Levels
id_GHZ:		equ 0
id_LZ:		equ 1
id_MZ:		equ 2
id_SLZ:		equ 3
id_SYZ:		equ 4
id_SBZ:		equ 5
id_EndZ:	equ 6
id_SS:		equ 7

; Colours
cBlack:		equ $000		; colour black
cWhite:		equ $EEE		; colour white
cBlue:		equ $E00		; colour blue
cGreen:		equ $0E0		; colour green
cRed:		equ $00E		; colour red
cYellow:	equ cGreen+cRed		; colour yellow
cAqua:		equ cGreen+cBlue	; colour aqua
cMagenta:	equ cBlue+cRed		; colour magenta

; Joypad input
btnStart:	equ %10000000 ; Start button	($80)
btnA:		equ %01000000 ; A		($40)
btnC:		equ %00100000 ; C		($20)
btnB:		equ %00010000 ; B		($10)
btnR:		equ %00001000 ; Right		($08)
btnL:		equ %00000100 ; Left		($04)
btnDn:		equ %00000010 ; Down		($02)
btnUp:		equ %00000001 ; Up		($01)
btnDir:		equ %00001111 ; Any direction	($0F)
btnABC:		equ %01110000 ; A, B or C	($70)
bitStart:	equ 7
bitA:		equ 6
bitC:		equ 5
bitB:		equ 4
bitR:		equ 3
bitL:		equ 2
bitDn:		equ 1
bitUp:		equ 0

; Object variables
obID:			equ 0	; Object ID number
obRender:		equ 1	; bitfield for x/y flip, display mode
obGfx:			equ 2	; palette line & VRAM setting (2 bytes)
obMap:			equ 4	; mappings address (4 bytes)
obX:			equ 8	; x-axis position (2-4 bytes)
obScreenY:		equ $A	; y-axis position for screen-fixed items (2 bytes)
obY:			equ $C	; y-axis position (2-4 bytes)
obVelX:			equ $10	; x-axis velocity (2 bytes)
obVelY:			equ $12	; y-axis velocity (2 bytes)
obActWid:		equ $14	; action width
;$15 is now free
obHeight:		equ $16	; height/2
obWidth:		equ $17	; width/2
obPriority:		equ $18	; sprite stack priority -- 0 is front (2 bytes)
obFrame:		equ $1A	; current frame displayed
obAniFrame:		equ $1B	; current frame in animation script
obAnim:			equ $1C	; current animation
obNextAni:		equ $1D	; next animation
obTimeFrame:	equ $1E	; time to next frame
obDelayAni:		equ $1F	; time to delay animation
;$1F is free for SONIC
obInertia:		equ $20	; potential speed (2 bytes) - Sonic ONLY
obColType:		equ $20	; collision response type
obColProp:		equ $21	; collision extra property
obStatus:		equ $22	; orientation or mode
obRespawnNo:	equ $23	; respawn list index number
obRoutine:		equ $24	; routine number
ob2ndRout:		equ $25	; secondary routine number
obAngle:		equ $26	; angle

obShieldProp:	equ $27 ; How object responds to shields {Lightning-Bubble-Flame-Reflect 0-0-0-0}

obSubtype:		equ $28	; object subtype
obSolid:		equ ob2ndRout ; solid status flag

; Object variables used by Sonic
obJumpFlag:		equ $2E ; Flag for Double Jump
obInvuln:		equ $30	; Invulnerable (blinking) timer ; $31 reserved as well
obInvinc:		equ $31	; Invincibility timer
obShoes:		equ $32	; Speed Shoes timer
obSShoes:		equ $33 ; Slow Shoes timer
obFrontAngle:	equ $36
obRearAngle:	equ $37
obOnWheel:		equ $38	; on convex wheel flag
obStatus2:		equ $39	; status for abilities such as Spin Dash
obRevSpeed:		equ $3A	; rev speed for Spin Dash or Dash
obRestartTimer:	equ $3A ; level restart timer
obJumping:		equ $3C	; jumping flag
obPlatformID:	equ $3D	; ost slot of the object Sonic's on top of
obLRLock:		equ $3E	; flag for preventing left and right input
obSize:			equ $40

; Object Variables used by bosses
obSLZBossPinchMode:	equ $29
obBossPinchMode:	equ $2E
obBossBufferX:		equ $30
obBossParent:		equ $34
obBossBufferY:		equ $38
obBossDelayTimer:	equ $3C
obBossFlashTime:	equ $3E
obBossHoverValue:	equ $3F

; Ralakimus Subsprite SSTs
mainspr_mapframe = $B
mainspr_width = $E
mainspr_childsprites = $F ; amount of child sprites
mainspr_height = $14
sub2_x_pos = $10 ;x_vel
sub2_y_pos = $12 ;y_vel
sub2_mapframe = $15
sub3_x_pos = $16 ;y_radius
sub3_y_pos = $18 ;priority
sub3_mapframe = $1B ;anim_frame
sub4_x_pos = $1C ;anim
sub4_y_pos = $1E ;anim_frame_duration
sub4_mapframe = $21 ;collision_property
sub5_x_pos = $22 ;status
sub5_y_pos = $24 ;routine
sub5_mapframe = $27
sub6_x_pos = $28 ;subtype
sub6_y_pos = $2A
sub6_mapframe = $2D
sub7_x_pos = $2E
sub7_y_pos = $30
sub7_mapframe = $33
sub8_x_pos = $34
sub8_y_pos = $36
sub8_mapframe = $39
sub9_x_pos = $3A
sub9_y_pos = $3C
sub9_mapframe = $3F
next_subspr = $6

; Sonic Status Bits
staFacing:		equ 0
staAir:			equ 1
staSpin:		equ 2
staOnObj:		equ 3
staRollJump:	equ 4
staPush:		equ 5
staWater:		equ 6
staSSJump:		equ 7

; Ability Status
staSpinDash:	equ 0
staDash:		equ 1

; v_status_secondary
stsShield:		equ 0
stsInvinc:		equ 1
stsShoes:		equ 2
stsGoggles:		equ 3
stsSuper:		equ 4

stsReflect:		equ 4 ; Shield Property for obstacles
; Shield properties for Sonic and other objects
stsFlame:		equ 5
stsBubble:		equ 6
stsLightning:	equ 7

stsRmvShield:	equ $1E
stsElShield:	equ $E0
stsChkShield:	equ $E3

obPlayerHeight:	equ $13
obTailsHeight:	equ $F
obPlayerWidth:	equ 9
obBallHeight:	equ $E
obBallWidth:	equ 7

; NEW GLOBAL Animation IDs - To make easier the usage of animations across all 6 characters
aniID_Null:			equ 0		; Null animation
aniID_Walk:			equ 1		; Walking animation
aniID_Run:			equ 2		; Running animation
aniID_Dash:			equ 3		; Dashing animation (Used by Sonic and Tails)
aniID_Roll:			equ 4		; Rolling animation
aniID_Roll2:		equ 5		; Faster rolling animation (Metal also uses this for his Spindash)
aniID_Push:			equ 6		; Pushing animation
aniID_Wait:			equ 7		; Idle waiting animation
aniID_Balance:		equ 8		; Primary Balancing animation (Used by everyone)
aniID_Balance2:		equ 9		; Secondary Balancing animation (Used by Sonic and MAYBE Mighty)
aniID_Balance3:		equ $A		; Tertiary Balancing Animation (Used by Sonic)
aniID_LookUp:		equ $B		; Look Up animation
aniID_Duck:			equ $C		; Duck animation
aniID_Spindash:		equ $D		; Spindash animation and Amy's Running dash animation
aniID_Stop:			equ $E		; Stopping animation
aniID_Float1:		equ $F		; Floating animation #1
aniID_Float2:		equ $10		; Floating animation #2
aniID_Float3:		equ $11		; Floating animation #3
aniID_Float4:		equ $12		; Floating animation #4
aniID_Spring:		equ $13		; Spring animation
aniID_Hang:			equ $14		; Hanging animation (LZ Vertical Pole)
aniID_Fall:			equ $15		; Falling animation (Knuckles and Amy only; MIGHT incorporate for others)
aniID_GetAir:		equ $16		; Getting Air Bubble animation
aniID_GetAir2: 		equ $17		; Getting Air Bubble while standing animation
aniID_Death:		equ $18		; Death animation
aniID_Drown:		equ $19		; Drown animation
aniID_Shrink:		equ $1A		; Shrink animation
aniID_Hurt:			equ $1B		; Hurt animation
aniID_WaterSlide:	equ $1C		; Water Slide animation
aniID_Transform:	equ $1D		; Super Transformation animation

; ----- CHARACTER SPECIFIC ANIMATION IDs -----
aniID_Peelout:		equ $1E		; Peelout animation (Sonic, Amy, and Metal Sonic)


; Animation flags
afEnd:		equ $FF	; return to beginning of animation
afBack:		equ $FE	; go back (specified number) bytes
afChange:	equ $FD	; run specified animation
afRoutine:	equ $FC	; increment routine counter
afReset:	equ $FB	; reset animation and 2nd object routine counter
af2ndRoutine:	equ $FA	; increment 2nd routine counter

; Difficulty settings
difNormal:	equ 0
difEasy:	equ 1
difHard:	equ 2

; Background music
bgm__First:	equ $81
bgm_GHZ:	equ ((ptr_mus81-MusicIndex)/4)+bgm__First
bgm_LZ:		equ ((ptr_mus82-MusicIndex)/4)+bgm__First
bgm_MZ:		equ ((ptr_mus83-MusicIndex)/4)+bgm__First
bgm_SLZ:	equ ((ptr_mus84-MusicIndex)/4)+bgm__First
bgm_SYZ:	equ ((ptr_mus85-MusicIndex)/4)+bgm__First
bgm_SBZ:	equ ((ptr_mus86-MusicIndex)/4)+bgm__First
bgm_Invincible:	equ ((ptr_mus87-MusicIndex)/4)+bgm__First
bgm_ExtraLife:	equ ((ptr_mus88-MusicIndex)/4)+bgm__First
bgm_SS:		equ ((ptr_mus89-MusicIndex)/4)+bgm__First
bgm_Title:	equ ((ptr_mus8A-MusicIndex)/4)+bgm__First
bgm_Ending:	equ ((ptr_mus8B-MusicIndex)/4)+bgm__First
bgm_Boss:	equ ((ptr_mus8C-MusicIndex)/4)+bgm__First
bgm_FZ:		equ ((ptr_mus8D-MusicIndex)/4)+bgm__First
bgm_GotThrough:	equ ((ptr_mus8E-MusicIndex)/4)+bgm__First
bgm_GameOver:	equ ((ptr_mus8F-MusicIndex)/4)+bgm__First
bgm_Continue:	equ ((ptr_mus90-MusicIndex)/4)+bgm__First
bgm_Credits:	equ ((ptr_mus91-MusicIndex)/4)+bgm__First
bgm_Drowning:	equ ((ptr_mus92-MusicIndex)/4)+bgm__First
bgm_Emerald:	equ ((ptr_mus93-MusicIndex)/4)+bgm__First
bgm__Last:	equ ((ptr_musend-MusicIndex-4)/4)+bgm__First

; Sound effects
sfx__First:	equ $A0
sfx_Jump:	equ ((ptr_sndA0-SoundIndex)/4)+sfx__First
sfx_Lamppost:	equ ((ptr_sndA1-SoundIndex)/4)+sfx__First
sfx_A2:		equ ((ptr_sndA2-SoundIndex)/4)+sfx__First
sfx_Death:	equ ((ptr_sndA3-SoundIndex)/4)+sfx__First
sfx_Skid:	equ ((ptr_sndA4-SoundIndex)/4)+sfx__First
sfx_A5:		equ ((ptr_sndA5-SoundIndex)/4)+sfx__First
sfx_HitSpikes:	equ ((ptr_sndA6-SoundIndex)/4)+sfx__First
sfx_Push:	equ ((ptr_sndA7-SoundIndex)/4)+sfx__First
sfx_SSGoal:	equ ((ptr_sndA8-SoundIndex)/4)+sfx__First
sfx_SSItem:	equ ((ptr_sndA9-SoundIndex)/4)+sfx__First
sfx_Splash:	equ ((ptr_sndAA-SoundIndex)/4)+sfx__First
sfx_AB:		equ ((ptr_sndAB-SoundIndex)/4)+sfx__First
sfx_HitBoss:	equ ((ptr_sndAC-SoundIndex)/4)+sfx__First
sfx_Bubble:	equ ((ptr_sndAD-SoundIndex)/4)+sfx__First
sfx_Fireball:	equ ((ptr_sndAE-SoundIndex)/4)+sfx__First
sfx_Shield:	equ ((ptr_sndAF-SoundIndex)/4)+sfx__First
sfx_Saw:	equ ((ptr_sndB0-SoundIndex)/4)+sfx__First
sfx_Electric:	equ ((ptr_sndB1-SoundIndex)/4)+sfx__First
sfx_Drown:	equ ((ptr_sndB2-SoundIndex)/4)+sfx__First
sfx_Flamethrower:equ ((ptr_sndB3-SoundIndex)/4)+sfx__First
sfx_Bumper:	equ ((ptr_sndB4-SoundIndex)/4)+sfx__First
sfx_Ring:	equ ((ptr_sndB5-SoundIndex)/4)+sfx__First
sfx_SpikesMove:	equ ((ptr_sndB6-SoundIndex)/4)+sfx__First
sfx_Rumbling:	equ ((ptr_sndB7-SoundIndex)/4)+sfx__First
sfx_B8:		equ ((ptr_sndB8-SoundIndex)/4)+sfx__First
sfx_Collapse:	equ ((ptr_sndB9-SoundIndex)/4)+sfx__First
sfx_SSGlass:	equ ((ptr_sndBA-SoundIndex)/4)+sfx__First
sfx_Door:	equ ((ptr_sndBB-SoundIndex)/4)+sfx__First
sfx_Teleport:	equ ((ptr_sndBC-SoundIndex)/4)+sfx__First
sfx_ChainStomp:	equ ((ptr_sndBD-SoundIndex)/4)+sfx__First
sfx_Roll:	equ ((ptr_sndBE-SoundIndex)/4)+sfx__First
sfx_Continue:	equ ((ptr_sndBF-SoundIndex)/4)+sfx__First
sfx_Basaran:	equ ((ptr_sndC0-SoundIndex)/4)+sfx__First
sfx_BreakItem:	equ ((ptr_sndC1-SoundIndex)/4)+sfx__First
sfx_Warning:	equ ((ptr_sndC2-SoundIndex)/4)+sfx__First
sfx_GiantRing:	equ ((ptr_sndC3-SoundIndex)/4)+sfx__First
sfx_Bomb:	equ ((ptr_sndC4-SoundIndex)/4)+sfx__First
sfx_Cash:	equ ((ptr_sndC5-SoundIndex)/4)+sfx__First
sfx_RingLoss:	equ ((ptr_sndC6-SoundIndex)/4)+sfx__First
sfx_ChainRise:	equ ((ptr_sndC7-SoundIndex)/4)+sfx__First
sfx_Burning:	equ ((ptr_sndC8-SoundIndex)/4)+sfx__First
sfx_Bonus:	equ ((ptr_sndC9-SoundIndex)/4)+sfx__First
sfx_EnterSS:	equ ((ptr_sndCA-SoundIndex)/4)+sfx__First
sfx_WallSmash:	equ ((ptr_sndCB-SoundIndex)/4)+sfx__First
sfx_Spring:	equ ((ptr_sndCC-SoundIndex)/4)+sfx__First
sfx_Switch:	equ ((ptr_sndCD-SoundIndex)/4)+sfx__First
sfx_RingLeft:	equ ((ptr_sndCE-SoundIndex)/4)+sfx__First
sfx_Signpost:	equ ((ptr_sndCF-SoundIndex)/4)+sfx__First
sfx__Last:	equ ((ptr_sndend-SoundIndex-4)/4)+sfx__First

; Special sound effects
spec__First:	equ $D0
sfx_Waterfall:	equ ((ptr_sndD0-SpecSoundIndex)/4)+spec__First
spec__Last:	equ ((ptr_specend-SpecSoundIndex-4)/4)+spec__First

sfx_SpinDash:	equ $D1

flg__First:		equ $E0
bgm_Fade:		equ ((ptr_flgE0-Sound_ExIndex)/4)+flg__First
sfx_Sega:		equ ((ptr_flgE1-Sound_ExIndex)/4)+flg__First
bgm_Speedup:	equ ((ptr_flgE2-Sound_ExIndex)/4)+flg__First
bgm_Slowdown:	equ ((ptr_flgE3-Sound_ExIndex)/4)+flg__First
bgm_Stop:		equ ((ptr_flgE4-Sound_ExIndex)/4)+flg__First
flg__Last:		equ ((ptr_flgend-Sound_ExIndex-4)/4)+flg__First

; ---------------------------------------------------------------------------
; NEW VRAM and tile art base addresses, to make VRAM shifting less of a headache.

Art_LevelArt:			equ 0

; Shared art between zones
ArtNem_Splash_locVRAM:			equ $5560
ArtNem_Splash:					equ $4000+(ArtNem_Splash_locVRAM/$20) ; BZ/JZ/LZ

ArtNem_WaterSurface_locVRAM:	equ $5BE0
ArtNem_WaterSurface:			equ $C000+(ArtNem_WaterSurface_locVRAM/$20) ; BZ/JZ/LZ

ArtNem_Bubbles_locVRAM:			equ $64E0
ArtNem_Bubbles:					equ $A000+(ArtNem_Bubbles_locVRAM/$20) ; BZ/JZ/LZ

ArtNem_SwingPtform_locVRAM:		equ $6FC0
ArtNem_SwingPtform:				equ $4000+(ArtNem_SwingPtform_locVRAM/$20) ; GHZ/MZ

ArtNem_Bridge_locVRAM:			equ $7180
ArtNem_Bridge:					equ $4000+(ArtNem_Bridge_locVRAM/$20) ; GHZ/BZ	- SHIFT THIS DOWN in GHZ to make room for Bubbles in BZ

ArtNem_PurpleRock_locVRAM:		equ $79C0
ArtNem_PurpleRock:				equ $6000+(ArtNem_PurpleRock_locVRAM/$20) ; GHZ/BZ

ArtNem_Crabmeat_locVRAM:		equ $7CC0
ArtNem_Crabmeat:				equ $2000+(ArtNem_Crabmeat_locVRAM/$20) ; GHZ/SYZ

ArtNem_BuzzBomber_locVRAM:		equ $8540
ArtNem_BuzzBomber_Missile:		equ (ArtNem_BuzzBomber_locVRAM/$20)
ArtNem_BuzzBomber:				equ $2000+(ArtNem_BuzzBomber_Missile) ; GHZ/BZ/MZ/JZ/SYZ

ArtNem_Orbinaut_locVRAM:		equ $85A0
ArtNem_Orbinaut:				equ (ArtNem_Orbinaut_locVRAM/$20) ; LZ/SLZ
ArtNem_Orbinaut2:				equ $2000+(ArtNem_Orbinaut) ; LZ/SLZ

ArtNem_Chopper_locVRAM:			equ $8C20
ArtNem_Chopper:					equ $2000+(ArtNem_Chopper_locVRAM/$20) ; GHZ/BZ/JZ

ArtNem_Switch_locVRAM:			equ $8C20
ArtNem_Switch:					equ $2000+(ArtNem_Switch_locVRAM/$20)+4
ArtNem_MZSwitch:				equ $4000+(ArtNem_Switch_locVRAM/$20) ; MZ/SYZ/LZ/SBZ

ArtNem_Fireball_locVRAM:		equ $7180
ArtNem_Fireball:				equ $2000+(ArtNem_Fireball_locVRAM/$20) ; MZ/SLZ

ArtNem_Caterkiller_locVRAM:		equ $9320
ArtNem_Caterkiller:				equ $2000+(ArtNem_Caterkiller_locVRAM/$20) ; MZ/SYZ/SBZ

ArtNem_Yadrin_locVRAM:			equ $9520
ArtNem_Yadrin:					equ $2000+(ArtNem_Yadrin_locVRAM/$20) ; MZ/SYZ

ArtNem_Bomb_locVRAM:			equ $9B20
ArtNem_Bomb:					equ $2000+(ArtNem_Bomb_locVRAM/$20) ; SLZ/SBZ/SKBZ

; GHZ
ArtUnc_BigFlower_locVRAM:		equ $67C0
ArtUnc_SmallFlower_locVRAM:		equ $69C0
ArtUnc_Waterfall_locVRAM:		equ $6B40
ArtNem_FlowerStalk_locVRAM:		equ $6C40

ArtNem_GHZEdgeWall_locVRAM:		equ $6CC0
ArtNem_GHZEdgeWall:				equ $4000+(ArtNem_GHZEdgeWall_locVRAM/$20)

ArtNem_GHZBreakWall_locVRAM:	equ $6E40
ArtNem_GHZBreakWall:			equ $4000+(ArtNem_GHZBreakWall_locVRAM/$20)

ArtNem_GHZSpikePole_locVRAM:	equ $72C0
ArtNem_GHZSpikePole:			equ $4000+(ArtNem_GHZSpikePole_locVRAM/$20)

ArtNem_GHZBall_locVRAM:			equ $7500
ArtNem_GHZBall:					equ $4000+(ArtNem_GHZBall_locVRAM/$20)

ArtNem_Newtron_locVRAM:			equ $9020
ArtNem_Newtron_blue:			equ (ArtNem_Newtron_locVRAM/$20)
ArtNem_Newtron_green:			equ $2000+(ArtNem_Newtron_blue)

ArtNem_Motobug_locVRAM:			equ $9AC0
ArtNem_Motobug:					equ $2000+(ArtNem_Motobug_locVRAM/$20)
; 15 tiles free at 9E60

; MZ
ArtUnc_FlowingLava_locVRAM:		equ $52E0
ArtUnc_LavaSurface_locVRAM:		equ (ArtUnc_FlowingLava_locVRAM+$200)
ArtUnc_Torch_locVRAM:			equ $55E0

ArtNem_MZLavaGeyser_locVRAM:	equ $56A0
ArtNem_MZLavaGeyser:			equ $6000+(ArtNem_MZLavaGeyser_locVRAM/$20)
ArtNem_MZLavaGeyser_2:			equ $8000+(ArtNem_MZLavaGeyser)
; 21 tiles free at 6A20

ArtNem_MZBlock_locVRAM:			equ $6CC0
ArtNem_MZBlock:					equ $4000+(ArtNem_MZBlock_locVRAM/$20)
ArtNem_MZBlock_Long:			equ $8000+(ArtNem_MZBlock)

ArtNem_MZGlass_locVRAM:			equ $7700
ArtNem_MZGlass:					equ $C000+(ArtNem_MZGlass_locVRAM/$20)

ArtNem_MZMetal_locVRAM:			equ $7A40
ArtNem_MZMetal:					equ $2000+(ArtNem_MZMetal_locVRAM/$20)
; 19 tiles free at 82E0

ArtNem_Basaran_locVRAM:			equ $8DA0
ArtNem_Basaran:					equ $A000+(ArtNem_Basaran_locVRAM/$20)
; 3 tiles free at 92C0
; 28 tiles free at 9CC0

; SYZ
ArtNem_SYZSpike_locVRAM:		equ $6E40
ArtNem_SYZSpike:				equ $2000+(ArtNem_SYZSpike_locVRAM/$20)

ArtNem_SYZSmallSpike_locVRAM:	equ $7140
ArtNem_SYZSmallSpike:			equ $2000+(ArtNem_SYZSmallSpike_locVRAM/$20)

ArtNem_Roller_locVRAM:			equ $71C0
ArtNem_Roller:					equ $2000+(ArtNem_Roller_locVRAM/$20)
; 8 tiles free at 7BC0

ArtNem_Splats_locVRAM:			equ $8DA0
ArtNem_Splats:					equ $2000+(ArtNem_Splats_locVRAM/$20)
; 15 tiles free at 9140

ArtNem_Bumper_locVRAM:			equ $9CC0
ArtNem_Bumper:					equ $2000+(ArtNem_Bumper_locVRAM/$20)

ArtNem_Sparkle_locVRAM:			equ $9F80
ArtNem_Sparkle:					equ $2000+(ArtNem_Sparkle_locVRAM/$20)
; 3 tiles free at 9FE0

; LZ
ArtNem_LZBlock1_locVRAM:		equ $38C0
ArtNem_LZBlock1:				equ $4000+(ArtNem_LZBlock1_locVRAM/$20)

ArtNem_LZBlock2_locVRAM:		equ $3AC0
ArtNem_LZBlock2:				equ $4000+(ArtNem_LZBlock2_locVRAM/$20)

ArtNem_LZWaterfall_locVRAM:		equ $47C0
ArtNem_LZWaterfall:				equ $4000+(ArtNem_LZWaterfall_locVRAM/$20)

ArtNem_LZGargoyle_locVRAM:		equ $59C0
ArtNem_LZGargoyle:				equ $4000+(ArtNem_LZGargoyle_locVRAM/$20)

ArtNem_LZSpikeball_locVRAM:		equ $5DE0
ArtNem_LZSpikeball:				equ $2000+(ArtNem_LZSpikeball_locVRAM/$20)

ArtNem_LZFlapDoor_locVRAM:		equ $60E0
ArtNem_LZFlapDoor:				equ $4000+(ArtNem_LZFlapDoor_locVRAM/$20)

ArtNem_LZBlock3_locVRAM:		equ $7360
ArtNem_LZBlock3:				equ $4000+(ArtNem_LZBlock3_locVRAM/$20)

ArtNem_LZDoor1_locVRAM:			equ $7460
ArtNem_LZDoor1:					equ $4000+(ArtNem_LZDoor1_locVRAM/$20)

ArtNem_LZHarpoon_locVRAM:		equ $7560
ArtNem_LZHarpoon:				equ (ArtNem_LZHarpoon_locVRAM/$20)

ArtNem_LZDoor2_locVRAM:			equ $77A0
ArtNem_LZDoor2:					equ $4000+(ArtNem_LZDoor2_locVRAM/$20)

ArtNem_LZWheel_locVRAM:			equ $79A0
ArtNem_LZWheel:					equ (ArtNem_LZWheel_locVRAM/$20)
ArtNem_LZWheel2:				equ $4000+(ArtNem_LZWheel_locVRAM/$20)

ArtNem_LZPlatfm_locVRAM:		equ $82A0
ArtNem_LZPlatfm:				equ $4000+(ArtNem_LZPlatfm_locVRAM/$20)

ArtNem_LZCork_locVRAM:			equ $8980
ArtNem_LZCork:					equ $4000+(ArtNem_LZCork_locVRAM/$20)
; 5 tiles free at 8B80

ArtNem_LZPole_locVRAM:			equ $8DA0
ArtNem_LZPole:					equ $4000+(ArtNem_LZPole_locVRAM/$20)

ArtNem_Burrobot_locVRAM:		equ $8EA0
ArtNem_Burrobot:				equ $2000+(ArtNem_Burrobot_locVRAM/$20)

ArtNem_Jaws_locVRAM:			equ $99E0
ArtNem_Jaws:					equ $2000+(ArtNem_Jaws_locVRAM/$20)
; 19 tiles free at 9DE0

; SLZ
; 8 tiles free at 6E40
ArtNem_SLZBreakWall_locVRAM:	equ $6E40
ArtNem_SLZBreakWall:			equ $4000+(ArtNem_SLZBreakWall_locVRAM/$20)
; 18 tiles free at 6F40

ArtNem_SLZSeesaw_locVRAM:		equ $7700
ArtNem_SLZSeesaw:				equ $2000+(ArtNem_SLZSeesaw_locVRAM/$20)

ArtNem_SLZPylon_locVRAM:		equ $6F80
ArtNem_SLZPylon:				equ $A000+(ArtNem_SLZPylon_locVRAM/$20)

ArtNem_SLZSpike_locVRAM:		equ $7E80
ArtNem_SLZSpike:				equ $2000+(ArtNem_SLZSpike_locVRAM/$20)
; 23 tiles free at 80C0

ArtNem_SLZBlock_locVRAM:		equ $83A0
ArtNem_SLZBlock:				equ $4000+(ArtNem_SLZBlock_locVRAM/$20)

ArtNem_SLZCannon_locVRAM:		equ $8980
ArtNem_SLZCannon:				equ $4000+(ArtNem_SLZCannon_locVRAM/$20)
; 57 tiles free at 8A80

ArtNem_SLZFan_locVRAM:			equ $91A0
ArtNem_SLZFan:					equ $4000+(ArtNem_SLZFan_locVRAM/$20)

ArtNem_SLZSwing_locVRAM:		equ $9720
ArtNem_SLZSwing:				equ $4000+(ArtNem_SLZSwing_locVRAM/$20)

; SBZ
ArtUnc_SBZSmokePuff1_locVRAM:	equ $5520
ArtUnc_SBZSmokePuff2_locVRAM:	equ $56A0

ArtNem_SBZStomper_locVRAM:		equ $5820
ArtNem_SBZStomper:				equ $2000+(ArtNem_SBZStomper_locVRAM/$20)

ArtNem_SBZDoor1_locVRAM:		equ $5D20
ArtNem_SBZDoor1:				equ $4000+(ArtNem_SBZDoor1_locVRAM/$20)

ArtNem_SBZGirder_locVRAM:		equ $5E20
ArtNem_SBZGirder:				equ $4000+(ArtNem_SBZGirder_locVRAM/$20)

ArtNem_Ballhog_locVRAM:			equ $6060
ArtNem_Ballhog:					equ $2000+(ArtNem_Ballhog_locVRAM/$20)

ArtNem_SBZSpike_locVRAM:		equ $6640
ArtNem_SBZSpike:				equ (ArtNem_SBZSpike_locVRAM/$20)

ArtNem_SBZWheel1_locVRAM:		equ $6AC0
ArtNem_SBZWheel1:				equ $C000+(ArtNem_SBZWheel1_locVRAM/$20)

ArtNem_SBZWheel2_locVRAM:		equ $6B40
ArtNem_SBZWheel2:				equ $4000+(ArtNem_SBZWheel2_locVRAM/$20)

ArtNem_SBZCutter_locVRAM:		equ $7460
ArtNem_SBZCutter:				equ $4000+(ArtNem_SBZCutter_locVRAM/$20)

ArtNem_SBZTrapdoor_locVRAM:		equ $78E0
ArtNem_SBZTrapdoor:				equ $4000+(ArtNem_SBZTrapdoor_locVRAM/$20)

ArtNem_SBZDoor2_locVRAM:		equ $7F00
ArtNem_SBZDoor2:				equ $4000+(ArtNem_SBZDoor2_locVRAM/$20)

ArtNem_SBZFloor1_locVRAM:		equ $80E0
ArtNem_SBZFloor2_locVRAM:		equ $8160
ArtNem_SBZFloor:				equ $4000+(ArtNem_SBZFloor1_locVRAM/$20)

ArtNem_SBZSpinPlatfm_locVRAM:	equ $81E0
ArtNem_SBZSpinPlatfm:			equ $2000+(ArtNem_SBZSpinPlatfm_locVRAM/$20)

ArtNem_SBZElectric_locVRAM:		equ $87E0
ArtNem_SBZElectric:				equ $2000+(ArtNem_SBZElectric_locVRAM/$20)

ArtNem_SBZBlock_locVRAM:		equ $8DA0
ArtNem_SBZBlock:				equ $4000+(ArtNem_SBZBlock_locVRAM/$20)

ArtNem_SBZFlamepipe_locVRAM:	equ $9520
ArtNem_SBZFlamepipe:			equ $A000+(ArtNem_SBZFlamepipe_locVRAM/$20)

ArtNem_SBZSlideFloor_locVRAM:	equ $98A0
ArtNem_SBZSlideFloor:			equ $4000+(ArtNem_SBZSlideFloor_locVRAM/$20)

; Global art
ArtNem_HSpring_locVRAM:			equ $A040
ArtNem_HSpring_Red:				equ (ArtNem_HSpring_locVRAM/$20)
ArtNem_HSpring_Yellow:			equ $2000+(ArtNem_HSpring_Red)

ArtNem_VSpring_locVRAM:			equ $A240
ArtNem_VSpring_Red:				equ (ArtNem_VSpring_locVRAM/$20)
ArtNem_VSpring_Yellow:			equ $2000+(ArtNem_VSpring_Red)

ArtNem_Lamppost_locVRAM:		equ $A400
ArtNem_Lamppost:				equ $2000+(ArtNem_Lamppost_locVRAM/$20)

ArtNem_Points_locVRAM:			equ $A540
ArtNem_Points:					equ $2000+(ArtNem_Points_locVRAM/$20)

ArtNem_Ring_locVRAM:			equ $A660
ArtNem_Ring:					equ $2000+(ArtNem_Ring_locVRAM/$20)

ArtNem_Spikes_locVRAM:			equ $A8E0
ArtNem_Spikes:					equ $2000+(ArtNem_Spikes_locVRAM/$20)

ArtUnc_PlayerBonus_locVRAM:		equ $A9E0
ArtUnc_PlayerBonus:				equ (ArtUnc_PlayerBonus_locVRAM/$20)

ArtNem_GameOver_locVRAM:		equ $AA00

ArtNem_Animal1_locVRAM:			equ $AF80
ArtNem_Animal1:					equ $2000+(ArtNem_Animal1_locVRAM/$20)

ArtNem_Animal2_locVRAM:			equ $B1C0
ArtNem_Animal2:					equ $2000+(ArtNem_Animal2_locVRAM/$20)

ArtNem_Explosions_locVRAM:		equ $B400
ArtNem_Explosions:				equ (ArtNem_Explosions_locVRAM/$20)

ArtNem_Monitors_locVRAM:		equ $D000
ArtNem_Monitors:				equ (ArtNem_Monitors_locVRAM/$20)
ArtNem_Signpost:				equ (ArtNem_Monitors)

ArtNem_HUD_locVRAM:				equ $D940

; BOSSES
ArtNem_Eggman_locVRAM:			equ $7D20	; Eggman main patterns
ArtNem_Eggman:					equ (ArtNem_Eggman_locVRAM/$20)

ArtNem_Weapons_locVRAM:			equ $8AA0	; Eggman's weapons
ArtNem_Weapons:					equ $2000+(ArtNem_Weapons_locVRAM/$20)

ArtNem_Prison_locVRAM:			equ $90C0	; prison capsule
ArtNem_Prison:					equ (ArtNem_Prison_locVRAM/$20)

ArtNem_SLZWeapons_locVRAM:		equ $9FA0	; bomb enemy (gets overwritten by spikeballs, shrapnel is used for SLZ boss)
ArtNem_SLZWeapons:				equ (ArtNem_SLZWeapons_locVRAM/$20)

ArtNem_Exhaust_locVRAM: 		equ $A260	; exhaust flame
