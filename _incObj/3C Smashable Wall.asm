; ---------------------------------------------------------------------------
; Object 3C - smashable	wall (GHZ, SLZ)
; ---------------------------------------------------------------------------

SmashWall:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Smash_Index(pc,d0.w),d1
		jsr		Smash_Index(pc,d1.w)
		bra.w	RememberState
; ===========================================================================
Smash_Index:
		dc.w Smash_Main-Smash_Index
		dc.w Smash_Solid-Smash_Index
		dc.w Smash_FragMove-Smash_Index

smash_speed:	equ $30		; Sonic's horizontal speed
; ===========================================================================

Smash_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Smash,obMap(a0)
		move.w	#ArtNem_GHZBreakWall,obGfx(a0)
		cmpi.b	#id_SLZ,(v_zone).w
		bne.s	@notslz
		move.w	#ArtNem_SLZBreakWall,obGfx(a0) ; SLZ
	@notslz:
		move.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$200,obPriority(a0)
		move.b	obSubtype(a0),obFrame(a0)

Smash_Solid:	; Routine 2
		move.w	(v_player+obVelX).w,smash_speed(a0) ; load Sonic's horizontal speed
		move.w	#$1B,d1
		move.w	#$20,d2
		move.w	#$20,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		beq.s	@donothing

;		cmpi.b	#ch_Knuckles,obCharID(a1)	; is the current character Knuckles
;		beq.s	@continue					; if yes, continue
;		tst.b	obCharID(a1)				; is the player Sonic?
;		bne.s	@chkPush					; if not, skip and check if player is rolling on the ground
		btst	#stsFlame,(v_status_secondary).w	; does Sonic have the Flame Shield
		beq.s	@chkPush							; if not, skip and check if player is rolling on the ground
		tst.b	obJumpFlag(a1)			; is Sonic using his ability?
		bne.s	@continue				; if yes, branch. ABILITY TIME

	@chkPush:
		btst	#staPush,obStatus(a0)	; is Sonic pushing against the wall?
		beq.s	@donothing				; if no, branch

	@chkroll:
		cmpi.b	#aniID_Roll,obAnim(a1)	; is Sonic rolling?
		bne.s	@donothing				; if not, branch
		move.w	smash_speed(a0),d0
		bpl.s	@chkspeed
		neg.w	d0

	@chkspeed:
		cmpi.w	#$480,d0	; is Sonic's speed $480 or higher?
		bcs.s	@donothing	; if not, branch

	@continue:
		bclr	#staPush,obStatus(a0)
		move.w	smash_speed(a0),obVelX(a1)
		addq.w	#4,obX(a1)
		lea		(Smash_FragSpd1).l,a4 ;	use fragments that move	right
		move.w	obX(a0),d0
		cmp.w	obX(a1),d0	; is Sonic to the right	of the block?
		bcs.s	@smash		; if yes, branch
		subq.w	#8,obX(a1)
		lea		(Smash_FragSpd2).l,a4 ;	use fragments that move	left

	@smash:
		move.w	obVelX(a1),obInertia(a1)
;		bclr	#staPush,obStatus(a0)
		bclr	#staPush,obStatus(a1)
		moveq	#7,d1		; load 8 fragments
		move.w	#$70,d2
		bsr.s	SmashObject

	@donothing:
		rts	
; ===========================================================================

Smash_FragMove:	; Routine 4
		addq.l	#4,sp
		bsr.w	SpeedToPos
		addi.w	#$70,obVelY(a0)	; make fragment	fall faster
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
