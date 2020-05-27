; ---------------------------------------------------------------------------
; Object 73 - Eggman (MZ)
; ---------------------------------------------------------------------------

BossMarble:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj73_Index(pc,d0.w),d1
		jmp		Obj73_Index(pc,d1.w)
; ===========================================================================
Obj73_Index:
		dc.w Obj73_Main-Obj73_Index
		dc.w Obj73_ShipMain-Obj73_Index
		dc.w Obj73_FaceMain-Obj73_Index
		dc.w Obj73_FlameMain-Obj73_Index
		dc.w Obj73_TubeMain-Obj73_Index

Obj73_ObjData:	; routine number, animation
				; priority
		; Ship
		dc.b 2,	0
		dc.w $200
		; Face
		dc.b 4, 1
		dc.w $200
		; Flame
		dc.b 6, 7
		dc.w $200
		; Tube
		dc.b 8, 0
		dc.w $180
; ===========================================================================

Obj73_Main:	; Routine 0
		move.w	obX(a0),obBossBufferX(a0)
		move.w	obX(a0),(v_boss_start_x).w	; new variable for positioning purposes between layouts (Difficulties, Boss Rush, etc.)
		move.w	obY(a0),obBossBufferY(a0)
		move.w	obY(a0),(v_boss_start_y).w	; new variable for positioning purposes between layouts (Difficulties, Boss Rush, etc.)
		move.b	#$F,obColType(a0)
		move.b	#8,obColProp(a0) ; set number of hits to 8
		cmpi.b	#difEasy,(v_difficulty).w
		bne.s	@notEasy
		move.b	#6,obColProp(a0)			; set number of hits to 6 for Easy Mode
	@notEasy:
		lea		Obj73_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj73_LoadBoss
; ===========================================================================

Obj73_Loop:
		jsr		(FindNextFreeObj).l
		bne.s	Obj73_ShipMain
		move.b	#id_BossMarble,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

Obj73_LoadBoss:
		bclr	#staFacing,obStatus(a0)
		clr.b	ob2ndRout(a1)
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,obAnim(a1)
		move.w	(a2)+,obPriority(a1)
		move.l	#Map_Eggman,obMap(a1)
		move.w	#ArtNem_Eggman,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.l	a0,obBossParent(a1)
		dbf		d1,Obj73_Loop	; repeat sequence 3 more times

Obj73_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj73_ShipIndex(pc,d0.w),d1
		jsr		Obj73_ShipIndex(pc,d1.w)
		lea		(Ani_Eggman).l,a1
		jsr		(AnimateSprite).l
		moveq	#3,d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplaySprite).l
; ===========================================================================
Obj73_ShipIndex:
					dc.w BMZ_ShipStart-Obj73_ShipIndex
					dc.w loc_183AA-Obj73_ShipIndex
ptr_BMZ_Defeat:		dc.w BMZ_ShipExplode-Obj73_ShipIndex
					dc.w BMZ_AfterExplosions-Obj73_ShipIndex
					dc.w BMZ_Retreat-Obj73_ShipIndex

id_BMZDefeated: 	equ ptr_BMZ_Defeat-Obj73_ShipIndex
; ===========================================================================

BMZ_ShipStart:
		move.b	obBossHoverValue(a0),d0
		addq.b	#2,obBossHoverValue(a0)
		jsr		(CalcSine).l
		asr.w	#2,d0
		move.w	d0,obVelY(a0)
		move.w	#-$100,obVelX(a0)
		bsr.w	BossMove

		move.w	(v_boss_start_x).w,d0
		subi.w	#$E0,d0
		move.w	obBossBufferX(a0),d1
		cmp.w	d0,d1
		;cmpi.w	#$1910,obBossBufferX(a0)

		bne.s	loc_18334
		addq.b	#2,ob2ndRout(a0)
		clr.b	obSubtype(a0)
		clr.l	obVelX(a0)

loc_18334:
		jsr		(RandomNumber).l
		move.b	d0,$34(a0)

