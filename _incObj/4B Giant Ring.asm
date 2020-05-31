; ---------------------------------------------------------------------------
; Object 4B - giant ring for entry to special stage
; ---------------------------------------------------------------------------

GiantRing:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GRing_Index(pc,d0.w),d1
		jmp	GRing_Index(pc,d1.w)
; ===========================================================================
GRing_Index:
		dc.w GRing_Main-GRing_Index
		dc.w GRing_Animate-GRing_Index
		dc.w GRing_Collect-GRing_Index
		dc.w GRing_Delete-GRing_Index
; ===========================================================================

GRing_Main:	; Routine 0
		tst.b	(f_timeattack).w		; don't let the Giant Ring appear in Time Attack mode
		bne.w	GRing_Delete
		cmpi.b	#modeHandheld,(v_optgamemode).w
		beq.w	GRing_Delete			; dont let the Ring appear in handheld mode either

		move.l	#Map_GRing,obMap(a0)
		move.w	#$2430,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$40,obActWid(a0)
		tst.b	obRender(a0)
		bpl.s	GRing_Animate

		cmpi.b	#6,(v_emeralds).w ; do you have all of the emeralds? (Can toggle between 6/7)
		beq.w	GRing_Delete	; if yes, branch
		cmpi.w	#50,(v_rings).w	; do you have at least 50 rings?
		bcc.s	GRing_Okay	; if yes, branch
		rts	
; ===========================================================================

GRing_Okay:
		addq.b	#2,obRoutine(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$52,obColType(a0)

GRing_Animate:	; Routine 2
		move.b	(v_ani2_frame).w,obFrame(a0)
		out_of_range	DeleteObject
		bsr.w	GRing_LoadGfx
		bra.w	DisplaySprite
; ===========================================================================

GRing_Collect:	; Routine 4
		subq.b	#2,obRoutine(a0)
		clr.b	obColType(a0)
		bsr.w	FindFreeObj
		bne.w	GRing_PlaySnd
		move.b	#id_RingFlash,obID(a1) ; load giant ring flash object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	a0,$3C(a1)
		move.w	(v_player+obX).w,d0
		cmp.w	obX(a0),d0	; has Sonic come from the left?
		bcs.s	GRing_PlaySnd	; if yes, branch
		bset	#0,obRender(a1)	; reverse flash	object

GRing_PlaySnd:
		sfx	sfx_GiantRing,0,0,0	; play giant ring sound
		bra.s	GRing_Animate
; ===========================================================================

GRing_Delete:	; Routine 6
		bra.w	DeleteObject
; ===========================================================================

GRing_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		lea		(GRingDynPLC).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
        move.b	(a2)+,d5          ; read "number of entries" value
		subq.w	#1,d5
		bmi.s	GRingDPLC_Return ; if zero, branch
		move.w	#$8600,d4

GRingDPLC_ReadEntry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	#Art_BigRing,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).l
		dbf		d5,GRingDPLC_ReadEntry	; repeat for number of entries

GRingDPLC_Return:
		rts