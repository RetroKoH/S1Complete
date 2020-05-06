; ----------------------------------------------------------------------------
; Object 05 - Visual Effects (Spin Dash Dust, Insta-Shield, etc.)
; ----------------------------------------------------------------------------
Effects:
		moveq	#0,d0
		move.b	obRoutine(a0),d0 
		move.w	Dust_Index(pc,d0.w),d1
		jmp		Dust_Index(pc,d1.w)
; ===========================================================================
Dust_Index:
		dc.w Dust_Init-Dust_Index
		dc.w Dust_Main-Dust_Index
; ===========================================================================
Dust_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Effects,obMap(a0)
		ori.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	#0,obAnim(a0)
		move.w	#$7A0,obGfx(a0)
		move.w	#$F400,$3C(a0)
; ===========================================================================
Dust_Main:
		btst	#staSpinDash,(v_player+obStatus2).w		; is Player Spin Dashing?	;Mercury Constants

;	if InstaShieldActive=1	;Mercury Insta-Shield
;		bne.s	@active
;		tst.b	(v_player+obInstaShield).w	; is Player doing the InstaShield?	;Mercury Constants
;	endc	;end Insta-Shield
	
		beq.s	@return
	
	@active:
		lea		(v_player).l,a2
		move.w	obX(a2),obX(a0)		; match Player's position
		move.w	obY(a2),obY(a0)
		move.b	obStatus(a2),obStatus(a0)	; match Player's x orientation
		bclr	#staFacing,obRender(a0)	;Mercury Constants
		andi.b	#1,obStatus(a0)
		beq.s	@display
		bset	#staFacing,obRender(a0)	;Mercury Constants

	@display:
		lea		(Ani_Effects).l,a1
		jsr		AnimateSprite
		bsr.s	Dust_LoadArt
		jmp		DisplaySprite

	@return:
		rts
; ===========================================================================
Dust_LoadArt:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		cmp.b	$30(a0),d0
		beq.s	return_1DF36
		move.b	d0,$30(a0)
		lea		(DynPLC_Effects).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d5
		subq.w	#1,d5
		bmi.s	return_1DF36
		move.w	$3C(a0),d4

	@loop:
		moveq	#0,d1
		move.w	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		addi.l	#Art_Effects,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).l
		dbf		d5,@loop

	return_1DF36:
		rts