loc_1833E:
		move.w	obBossBufferY(a0),obY(a0)
		move.w	obBossBufferX(a0),obX(a0)

		cmpi.b	#id_BMZDefeated,ob2ndRout(a0)	; Has Eggman already been defeated?
		bcc.s	locret_18390					; if yes, branch
		tst.b	obStatus(a0)					; Did Eggman take the final hit?
		bmi.s	BMZ_Defeat						; if yes, branch to adding points and setting routine
		tst.b	obColType(a0)					; can the boss be hit?
		bne.s	locret_18390					; if yes, branch
		tst.b	obBossFlashTime(a0)				; if not, is the boss flashing?
		bne.s	BMZ_ShipFlash					; if yes, branch
		move.b	#$28,obBossFlashTime(a0)		; set number of	frames for ship to flash
		sfx		sfx_HitBoss,0,0,0				; play boss damage sound

BMZ_ShipFlash:
		lea		(v_pal_dry+$22).w,a1		; load 2nd pallet, 2nd entry
		moveq	#0,d0						; move 0 (black) to d0
		tst.w	(a1)
		bne.s	loc_18382
		move.w	#cWhite,d0					; move 0EEE (white) to d0

loc_18382:
		move.w	d0,(a1)						; load colour stored in	d0
		subq.b	#1,obBossFlashTime(a0)		; decrement flash timer
		bne.s	locret_18390				; if time remains, branch
		move.b	#$F,obColType(a0)			; otherwise, make the boss vulnerable to damage again

locret_18390:
		rts	
; ===========================================================================

BMZ_Defeat:
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
		move.b	#4,ob2ndRout(a0)
		move.w	#$B4,obBossDelayTimer(a0)
		clr.w	obVelX(a0)
		rts	
; ===========================================================================

loc_183AA:
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		move.w	off_183C2(pc,d0.w),d0
		jsr		off_183C2(pc,d0.w)
		andi.b	#6,obSubtype(a0)
		bra.w	loc_1833E
; ===========================================================================
off_183C2:	dc.w loc_183CA-off_183C2
		dc.w Obj73_MakeLava2-off_183C2
		dc.w loc_183CA-off_183C2
		dc.w Obj73_MakeLava2-off_183C2
; ===========================================================================

loc_183CA:
		tst.w	obVelX(a0)
		bne.s	loc_183FE
		moveq	#$40,d0

		move.w	(v_boss_start_y).w,d1
		move.w	obBossBufferY(a0),d2
		cmp.w	d1,d2

		beq.s	loc_183E6
		bcs.s	loc_183DE
		neg.w	d0

loc_183DE:
		move.w	d0,obVelY(a0)
		bra.w	BossMove
; ===========================================================================

loc_183E6:
		move.w	#$200,obVelX(a0)
		move.w	#$100,obVelY(a0)
		btst	#0,obStatus(a0)
		bne.s	loc_183FE
		neg.w	obVelX(a0)

loc_183FE:
		cmpi.b	#$18,$3E(a0)
		bcc.s	Obj73_MakeLava
		bsr.w	BossMove
		subq.w	#4,obVelY(a0)

Obj73_MakeLava:
		subq.b	#1,$34(a0)
		bcc.s	loc_1845C
		jsr	(FindFreeObj).l
		bne.s	loc_1844A
		move.b	#id_LavaBall,obID(a1) ; load lava ball object
		move.w	#$2E8,obY(a1)	; set Y	position
		jsr	(RandomNumber).l
		andi.l	#$FFFF,d0
		divu.w	#$50,d0
		swap	d0
		addi.w	#$1878,d0
		move.w	d0,obX(a1)
		lsr.b	#7,d1
		move.w	#$FF,obSubtype(a1)

loc_1844A:
		jsr	(RandomNumber).l
		andi.b	#$1F,d0
		addi.b	#$40,d0
		move.b	d0,$34(a0)

