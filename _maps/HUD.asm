; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS, and lives
; Includes Hard Mode HUD: SCORE RINGS TIME and Lives
; ---------------------------------------------------------------------------
Map_HUD:	mappingsTable
	mappingsTableEntry.w	@allyellow
	mappingsTableEntry.w	@ringred
	mappingsTableEntry.w	@timered
	mappingsTableEntry.w	@allred
	mappingsTableEntry.w	@allyellow_h
	mappingsTableEntry.w	@ringred_h
	mappingsTableEntry.w	@timered_h
	mappingsTableEntry.w	@allred_h


@allyellow:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; SCOR
	spritePiece	$20, -$80, 4, 2, $18, 0, 0, 0, 1	; E
	spritePiece	$40, -$80, 4, 2, $20, 0, 0, 0, 1	; Score #
	spritePiece	0, -$70, 4, 2, $10, 0, 0, 0, 1		; TIME
	spritePiece	$28, -$70, 4, 2, $28, 0, 0, 0, 1	; X:XX
	spritePiece	0, -$60, 4, 2, 8, 0, 0, 0, 1		; RING
	spritePiece	$20, -$60, 1, 2, 0, 0, 0, 0, 1		; S
	spritePiece	$30, -$60, 3, 2, $30, 0, 0, 0, 1	; # of rings
	spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1		; Life Icon
	spritePiece	$10, $40, 4, 2, $10E, 0, 0, 1, 1	; Name and Lives #
@allyellow_End
	even
@ringred:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1
	spritePiece	$20, -$80, 4, 2, $18, 0, 0, 0, 1
	spritePiece	$40, -$80, 4, 2, $20, 0, 0, 0, 1
	spritePiece	0, -$70, 4, 2, $10, 0, 0, 0, 1
	spritePiece	$28, -$70, 4, 2, $28, 0, 0, 0, 1
	;spritePiece	0, -$60, 4, 2, 8, 0, 0, 0, 1
	;spritePiece	$20, -$60, 1, 2, 0, 0, 0, 0, 1
	spritePiece	$30, -$60, 3, 2, $30, 0, 0, 0, 1
	spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1
	spritePiece	$10, $40, 4, 2, $10E, 0, 0, 1, 1
@ringred_End
	even
@timered:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1
	spritePiece	$20, -$80, 4, 2, $18, 0, 0, 0, 1
	spritePiece	$40, -$80, 4, 2, $20, 0, 0, 0, 1
	;spritePiece	0, -$70, 4, 2, $10, 0, 0, 0, 1
	spritePiece	$28, -$70, 4, 2, $28, 0, 0, 0, 1
	spritePiece	0, -$60, 4, 2, 8, 0, 0, 0, 1
	spritePiece	$20, -$60, 1, 2, 0, 0, 0, 0, 1
	spritePiece	$30, -$60, 3, 2, $30, 0, 0, 0, 1
	spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1
	spritePiece	$10, $40, 4, 2, $10E, 0, 0, 1, 1
@timered_End
	even
@allred:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1
	spritePiece	$20, -$80, 4, 2, $18, 0, 0, 0, 1
	spritePiece	$40, -$80, 4, 2, $20, 0, 0, 0, 1
	;spritePiece	0, -$70, 4, 2, $10, 0, 0, 0, 1
	spritePiece	$28, -$70, 4, 2, $28, 0, 0, 0, 1
	;spritePiece	0, -$60, 4, 2, 8, 0, 0, 0, 1
	;spritePiece	$20, -$60, 1, 2, 0, 0, 0, 0, 1
	spritePiece	$30, -$60, 3, 2, $30, 0, 0, 0, 1
	spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1
	spritePiece	$10, $40, 4, 2, $10E, 0, 0, 1, 1
@allred_End
	even

@allyellow_h:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; SCOR
	spritePiece	$20, -$80, 4, 2, $18, 0, 0, 0, 1	; E
	spritePiece	$40, -$80, 4, 2, $20, 0, 0, 0, 1	; Score #
	spritePiece	0, -$70, 4, 2, 8, 0, 0, 0, 1		; RING
	spritePiece	$20, -$70, 1, 2, 0, 0, 0, 0, 1		; S
	spritePiece	$30, -$70, 3, 2, $30, 0, 0, 0, 1	; # of rings
	spritePiece	0, -$60, 4, 2, $10, 0, 0, 0, 1		; TIME
	spritePiece	$28, -$60, 4, 2, $28, 0, 0, 0, 1	; X:XX
	spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1		; Life Icon
	spritePiece	$10, $40, 4, 2, $10E, 0, 0, 1, 1	; Name and Lives #
@allyellow_h_End
	even
@ringred_h:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; SCOR
	spritePiece	$20, -$80, 4, 2, $18, 0, 0, 0, 1	; E
	spritePiece	$40, -$80, 4, 2, $20, 0, 0, 0, 1	; Score #
;	spritePiece	0, -$70, 4, 2, 8, 0, 0, 0, 1		; RING
;	spritePiece	$20, -$70, 1, 2, 0, 0, 0, 0, 1		; S
	spritePiece	$30, -$70, 3, 2, $30, 0, 0, 0, 1	; # of rings
	spritePiece	0, -$60, 4, 2, $10, 0, 0, 0, 1		; TIME
	spritePiece	$28, -$60, 4, 2, $28, 0, 0, 0, 1	; X:XX
	spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1		; Life Icon
	spritePiece	$10, $40, 4, 2, $10E, 0, 0, 1, 1	; Name and Lives #
@ringred_h_End
	even
@timered_h:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; SCOR
	spritePiece	$20, -$80, 4, 2, $18, 0, 0, 0, 1	; E
	spritePiece	$40, -$80, 4, 2, $20, 0, 0, 0, 1	; Score #
	spritePiece	0, -$70, 4, 2, 8, 0, 0, 0, 1		; RING
	spritePiece	$20, -$70, 1, 2, 0, 0, 0, 0, 1		; S
	spritePiece	$30, -$70, 3, 2, $30, 0, 0, 0, 1	; # of rings
;	spritePiece	0, -$60, 4, 2, $10, 0, 0, 0, 1		; TIME
;	spritePiece	$28, -$60, 4, 2, $28, 0, 0, 0, 1	; X:XX
	spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1		; Life Icon
	spritePiece	$10, $40, 4, 2, $10E, 0, 0, 1, 1	; Name and Lives #
@timered_h_End
	even
@allred_h:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; SCOR
	spritePiece	$20, -$80, 4, 2, $18, 0, 0, 0, 1	; E
	spritePiece	$40, -$80, 4, 2, $20, 0, 0, 0, 1	; Score #
;	spritePiece	0, -$70, 4, 2, 8, 0, 0, 0, 1		; RING
;	spritePiece	$20, -$70, 1, 2, 0, 0, 0, 0, 1		; S
	spritePiece	$30, -$70, 3, 2, $30, 0, 0, 0, 1	; # of rings
;	spritePiece	0, -$60, 4, 2, $10, 0, 0, 0, 1		; TIME
	spritePiece	$28, -$60, 4, 2, $28, 0, 0, 0, 1	; X:XX
	spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1		; Life Icon
	spritePiece	$10, $40, 4, 2, $10E, 0, 0, 1, 1	; Name and Lives #
@allred_h_End
	even