; ----------------------------------------------------------------------------
; Object 05 - Visual Effects (Spin Dash Dust, Insta-Shield, etc.)
; ----------------------------------------------------------------------------
Effects:
		moveq	#0,d0
		move.b	obRoutine(a0),d0 
		move.w	Effects_Index(pc,d0.w),d1
		jmp		Effects_Index(pc,d1.w)
; ===========================================================================
Effects_Index:
		dc.w Effects_Init-Effects_Index
		dc.w Effects_Main-Effects_Index
		dc.w Effects_Delete-Effects_Index
; ===========================================================================
Effects_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Effects,obMap(a0)
		ori.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.b	#0,obAnim(a0)
		move.w	#$7A0,obGfx(a0)
		move.w	#$F400,$3C(a0)
; ===========================================================================
Effects_Main:
		lea		(v_player).w,a2
		moveq	#0,d0
		move.b	obAnim(a0),d0	; use current animation as a secondary routine counter
		add.w	d0,d0
		move.w	Fx_DisplayModes(pc,d0.w),d1
		jmp		Fx_DisplayModes(pc,d1.w)
; ===========================================================================
; off_1DDA4:
Fx_DisplayModes:
		dc.w Fx_MdDisplay-Fx_DisplayModes	; 0
		dc.w Fx_MdSpindashDust-Fx_DisplayModes	; 2
		dc.w Fx_MdDisplay-Fx_DisplayModes;Fx_MdSkidDust-Fx_DisplayModes	; 4
; ===========================================================================
Fx_MdSpindashDust:
		cmpi.b	#4,obRoutine(a2)
		bhs.s	Fx_ResetDisplayMode
		btst	#staSpinDash,obStatus2(a2)
		beq.s	Fx_ResetDisplayMode
		move.w	obX(a2),obX(a0)			; match Player's position
		move.w	obY(a2),obY(a0)
		move.b	obStatus(a2),obStatus(a0)	; match Player's x orientation
		andi.b	#1,obStatus(a0)

Fx_MdDisplay:
		lea		(Ani_Effects).l,a1
		jsr		AnimateSprite
		bsr.s	Effects_LoadGfx
		jmp		DisplaySprite

Fx_MdNull:
		rts
; ===========================================================================
Fx_ResetDisplayMode:
		clr.b	obAnim(a0)
		rts

Effects_Delete:	; Routine 4
		jmp		DeleteObject	; delete when animation	is complete
; ===========================================================================

Effects_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		move.l	#Art_Effects,d6

		lea		(DynPLC_Effects).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5          ; read "number of entries" value
		subq.w	#1,d5
		bmi.s	EffectsDPLC_Return ; if zero, branch
		move.w	#$F400,d4

EffectsDPLC_ReadEntry:
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
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).l
		dbf		d5,EffectsDPLC_ReadEntry	; repeat for number of entries

EffectsDPLC_Return:
		rts