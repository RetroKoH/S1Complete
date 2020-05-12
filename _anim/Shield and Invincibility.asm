; ---------------------------------------------------------------------------
; Animation script - shield and invincibility stars
; ---------------------------------------------------------------------------
Ani_Shield:

ptr_ShiAni_Blue:		dc.w shield-Ani_Shield
ptr_ShiAni_Stars1:		dc.w stars1-Ani_Shield
ptr_ShiAni_Stars2:		dc.w stars2-Ani_Shield
ptr_ShiAni_Stars3:		dc.w stars3-Ani_Shield
ptr_ShiAni_Stars4:		dc.w stars4-Ani_Shield
ptr_ShiAni_Flame:		dc.w flame1-Ani_Shield
ptr_ShiAni_FlameDash:	dc.w flame2-Ani_Shield
ptr_ShiAni_Bubble:		dc.w bubble1-Ani_Shield
ptr_ShiAni_BubbleDown:	dc.w bubble2-Ani_Shield
ptr_ShiAni_BubbleUp:	dc.w bubble3-Ani_Shield
ptr_ShiAni_Lightning:	dc.w lightning1-Ani_Shield
ptr_ShiAni_Lightning2:	dc.w lightning2-Ani_Shield
ptr_ShiAni_Lightning3:	dc.w lightning3-Ani_Shield
ptr_ShiAni_Insta:		dc.w insta1-Ani_Shield
ptr_ShiAni_InstaActive:	dc.w insta2-Ani_Shield

shield:			dc.b 1,	1, 0, 2, 0, 3, 0, afEnd

stars1:			dc.b 5,	4, 5, 6, 7, afEnd

stars2:			dc.b 0,	4, 4, 0, 4, 4, 0, 5, 5,	0, 5, 5, 0, 6, 6, 0, 6
				dc.b 6,	0, 7, 7, 0, 7, 7, 0, afEnd

stars3:			dc.b 0,	4, 4, 0, 4, 0, 0, 5, 5,	0, 5, 0, 0, 6, 6, 0, 6
				dc.b 0,	0, 7, 7, 0, 7, 0, 0, afEnd

stars4:			dc.b 0,	4, 0, 0, 4, 0, 0, 5, 0,	0, 5, 0, 0, 6, 0, 0, 6
				dc.b 0,	0, 7, 0, 0, 7, 0, 0, afEnd

flame1:			dc.b 1, 0, $F, 1, $10, 2, $11, 3, $12, 4, $13, 5, $14, 6, $15, 7, $16, 8, $17, afEnd

flame2:			dc.b 1, 9, $A, $B, $C, $D, $E, 9, $A, $B, $C, $D, $E, afChange, 5

bubble1:		dc.b    1,   0,   9,   0,   9,   0,   9,   1,  $A,   1,  $A,   1,  $A,   2,   9,   2,   9,   2,   9,   3
				dc.b   $A,   3,  $A,   3,  $A,   4,   9,   4,   9,   4,   9,   5,  $A,   5,  $A,   5,  $A,   6,   9,   6
				dc.b    9,   6,   9,   7,  $A,   7,  $A,   7,  $A,   8,   9,   8,   9,   8,   9, afEnd

bubble2:		dc.b	5,   9,	 $B,  $B,  $B, afChange, 7

bubble3:		dc.b	5,  $C,	 $C,  $B, afChange, 7, 0

lightning1:		dc.b    1,   0,   0,   1,   1,   2,   2,   3,   3,   4,   4,   5,   5,   6,   6,   7,   7,   8,   8,   9
				dc.b   $A,  $B, $16, $16, $15, $15, $14, $14, $13, $13, $12, $12
				dc.b  $11, $11,	$10, $10,  $F,	$F,  $E,  $E,	9,  $A,	 $B, afEnd

lightning2:		dc.b    0,  $C,  $D, $17,  $C,  $D, $17,  $C,  $D, $17,  $C,  $D, $17,  $C,  $D, $17,  $C,  $D, $17,  $C
				dc.b   $D, afRoutine, -1

lightning3:		dc.b	3,   0,	  1,   2, afRoutine, -1,   0

insta1:			dc.b  $1F,   6,	afEnd

insta2:			dc.b	0,   0,	  1,   2,   3,	 4,   5,   6,	6,   6,	  6,   6,   6,	 6,   7, afChange, $D
		even

aniID_BlueShield:		equ	(ptr_ShiAni_Blue-Ani_Shield)/2		; 0
aniID_InvStars1:		equ	(ptr_ShiAni_Stars1-Ani_Shield)/2	; 1
aniID_InvStars2:		equ	(ptr_ShiAni_Stars2-Ani_Shield)/2	; 2
aniID_InvStars3:		equ	(ptr_ShiAni_Stars3-Ani_Shield)/2	; 3
aniID_InvStars4:		equ	(ptr_ShiAni_Stars4-Ani_Shield)/2	; 4
aniID_FlameShield:		equ	(ptr_ShiAni_Flame-Ani_Shield)/2		; 5
aniID_FlameDash:		equ	(ptr_ShiAni_FlameDash-Ani_Shield)/2	; 6
aniID_BubbleShield:		equ	(ptr_ShiAni_Bubble-Ani_Shield)/2	; 7 - Standard animation for Bubble Shield
aniID_BubbleBounce:		equ	(ptr_ShiAni_BubbleDown-Ani_Shield)/2	; 8 - Used by Sonic_JumpHeight when going downward for the bounce
aniID_BubbleBounceUp:	equ	(ptr_ShiAni_BubbleUp-Ani_Shield)/2	; 9 - Used by Sonic_ResetOnFloor when bouncing up
aniID_LightningShield:	equ	(ptr_ShiAni_Lightning-Ani_Shield)/2	; A - Standard animation for Lightning Shield
aniID_LightningSpark:	equ	(ptr_ShiAni_Lightning2-Ani_Shield)/2	; B - Used by Sonic_JumpHeight when jumping up, and used by sparks
aniID_LightningStars:	equ	(ptr_ShiAni_Lightning3-Ani_Shield)/2	; C - Apparently used for Super Sonic Stars