loc_1845C:
		btst	#0,obStatus(a0)
		beq.s	loc_18474

		move.w	(v_boss_start_x).w,d0
		subi.w	#$E0,d0
		move.w	obBossBufferX(a0),d1
		cmp.w	d0,d1
;		cmpi.w	#$1910,obBossBufferX(a0)

		blt.s	locret_1849C
		move.w	d0,obBossBufferX(a0)
		bra.s	loc_18482
; ===========================================================================

loc_18474:
		move.w	(v_boss_start_x).w,d0
		subi.w	#$1C0,d0
		move.w	obBossBufferX(a0),d1
		cmp.w	d0,d1
;		cmpi.w	#$1830,obBossBufferX(a0)
		bgt.s	locret_1849C
		move.w	d0,obBossBufferX(a0)

loc_18482:
		clr.w	obVelX(a0)
		move.w	#-$180,obVelY(a0)
		move.w	(v_boss_start_y).w,d0
		move.w	obBossBufferY(a0),d1
		cmp.w	d0,d1
;		cmpi.w	#$22C,obBossBufferY(a0)
		bcc.s	loc_18498
		neg.w	obVelY(a0)

loc_18498:
		addq.b	#2,obSubtype(a0)

locret_1849C:
		rts	
; ===========================================================================

Obj73_MakeLava2:
		bsr.w	BossMove
		move.w	obBossBufferY(a0),d0
		move.w	(v_boss_start_y).w,d1
		sub.w	d1,d0
		bgt.s	locret_184F4
		move.w	d1,d0
		tst.w	obVelY(a0)
		beq.s	loc_184EA
		clr.w	obVelY(a0)
		move.w	#$50,obBossDelayTimer(a0)
		bchg	#0,obStatus(a0)
		jsr		(FindFreeObj).l
		bne.s	loc_184EA
		move.w	obBossBufferX(a0),obX(a1)
		move.w	obBossBufferY(a0),obY(a1)
		addi.w	#$18,obY(a1)
		move.b	#id_BossFire,obID(a1)	; load lava ball object
		move.b	#1,obSubtype(a1)

loc_184EA:
		subq.w	#1,obBossDelayTimer(a0)
		bne.s	locret_184F4
		addq.b	#2,obSubtype(a0)

locret_184F4:
		rts	
; ===========================================================================

BMZ_ShipExplode:
		subq.w	#1,obBossDelayTimer(a0)
		bmi.s	loc_18500
		bra.w	BossDefeated
; ===========================================================================

loc_18500:
		bset	#staFacing,obStatus(a0)
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		addq.b	#2,ob2ndRout(a0)
		move.w	#-$26,obBossDelayTimer(a0)
		tst.b	(v_bossstatus).w
		bne.s	locret_1852A
		move.b	#1,(v_bossstatus).w
		clr.w	obVelY(a0)

locret_1852A:
		rts	
; ===========================================================================

BMZ_AfterExplosions:
		addq.w	#1,obBossDelayTimer(a0)
		beq.s	loc_18544
		bpl.s	loc_1854E

		move.w	(v_boss_start_y).w,d0
		addi.w	#$44,d0
		move.w	obBossBufferY(a0),d1
		cmp.w	d0,d1
;		cmpi.w	#$270,obBossBufferY(a0)

		bcc.s	loc_18544
		addi.w	#$18,obVelY(a0)
		bra.s	loc_1857A
; ===========================================================================

loc_18544:
		clr.w	obVelY(a0)
		clr.w	obBossDelayTimer(a0)
		bra.s	loc_1857A
; ===========================================================================

loc_1854E:
		cmpi.w	#$30,obBossDelayTimer(a0)
		bcs.s	loc_18566
		beq.s	loc_1856C
		cmpi.w	#$38,obBossDelayTimer(a0)
		bcs.s	loc_1857A
		addq.b	#2,ob2ndRout(a0)
		bra.s	loc_1857A
; ===========================================================================

loc_18566:
		subq.w	#8,obVelY(a0)
		bra.s	loc_1857A
; ===========================================================================

