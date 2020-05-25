; ---------------------------------------------------------------------------
; Sprite mappings - "PRESS START BUTTON" and "TM" from title screen
; Now includes menu
; ---------------------------------------------------------------------------
Map_PSB:	mappingsTable
	mappingsTableEntry.w	byte_A7CD
	mappingsTableEntry.w	M_PSB_PSB
	mappingsTableEntry.w	M_PSB_Limiter
	mappingsTableEntry.w	M_PSB_TM
	mappingsTableEntry.w	M_PSB_STARTGAME
	mappingsTableEntry.w	M_PSB_OPTIONS
	mappingsTableEntry.w	M_PSB_LEVELSELECT

M_PSB_PSB:	spriteHeader
byte_A7CD:spritePiece	0, 0, 4, 1, $F0, 0, 0, 0, 0
	spritePiece	$20, 0, 1, 1, $F3, 0, 0, 0, 0
	spritePiece	$30, 0, 1, 1, $F3, 0, 0, 0, 0
	spritePiece	$38, 0, 4, 1, $F4, 0, 0, 0, 0
	spritePiece	$60, 0, 3, 1, $F8, 0, 0, 0, 0
	spritePiece	$78, 0, 3, 1, $FB, 0, 0, 0, 0
M_PSB_PSB_End

M_PSB_Limiter:	spriteHeader
	spritePiece	-$80, -$48, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$48, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$48, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$48, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$48, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$48, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$48, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$48, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$48, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$48, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$28, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$28, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$28, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$28, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$28, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$28, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$28, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$28, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$28, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -$28, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -8, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -8, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -8, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -8, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -8, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -8, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -8, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -8, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -8, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$80, -8, 4, 4, 0, 0, 0, 0, 0
M_PSB_Limiter_End

M_PSB_TM:	spriteHeader
	spritePiece	-8, -4, 2, 1, 0, 0, 0, 0, 0
M_PSB_TM_End

M_PSB_STARTGAME:	spriteHeader ; $4C
        spritePiece	$10, -8, 2, 1, $348, 0, 0, 0, 0
        spritePiece	$28, -8, 1, 1, $F3, 0, 0, 0, 0
	spritePiece	$30, -8, 4, 1, $F4, 0, 0, 0, 0
	spritePiece	$58, -8, 4, 1, $333, 0, 0, 0, 0
	spritePiece	$28, 8, 4, 1, $337, 0, 0, 0, 0
	spritePiece	$43, 8, 3, 1, $33B, 0, 0, 0, 0
M_PSB_STARTGAME_End

M_PSB_OPTIONS:	spriteHeader
        spritePiece	$10, 8, 2, 1, $348, 0, 0, 0, 0
        spritePiece	$28, -8, 1, 1, $F3, 0, 0, 0, 0
	spritePiece	$30, -8, 4, 1, $F4, 0, 0, 0, 0
	spritePiece	$58, -8, 4, 1, $333, 0, 0, 0, 0
	spritePiece	$28, 8, 4, 1, $337, 0, 0, 0, 0
	spritePiece	$43, 8, 3, 1, $33B, 0, 0, 0, 0
M_PSB_OPTIONS_End

M_PSB_LEVELSELECT:	spriteHeader
        spritePiece	$10, -8, 2, 1, $348, 0, 0, 0, 0
        spritePiece	$28, -8, 4, 1, $33E, 0, 0, 0, 0
	spritePiece	$48, -8, 1, 1, $33E, 0, 0, 0, 0
	spritePiece	$58, -8, 4, 1, $342, 0, 0, 0, 0
	spritePiece	$78,-8, 2, 1, $346, 0, 0, 0, 0
M_PSB_LEVELSELECT_End

	even
