; ---------------------------------------------------------------------------
; Sprite mappings - bubbles (LZ)
; ---------------------------------------------------------------------------
Map_Bub:
	dc.w	@bubble1-Map_Bub
	dc.w	@bubble2-Map_Bub
	dc.w	@bubble3-Map_Bub
	dc.w	@bubble4-Map_Bub
	dc.w	@bubble5-Map_Bub
	dc.w	@bubble6-Map_Bub
	dc.w	@bubblefull-Map_Bub
	dc.w	@burst1-Map_Bub
	dc.w	@burst2-Map_Bub
	dc.w	@zero_sm-Map_Bub
	dc.w	@five_sm-Map_Bub
	dc.w	@three_sm-Map_Bub
	dc.w	@one_sm-Map_Bub
	dc.w	@zero-Map_Bub
	dc.w	@five-Map_Bub
	dc.w	@four-Map_Bub
	dc.w	@three-Map_Bub
	dc.w	@two-Map_Bub
	dc.w	@one-Map_Bub
	dc.w	@bubmaker1-Map_Bub
	dc.w	@bubmaker2-Map_Bub
	dc.w	@bubmaker3-Map_Bub
	dc.w	@blank-Map_Bub

@bubble1:	dc.b 1
	dc.b $FC, 0, 0, 0, $FC

@bubble2:	dc.b 1
	dc.b $FC, 0, 0, 1, $FC

@bubble3:	dc.b 1
	dc.b $FC, 0, 0, 2, $FC

@bubble4:	dc.b 1
	dc.b $F8, 5, 0, 3, $F8

@bubble5:	dc.b 1
	dc.b $F8, 5, 0, 7, $F8

@bubble6:	dc.b 1
	dc.b $F4, $A, 0, $B, $F4

@bubblefull:	dc.b 1
	dc.b $F0, $F, 0, $14, $F0

@burst1:	dc.b 4
	dc.b $F0, 5, 0, $24, $F0
	dc.b $F0, 5, 8, $24, 0
	dc.b 0, 5, $10, $24, $F0
	dc.b 0, 5, $18, $24, 0

@burst2:	dc.b 4
	dc.b $F0, 5, 0, $28, $F0
	dc.b $F0, 5, 8, $28, 0
	dc.b 0, 5, $10, $28, $F0
	dc.b 0, 5, $18, $28, 0

@zero_sm:	dc.b 1
	dc.b $F4, 6, 0, $2C, $F8

@five_sm:	dc.b 1
	dc.b $F4, 6, 0, $32, $F8

@three_sm:	dc.b 1
	dc.b $F4, 6, 0, $38, $F8

@one_sm:	dc.b 1
	dc.b $F4, 6, 0, $3E, $F8

; REV C EDIT - Palette Line Mod, all numbers use same line as art_tile setting, goign from $20 to 0
@zero:	dc.b 1
	dc.b $F4, 6, $0, $44, $F8

@five:	dc.b 1
	dc.b $F4, 6, $0, $4A, $F8

@four:	dc.b 1
	dc.b $F4, 6, $0, $50, $F8

@three:	dc.b 1
	dc.b $F4, 6, $0, $56, $F8

@two:	dc.b 1
	dc.b $F4, 6, $0, $5C, $F8

@one:	dc.b 1
	dc.b $F4, 6, $0, $62, $F8

@bubmaker1:	dc.b 1
	dc.b $F8, 5, 0, $68, $F8

@bubmaker2:	dc.b 1
	dc.b $F8, 5, 0, $6C, $F8

@bubmaker3:	dc.b 1
	dc.b $F8, 5, 0, $70, $F8

@blank:	dc.b 0

	even