loc_1856C:
		clr.w	obVelY(a0)
		music	bgm_MZ,0,0,0		; play MZ music

loc_1857A:
		bsr.w	BossMove
		bra.w	loc_1833E
; ===========================================================================

BMZ_Retreat:
;		move.b	#$F,obColType(a0)			; make the boss vulnerable to damage again
		move.w	#$500,obVelX(a0)
		move.w	#-$40,obVelY(a0)

		move.w	(v_boss_start_x).w,d0
		subi.w	#$90,d0
		move.w	(v_limitright2).w,d1
		cmp.w	d0,d1

;		cmpi.w	#$1960,(v_limitright2).w
		bcc.s	loc_1859C
		addq.w	#2,(v_limitright2).w
		bra.s	loc_185A2
; ===========================================================================

loc_1859C:
		tst.b	obRender(a0)
		bpl.s	Obj73_ShipDel

loc_185A2:
		bsr.w	BossMove
		bra.w	loc_1833E
; ===========================================================================

Obj73_ShipDel:
		addq.l	#4,sp
		jmp		(DeleteObject).l
; ===========================================================================

Obj73_FaceMain:	; Routine 4
		moveq	#0,d0
		moveq	#1,d1
		movea.l	$34(a0),a1
		move.b	ob2ndRout(a1),d0
		subq.w	#2,d0
		bne.s	loc_185D2
		btst	#1,obSubtype(a1)
		beq.s	loc_185DA
		tst.w	obVelY(a1)
		bne.s	loc_185DA
		moveq	#4,d1
		bra.s	loc_185EE
; ===========================================================================

loc_185D2:
		subq.b	#2,d0
		bmi.s	loc_185DA
		moveq	#$A,d1
		bra.s	loc_185EE
; ===========================================================================

loc_185DA:
		tst.b	obColType(a1)
		bne.s	loc_185E4
		moveq	#5,d1
		bra.s	loc_185EE
; ===========================================================================

loc_185E4:
		cmpi.b	#4,(v_player+obRoutine).w
		bcs.s	loc_185EE
		moveq	#4,d1

loc_185EE:
		move.b	d1,obAnim(a0)
		subq.b	#4,d0
		bne.s	loc_18602
		move.b	#6,obAnim(a0)
		tst.b	obRender(a0)
		bpl.s	Obj73_FaceDel

loc_18602:
		bra.s	Obj73_Display
; ===========================================================================

Obj73_FaceDel:
		jmp	(DeleteObject).l
; ===========================================================================

Obj73_FlameMain:; Routine 6
		move.b	#7,obAnim(a0)
		movea.l	$34(a0),a1
		cmpi.b	#8,ob2ndRout(a1)
		blt.s	loc_1862A
		move.b	#$B,obAnim(a0)
		tst.b	obRender(a0)
		bpl.s	Obj73_FlameDel
		bra.s	loc_18636
; ===========================================================================

loc_1862A:
		tst.w	obVelX(a1)
		beq.s	loc_18636
		move.b	#8,obAnim(a0)

loc_18636:
		bra.s	Obj73_Display
; ===========================================================================

Obj73_FlameDel:
		jmp	(DeleteObject).l
; ===========================================================================

Obj73_Display:
		lea	(Ani_Eggman).l,a1
		jsr	(AnimateSprite).l

loc_1864A:
		movea.l	$34(a0),a1
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		moveq	#3,d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp	(DisplaySprite).l
; ===========================================================================

Obj73_TubeMain:	; Routine 8
		movea.l	$34(a0),a1
		cmpi.b	#8,ob2ndRout(a1)
		bne.s	loc_18688
		tst.b	obRender(a0)
		bpl.s	Obj73_TubeDel

loc_18688:
		move.l	#Map_BossItems,obMap(a0)
		move.w	#ArtNem_Weapons,obGfx(a0)
		move.b	#4,obFrame(a0)
		bra.s	loc_1864A
; ===========================================================================

Obj73_TubeDel:
		jmp	(DeleteObject).l
