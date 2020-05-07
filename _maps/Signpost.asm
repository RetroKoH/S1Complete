; ---------------------------------------------------------------------------
; Sprite mappings - signpost
; ---------------------------------------------------------------------------
Map_Sign:	mappingsTable
	mappingsTableEntry.w	@eggman
	mappingsTableEntry.w	@spin1
	mappingsTableEntry.w	@spin2
	mappingsTableEntry.w	@spin3
	mappingsTableEntry.w	@player

@eggman:	spriteHeader
	spritePiece	-8, -$10, 1, 3, $E, 0, 0, 0, 0
	spritePiece	0, -$10, 1, 3, $E, 1, 0, 0, 0
	spritePiece	-$18, -$10, 3, 4, 0, 0, 0, 1, 0
	spritePiece	0, -$10, 3, 4, 0, 1, 0, 1, 0
	spritePiece	-4, $10, 1, 2, $C, 0, 0, 1, 0
@eggman_End

@spin1:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 1, 0
	spritePiece	-4, $10, 1, 2, $10, 0, 0, 1, 0
@spin1_End

@spin2:	spriteHeader
	spritePiece	-4, -$10, 1, 4, 0, 0, 0, 1, 0
	spritePiece	-4, $10, 1, 2, 4, 1, 0, 1, 0
@spin2_End

@spin3:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, 0, 1, 0, 1, 0
	spritePiece	-4, $10, 1, 2, $10, 1, 0, 1, 0
@spin3_End

@player:	spriteHeader
	spritePiece	-$18, -$10, 3, 4, 0, 0, 0, 0, 0
	spritePiece	0, -$10, 3, 4, $C, 0, 0, 0, 0
	spritePiece	-4, $10, 1, 2, $18, 0, 0, 0, 0
@player_End

	even
