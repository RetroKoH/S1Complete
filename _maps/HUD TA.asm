; ---------------------------------------------------------------------------
; Sprite mappings - TIME, RINGS
; ---------------------------------------------------------------------------
Map_HUD_TA:	mappingsTable
	mappingsTableEntry.w	@allyellow
	mappingsTableEntry.w	@ringred
	mappingsTableEntry.w	@timered
	mappingsTableEntry.w	@allred

@allyellow:	spriteHeader
	spritePiece	0, -$80, 4, 2, $10, 0, 0, 0, 1
	spritePiece	$28, -$80, 4, 2, $28, 0, 0, 0, 1
	spritePiece	$48, -$80, 1, 2, $2A, 0, 0, 0, 1
	spritePiece	$50, -$80, 2, 2, -$E, 1, 1, 0, 1

	spritePiece	0, -$70, 4, 2, 8, 0, 0, 0, 1
	spritePiece	$20, -$70, 1, 2, 0, 0, 0, 0, 1
	spritePiece	$30, -$70, 3, 2, $30, 0, 0, 0, 1
@allyellow_End
	even
@ringred:	spriteHeader
	spritePiece	0, -$80, 4, 2, $10, 0, 0, 0, 1
	spritePiece	$28, -$80, 4, 2, $28, 0, 0, 0, 1
	spritePiece	$48, -$80, 1, 2, $2A, 0, 0, 0, 1
	spritePiece	$50, -$80, 2, 2, -$E, 1, 1, 0, 1

;	spritePiece	0, -$70, 4, 2, 8, 0, 0, 0, 1
;	spritePiece	$20, -$70, 1, 2, 0, 0, 0, 0, 1
	spritePiece	$30, -$70, 3, 2, $30, 0, 0, 0, 1
@ringred_End
	even
@timered:	spriteHeader
;	spritePiece	0, -$80, 4, 2, $10, 0, 0, 0, 1
	spritePiece	$28, -$80, 4, 2, $28, 0, 0, 0, 1
	spritePiece	$48, -$80, 1, 2, $2A, 0, 0, 0, 1
	spritePiece	$50, -$80, 2, 2, -$E, 1, 1, 0, 1

	spritePiece	0, -$70, 4, 2, 8, 0, 0, 0, 1
	spritePiece	$20, -$70, 1, 2, 0, 0, 0, 0, 1
	spritePiece	$30, -$70, 3, 2, $30, 0, 0, 0, 1
@timered_End
	even
@allred:	spriteHeader
;	spritePiece	0, -$80, 4, 2, $10, 0, 0, 0, 1
	spritePiece	$28, -$80, 4, 2, $28, 0, 0, 0, 1
	spritePiece	$48, -$80, 1, 2, $2A, 0, 0, 0, 1
	spritePiece	$50, -$80, 2, 2, -$E, 1, 1, 0, 1

;	spritePiece	0, -$70, 4, 2, 8, 0, 0, 0, 1
;	spritePiece	$20, -$70, 1, 2, 0, 0, 0, 0, 1
	spritePiece	$30, -$70, 3, 2, $30, 0, 0, 0, 1
@allred_End
	even
