; ---------------------------------------------------------------------------
; Object 3D - Eggman (GHZ)
; ---------------------------------------------------------------------------

BossGreenHill:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BGHZ_Index(pc,d0.w),d1
		jmp		BGHZ_Index(pc,d1.w)
; ===========================================================================
BGHZ_Index:
		dc.w BGHZ_Init-BGHZ_Index
		dc.w BGHZ_ShipMain-BGHZ_Index
		dc.w BGHZ_FaceMain-BGHZ_Index
		dc.w BGHZ_FlameMain-BGHZ_Index

BGHZ_ObjData:
		; Ship
		dc.b 2,	0		; routine counter, animation
		; Face
		dc.b 4,	1
		; Flame
		dc.b 6,	7
; ===========================================================================

BGHZ_Init:	; Routine 0
		lea		(BGHZ_ObjData).l,a2
		movea.l	a0,a1
		moveq	#2,d1
		bra.s	BGHZ_LoadBoss
; ===========================================================================

BGHZ_Loop:
		jsr		(FindNextFreeObj).l
		bne.s	BGHZ_InitVars

BGHZ_LoadBoss:
		move.b	(a2)+,obRoutine(a1)
		move.b	#id_BossGreenHill,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Eggman,obMap(a1)
		move.w	#ArtNem_Eggman,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.w	#$180,obPriority(a1)
		move.b	(a2)+,obAnim(a1)
		move.l	a0,obBossParent(a1)		; set first boss object as the parent
		dbf		d1,BGHZ_Loop			; repeat sequence 2 more times

BGHZ_InitVars:
		move.w	obX(a0),obBossBufferX(a0)	; set starting x-pos to $30
		move.w	obX(a0),(v_boss_start_x).w	; new variable for positioning purposes between layouts (Difficulties, Boss Rush, etc.)
		move.w	obY(a0),obBossBufferY(a0)	; set starting y-pos to $38
		move.w	obY(a0),(v_boss_start_y).w	; new variable for positioning purposes between layouts (Difficulties, Boss Rush, etc.)
		move.b	#$F,obColType(a0)
		move.b	#8,obColProp(a0)			; set number of hits to 8
		cmpi.b	#difEasy,(v_difficulty).w
		bne.s	BGHZ_ShipMain
		move.b	#6,obColProp(a0)			; set number of hits to 6 for Easy Mode

BGHZ_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BGHZ_ShipIndex(pc,d0.w),d1
		jsr		BGHZ_ShipIndex(pc,d1.w)

		lea		(Ani_Eggman).l,a1
		jsr		(AnimateSprite).l
		move.b	obStatus(a0),d0
		andi.b	#3,d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplaySprite).l
; ===========================================================================
BGHZ_ShipIndex:
					dc.w BGHZ_ShipStart-BGHZ_ShipIndex			; Sub-Routine 0
					dc.w BGHZ_MakeBall-BGHZ_ShipIndex			; Sub-Routine 2
					dc.w BGHZ_ShipSetDirection-BGHZ_ShipIndex	; Sub-Routine 4
					dc.w BGHZ_ShipMove-BGHZ_ShipIndex			; Sub-Routine 6
ptr_BGHZ_Defeat:	dc.w BGHZ_ShipExplode-BGHZ_ShipIndex		; Sub-Routine 8
					dc.w BGHZ_AfterExplosions-BGHZ_ShipIndex	; Sub-Routine A
					dc.w BGHZ_Retreat-BGHZ_ShipIndex			; Sub-Routine C

id_BGHZDefeated: 	equ ptr_BGHZ_Defeat-BGHZ_ShipIndex
; ===========================================================================

BGHZ_ShipStart:		; Sub-Routine 0
		move.w	#$100,obVelY(a0)			; move ship down
		bsr.w	BossMove
		move.w	(v_boss_start_y).w,d0
		addi.w	#$B8,d0
		move.w	obBossBufferY(a0),d1
		cmp.w	d0,d1						; has the ship lowered all the way down to the arena?
		bne.s	loc_177E6					; if not, branch
		clr.w	obVelY(a0)					; stop ship
		addq.b	#2,ob2ndRout(a0)			; goto next routine

loc_177E6:
		move.b	obBossHoverValue(a0),d0
		jsr		(CalcSine).l
		asr.w	#6,d0
		add.w	obBossBufferY(a0),d0		; Add the buffer y-pos
		move.w	d0,obY(a0)					; Apply stored y-pos to actual y-pos (hover effect)
;		move.w	obBossBufferY(a0),obY(a0)	; Apply stored y-pos to actual y-pos (without hover effect)
		move.w	obBossBufferX(a0),obX(a0)	; Apply stored x-pos to actual x-pos
		addq.b	#2,obBossHoverValue(a0)

		cmpi.b	#id_BGHZDefeated,ob2ndRout(a0)	; Has Eggman already been defeated?
		bcc.s	locret_1784A					; if yes, branch
		tst.b	obStatus(a0)					; Did Eggman take the final hit?
		bmi.s	BGHZ_Defeat						; if yes, branch to adding points and setting routine
		tst.b	obColType(a0)					; can the boss be hit?
		bne.s	locret_1784A					; if yes, branch
		tst.b	obBossFlashTime(a0)				; if not, is the boss flashing?
		bne.s	BGHZ_ShipFlash					; if yes, branch
		move.b	#$20,obBossFlashTime(a0)		; set number of	frames for ship to flash
		sfx		sfx_HitBoss,0,0,0				; play boss damage sound

BGHZ_ShipFlash:
		lea		(v_pal_dry+$22).w,a1		; load 2nd pallet, 2nd entry
		moveq	#0,d0						; move 0 (black) to d0
		tst.w	(a1)
		bne.s	loc_1783C
		move.w	#cWhite,d0					; move 0EEE (white) to d0

loc_1783C:
		move.w	d0,(a1)						; load colour stored in	d0
		subq.b	#1,obBossFlashTime(a0)		; decrement flash timer
		bne.s	locret_1784A				; if time remains, branch
		move.b	#$F,obColType(a0)			; otherwise, make the boss vulnerable to damage again

locret_1784A:
		rts	
; ===========================================================================

BGHZ_Defeat:
		cmpi.b	#difHard,(v_difficulty).w
		bne.s	@noPinchMode
		tst.b	obBossPinchMode(a0)
		bne.s	@noPinchMode
		bclr	#7,obStatus(a0)
		bset	#0,obBossPinchMode(a0)
		move.b	#4,obColProp(a0)
		music	bgm_Speedup,0,0,0		; speed	up the music
		rts

	@noPinchMode:
		cmpi.b	#difHard,(v_difficulty).w
		bne.s	@skipMusic
		music	bgm_Slowdown,0,0,0		; slow down the music

	@skipMusic:		
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#id_BGHZDefeated,ob2ndRout(a0)
		move.w	#$B3,obBossDelayTimer(a0)
		rts
