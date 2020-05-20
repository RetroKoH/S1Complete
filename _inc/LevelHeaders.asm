; ---------------------------------------------------------------------------
; Level Headers
; ---------------------------------------------------------------------------

LevelHeaders:

lhead:	macro plc1,lvlgfx,plc2,sixteen,onetwoeight,pal
	dc.l (plc1<<24)+lvlgfx
	dc.l (plc2<<24)+sixteen
	dc.l onetwoeight
	dc.b pal,0,0,0
	endm

; 1st PLC, level gfx (unused), 2nd PLC, 16x16 data, 128x128 data,
; palette, 0,0,0

;			1st PLC					2nd PLC					128x128 data
;						level gfx*				16x16 data				palette

	lhead	plcid_GHZ,	LvlArt_GHZ,	plcid_GHZ2,	Blk16_GHZ,	Blk128_GHZ,	palid_GHZ	; Green Hill
	lhead	plcid_LZ,	LvlArt_LZ,	plcid_LZ2,	Blk16_LZ,	Blk128_LZ,	palid_LZ	; Labyrinth
	lhead	plcid_MZ,	LvlArt_MZ,	plcid_MZ2,	Blk16_MZ,	Blk128_MZ,	palid_MZ	; Marble
	lhead	plcid_SLZ,	LvlArt_SLZ,	plcid_SLZ2,	Blk16_SLZ,	Blk128_SLZ,	palid_SLZ	; Star Light
	lhead	plcid_SYZ,	LvlArt_SYZ,	plcid_SYZ2,	Blk16_SYZ,	Blk128_SYZ,	palid_SYZ	; Spring Yard
	lhead	plcid_SBZ,	LvlArt_SBZ,	plcid_SBZ2,	Blk16_SBZ,	Blk128_SBZ,	palid_SBZ1	; Scrap Brain
	lhead	0,			LvlArt_GHZ,			0,	Blk16_GHZ,	Blk128_GHZ,	palid_Ending	; Ending
	lhead	plcid_LZ,	LvlArt_SBZ3,plcid_LZ2,	Blk16_SBZ3,	Blk128_SBZ3,palid_SBZ3	; Scrap Brain 3 (#7)
	even

;	* music and level gfx are actually set elsewhere, so these values are useless
