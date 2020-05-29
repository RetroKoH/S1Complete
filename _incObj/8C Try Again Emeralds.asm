; ---------------------------------------------------------------------------
; Object 8C - chaos emeralds on	the "TRY AGAIN"	screen
; ---------------------------------------------------------------------------

TryChaos:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	TCha_Index(pc,d0.w),d1
		jsr	TCha_Index(pc,d1.w)
		jmp	(DisplaySprite).l
; ===========================================================================
TCha_Index:	dc.w TCha_Main-TCha_Index
		dc.w TCha_Move-TCha_Index
; ===========================================================================

TCha_Main:	; Routine 0
		movea.l	a0,a1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#5,d1
		sub.b	(v_emeralds).w,d1	; d1 is number of emeralds we don't have, -1.

@makeemerald:
		move.b	#id_TryChaos,obID(a1) ; load emerald object
		addq.b	#2,obRoutine(a1)
		move.l	#Map_ECha,obMap(a1)
		move.w	#$3C5,obGfx(a1)
		move.b	#0,obRender(a1)
		move.w	#$80,obPriority(a1)
		move.w	#$104,obX(a1)
		move.w	#$120,$38(a1)
		move.w	#$EC,obScreenY(a1)
		move.w	obScreenY(a1),$3A(a1)
		move.b	#$1C,$3C(a1)
		move.b	(v_emeraldlist).w,d4	; d4 = bit field that tells which emeralds we do/don't have
		moveq	#0,d0
		move.b	(v_emeralds).w,d0	; load # of total emeralds to d0
		beq.s	@loc_5B42		; branch ahead if you have no emeralds

	@chkemerald:
		btst	d2,d4			; Did you get the emerald?
		beq.s	@loc_5B42		; if not, branch ahead and set the mappings.
		addq.b	#1,d2			; Check for the next emerald.
		bra.s	@chkemerald		; Jump back and check again.
; ===========================================================================

	@loc_5B42:
		move.b	d2,obFrame(a1)
		addq.b	#1,obFrame(a1)
		addq.b	#1,d2
		move.b	#$80,obAngle(a1)
		move.b	d3,obTimeFrame(a1)
		move.b	d3,obDelayAni(a1)
		addi.w	#10,d3
		lea		$40(a1),a1
		dbf		d1,@makeemerald	; repeat 5 times

TCha_Move:	; Routine 2
		tst.w	$3E(a0)
		beq.s	locret_5BBA
		tst.b	obTimeFrame(a0)
		beq.s	loc_5B78
		subq.b	#1,obTimeFrame(a0)
		bne.s	loc_5B80

loc_5B78:
		move.w	$3E(a0),d0
		add.w	d0,obAngle(a0)

loc_5B80:
		move.b	obAngle(a0),d0
		beq.s	loc_5B8C
		cmpi.b	#$80,d0
		bne.s	loc_5B96

loc_5B8C:
		clr.w	$3E(a0)
		move.b	obDelayAni(a0),obTimeFrame(a0)

loc_5B96:
		jsr		(CalcSine).l
		moveq	#0,d4
		move.b	$3C(a0),d4
		muls.w	d4,d1
		asr.l	#8,d1
		muls.w	d4,d0
		asr.l	#8,d0
		add.w	$38(a0),d1
		add.w	$3A(a0),d0
		move.w	d1,obX(a0)
		move.w	d0,obScreenY(a0)

locret_5BBA:
		rts	
