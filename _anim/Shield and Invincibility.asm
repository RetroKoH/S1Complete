; ---------------------------------------------------------------------------
; Animation script - shield and invincibility stars
; ---------------------------------------------------------------------------
Ani_Shield:
		dc.w @shield-Ani_Shield
		dc.w @stars1-Ani_Shield
		dc.w @stars2-Ani_Shield
		dc.w @stars3-Ani_Shield
		dc.w @stars4-Ani_Shield
		dc.w @flame1-Ani_Shield
		dc.w @flame2-Ani_Shield
		dc.w @bubble1-Ani_Shield
		dc.w @bubble2-Ani_Shield
		dc.w @bubble3-Ani_Shield
		dc.w @lightning1-Ani_Shield
		dc.w @lightning2-Ani_Shield
		dc.w @lightning3-Ani_Shield
		dc.w @insta1-Ani_Shield
		dc.w @insta2-Ani_Shield
@shield:	dc.b 1,	1, 0, 2, 0, 3, 0, afEnd
@stars1:	dc.b 5,	4, 5, 6, 7, afEnd
@stars2:	dc.b 0,	4, 4, 0, 4, 4, 0, 5, 5,	0, 5, 5, 0, 6, 6, 0, 6
		dc.b 6,	0, 7, 7, 0, 7, 7, 0, afEnd
@stars3:	dc.b 0,	4, 4, 0, 4, 0, 0, 5, 5,	0, 5, 0, 0, 6, 6, 0, 6
		dc.b 0,	0, 7, 7, 0, 7, 0, 0, afEnd
@stars4:	dc.b 0,	4, 0, 0, 4, 0, 0, 5, 0,	0, 5, 0, 0, 6, 0, 0, 6
		dc.b 0,	0, 7, 0, 0, 7, 0, 0, afEnd
@flame1:	dc.b 1, 0, $F, 1, $10, 2, $11, 3, $12, 4, $13, 5, $14, 6, $15, 7, $16, 8, $17, afEnd
@flame2:	dc.b 1, 9, $A, $B, $C, $D, $E, 9, $A, $B, $C, $D, $E, afChange, 5
@bubble1:	dc.b    1,   0,   9,   0,   9,   0,   9,   1,  $A,   1,  $A,   1,  $A,   2,   9,   2,   9,   2,   9,   3
		dc.b   $A,   3,  $A,   3,  $A,   4,   9,   4,   9,   4,   9,   5,  $A,   5,  $A,   5,  $A,   6,   9,   6
		dc.b    9,   6,   9,   7,  $A,   7,  $A,   7,  $A,   8,   9,   8,   9,   8,   9, afEnd
@bubble2:	dc.b	5,   9,	 $B,  $B,  $B, afChange, 7
@bubble3:	dc.b	5,  $C,	 $C,  $B, afChange, 7, 0
@lightning1:	dc.b    1,   0,   0,   1,   1,   2,   2,   3,   3,   4,   4,   5,   5,   6,   6,   7,   7,   8,   8,   9
		dc.b   $A,  $B, $16, $16, $15, $15, $14, $14, $13, $13, $12, $12
		dc.b  $11, $11,	$10, $10,  $F,	$F,  $E,  $E,	9,  $A,	 $B, afEnd
@lightning2:	dc.b    0,  $C,  $D, $17,  $C,  $D, $17,  $C,  $D, $17,  $C,  $D, $17,  $C,  $D, $17,  $C,  $D, $17,  $C
		dc.b   $D, afRoutine, -1
@lightning3:	dc.b	3,   0,	  1,   2, afRoutine, -1,   0
@insta1:	dc.b  $1F,   6,	afEnd
@insta2:	dc.b	0,   0,	  1,   2,   3,	 4,   5,   6,	6,   6,	  6,   6,   6,	 6,   7, afChange, $D
		even