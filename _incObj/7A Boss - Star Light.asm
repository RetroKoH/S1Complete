; ---------------------------------------------------------------------------
; Object 7A - Eggman (SLZ)
; ---------------------------------------------------------------------------



BossStarLight:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj7A_Index(pc,d0.w),d1
		jmp	Obj7A_Index(pc,d1.w)
; ===========================================================================
Obj7A_Index:
		dc.w Obj7A_Init-Obj7A_Index
		dc.w Obj7A_ShipMain-Obj7A_Index
		dc.w Obj7A_FaceMain-Obj7A_Index
		dc.w Obj7A_FlameMain-Obj7A_Index
		dc.w Obj7A_TubeMain-Obj7A_Index

Obj7A_ObjData:		; routine number, animation, priority
		dc.b 2,	0, 4
		dc.b 4,	1, 4
		dc.b 6,	7, 4
		dc.b 8,	0, 3
; ===========================================================================

Obj7A_Init:
		move.w	obX(a0),obBossBufferX(a0)	; set starting x-pos to $30
		move.w	obX(a0),(v_boss_start_x).w	; new variable for positioning purposes between layouts (Difficulties, Boss Rush, etc.)
		move.w	obY(a0),obBossBufferY(a0)	; set starting y-pos to $38
		move.w	obY(a0),(v_boss_start_y).w	; new variable for positioning purposes between layouts (Difficulties, Boss Rush, etc.)
		move.b	#$F,obColType(a0)
		move.b	#8,obColProp(a0)	; set number of hits to 8
		cmpi.b	#difEasy,(v_difficulty).w
		bne.s	@notEasy
		move.b	#6,obColProp(a0)	; set number of hits to 6 for Easy Mode

	@notEasy:
		lea		Obj7A_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj7A_LoadBoss
; ===========================================================================

Obj7A_Loop:
		jsr		(FindNextFreeObj).l
		bne.s	loc_1895C
		move.b	#id_BossStarLight,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

Obj7A_LoadBoss:
		bclr	#0,obStatus(a0)
		clr.b	ob2ndRout(a1)
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,obAnim(a1)
		move.b	(a2)+,obPriority(a1)

		move.w  obPriority(a1),d0
		lsr.w   #1,d0
		andi.w  #$380,d0
		move.w  d0,obPriority(a1)

		move.l	#Map_Eggman,obMap(a1)
		move.w	#ArtNem_Eggman,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.l	a0,$34(a1)
		dbf		d1,Obj7A_Loop	; repeat sequence 3 more times

loc_1895C:
		lea		(v_objspace+$40).w,a1
		lea		$2A(a0),a2
		moveq	#id_Seesaw,d0	; search for Seesaw object
		moveq	#$3E,d1			; # of times to loop

loc_18968:
		cmp.b	(a1),d0
		bne.s	loc_18974
		tst.b	obSubtype(a1)
		beq.s	loc_18974
		move.w	a1,(a2)+

loc_18974:
		adda.w	#$40,a1
		dbf		d1,loc_18968

Obj7A_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj7A_ShipIndex(pc,d0.w),d0
		jsr		Obj7A_ShipIndex(pc,d0.w)
		lea		(Ani_Eggman).l,a1
		jsr		(AnimateSprite).l
		moveq	#3,d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplaySprite).l
; ===========================================================================
Obj7A_ShipIndex:
		dc.w BSLZ_ShipStart-Obj7A_ShipIndex
		dc.w Obj7A_ShipMove-Obj7A_ShipIndex
		dc.w Obj7A_MakeBall-Obj7A_ShipIndex
		dc.w BSLZ_ShipExplode-Obj7A_ShipIndex
		dc.w BSLZ_AfterExplosions-Obj7A_ShipIndex
		dc.w BSLZ_Retreat-Obj7A_ShipIndex
; ===========================================================================

BSLZ_ShipStart:
		move.w	#-$100,obVelX(a0)			; move ship left

		move.w	(v_boss_start_x).w,d0
		subi.w	#$68,d0
		move.w	obBossBufferX(a0),d1
		cmp.w	d0,d1
;		cmpi.w	#$2120,obBossBufferX(a0)

		bcc.s	loc_189CA
		addq.b	#2,ob2ndRout(a0)

loc_189CA:
		bsr.w	BossMove
		move.b	obBossHoverValue(a0),d0
		addq.b	#2,obBossHoverValue(a0)
		jsr		(CalcSine).l
		asr.w	#6,d0
		add.w	obBossBufferY(a0),d0
		move.w	d0,obY(a0)
		move.w	obBossBufferX(a0),obX(a0)
		bra.s	loc_189FE
; ===========================================================================

loc_189EE:
		bsr.w	BossMove
		move.w	obBossBufferY(a0),obY(a0)
		move.w	obBossBufferX(a0),obX(a0)

loc_189FE:
		cmpi.b	#6,ob2ndRout(a0)
		bcc.s	locret_18A44
		tst.b	obStatus(a0)
		bmi.s	BSLZ_Defeat
		tst.b	obColType(a0)
		bne.s	locret_18A44
		tst.b	obBossFlashTime(a0)
		bne.s	loc_18A28
		move.b	#$20,obBossFlashTime(a0)
		sfx		sfx_HitBoss,0,0,0	; play boss damage sound

loc_18A28:
		lea		(v_pal_dry+$22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	loc_18A36
		move.w	#cWhite,d0

loc_18A36:
		move.w	d0,(a1)
		subq.b	#1,obBossFlashTime(a0)
		bne.s	locret_18A44
		move.b	#$F,obColType(a0)

locret_18A44:
		rts	
; ===========================================================================

BSLZ_Defeat:
		cmpi.b	#difHard,(v_difficulty).w
		bne.s	@noPinchMode
		tst.b	obSLZBossPinchMode(a0)
		bne.s	@noPinchMode
		bclr	#7,obStatus(a0)
		bset	#0,obSLZBossPinchMode(a0)
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
		move.b	#6,ob2ndRout(a0)
		move.b	#$78,obBossDelayTimer(a0)
		clr.w	obVelX(a0)
		rts	
; ===========================================================================

Obj7A_ShipMove:
		move.w	obBossBufferX(a0),d0
		move.w	#$200,obVelX(a0)
		btst	#0,obStatus(a0)
		bne.s	loc_18A7C
		neg.w	obVelX(a0)

		move.w	(v_boss_start_x).w,d1
		subi.w	#$180,d1
		cmp.w	d1,d0
;		cmpi.w	#$2008,d0

		bgt.s	loc_18A88
		bra.s	loc_18A82
; ===========================================================================

loc_18A7C:
		move.w	(v_boss_start_x).w,d1
		subi.w	#$50,d1
		cmp.w	d1,d0
;		cmpi.w	#$2138,d0
		blt.s	loc_18A88

loc_18A82:
		bchg	#0,obStatus(a0)

loc_18A88:
		move.w	obX(a0),d0
		moveq	#-1,d1
		moveq	#2,d2
		lea		$2A(a0),a2
		moveq	#$28,d4
		tst.w	obVelX(a0)
		bpl.s	loc_18A9E
		neg.w	d4

loc_18A9E:
		move.w	(a2)+,d1
		movea.l	d1,a3
		btst	#3,obStatus(a3)
		bne.s	loc_18AB4
		move.w	8(a3),d3
		add.w	d4,d3
		sub.w	d0,d3
		beq.s	loc_18AC0

loc_18AB4:
		dbf		d2,loc_18A9E

		move.b	d2,obSubtype(a0)
		bra.w	loc_189CA
; ===========================================================================

loc_18AC0:
		move.b	d2,obSubtype(a0)
		addq.b	#2,ob2ndRout(a0)
		move.b	#$28,obBossDelayTimer(a0)
		bra.w	loc_189CA
; ===========================================================================

Obj7A_MakeBall:
		cmpi.b	#$28,obBossDelayTimer(a0)
		bne.s	loc_18B36
		moveq	#-1,d0
		move.b	obSubtype(a0),d0
		ext.w	d0
		bmi.s	loc_18B40
		subq.w	#2,d0
		neg.w	d0
		add.w	d0,d0
		lea		$2A(a0),a1
		move.w	(a1,d0.w),d0
		movea.l	d0,a2
		lea		(v_objspace+$40).w,a1
		moveq	#$3E,d1

loc_18AFA:
		cmp.l	$3C(a1),d0
		beq.s	loc_18B40
		adda.w	#$40,a1
		dbf		d1,loc_18AFA

		move.l	a0,-(sp)
		lea		(a2),a0
		jsr		(FindNextFreeObj).l
		movea.l	(sp)+,a0
		bne.s	loc_18B40
		move.b	#id_BossSpikeball,obID(a1) ; load spiked ball object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		addi.w	#$20,obY(a1)
		move.b	obStatus(a2),obStatus(a1)
		move.l	a2,$3C(a1)

loc_18B36:
		subq.b	#1,obBossDelayTimer(a0)
		beq.s	loc_18B40
		bra.w	loc_189FE
; ===========================================================================

loc_18B40:
		subq.b	#2,ob2ndRout(a0)
		bra.w	loc_189CA
; ===========================================================================

BSLZ_ShipExplode:
		subq.b	#1,obBossDelayTimer(a0)
		bmi.s	loc_18B52
		bra.w	BossDefeated
; ===========================================================================

loc_18B52:
		addq.b	#2,ob2ndRout(a0)
		clr.w	obVelY(a0)
		bset	#0,obStatus(a0)
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		move.b	#-$18,$3C(a0)
		tst.b	(v_bossstatus).w
		bne.s	loc_18B7C
		move.b	#1,(v_bossstatus).w

loc_18B7C:
		bra.w	loc_189FE
; ===========================================================================

BSLZ_AfterExplosions:
		addq.b	#1,obBossDelayTimer(a0)
		beq.s	loc_18B90
		bpl.s	loc_18B96
		addi.w	#$18,obVelY(a0)
		bra.s	loc_18BC2
; ===========================================================================

loc_18B90:
		clr.w	obVelY(a0)
		bra.s	loc_18BC2
; ===========================================================================

loc_18B96:
		cmpi.b	#$20,obBossDelayTimer(a0)
		bcs.s	loc_18BAE
		beq.s	loc_18BB4
		cmpi.b	#$2A,obBossDelayTimer(a0)
		bcs.s	loc_18BC2
		addq.b	#2,ob2ndRout(a0)
		bra.s	loc_18BC2
; ===========================================================================

loc_18BAE:
		subq.w	#8,obVelY(a0)
		bra.s	loc_18BC2
; ===========================================================================

loc_18BB4:
		clr.w	obVelY(a0)
		music	bgm_SLZ,0,0,0		; play SLZ music

loc_18BC2:
		bra.w	loc_189EE
; ===========================================================================

BSLZ_Retreat:
;		move.b	#$F,obColType(a0)			; make the boss vulnerable to damage again
		move.w	#$400,obVelX(a0)
		move.w	#-$40,obVelY(a0)

		move.w	(v_boss_start_x).w,d0
		subi.w	#$28,d0
		move.w	(v_limitright2).w,d1
		cmp.w	d0,d1						; limitright2 should advance only $60 pixels ahead
;		cmpi.w	#$2160,(v_limitright2).w

		bcc.s	loc_18BE0
		addq.w	#2,(v_limitright2).w
		bra.s	loc_18BE8
; ===========================================================================

loc_18BE0:
		tst.b	obRender(a0)
		bmi.w   loc_18BE8
		addq.l  #4,sp
		bra.w   Obj7A_Delete

loc_18BE8:
		bsr.w	BossMove
		bra.w	loc_189CA
; ===========================================================================

Obj7A_FaceMain:	; Routine 4
		moveq	#0,d0
		moveq	#1,d1
		movea.l	$34(a0),a1
		move.b	ob2ndRout(a1),d0
		cmpi.b	#6,d0
		bmi.s	loc_18C06
		moveq	#$A,d1
		bra.s	loc_18C1A
; ===========================================================================

loc_18C06:
		tst.b	obColType(a1)
		bne.s	loc_18C10
		moveq	#5,d1
		bra.s	loc_18C1A
; ===========================================================================

loc_18C10:
		cmpi.b	#4,(v_player+obRoutine).w
		bcs.s	loc_18C1A
		moveq	#4,d1

loc_18C1A:
		move.b	d1,obAnim(a0)
		cmpi.b	#$A,d0
		bne.s	loc_18C32
		move.b	#6,obAnim(a0)
		tst.b	obRender(a0)
		bpl.w	Obj7A_Delete

loc_18C32:
		bra.s	loc_18C6C
; ===========================================================================

Obj7A_FlameMain:; Routine 6
		move.b	#8,obAnim(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$A,ob2ndRout(a1)
		bne.s	loc_18C56
		tst.b	obRender(a0)
		bpl.w	Obj7A_Delete
		move.b	#$B,obAnim(a0)
		bra.s	loc_18C6C
; ===========================================================================

loc_18C56:
		cmpi.b	#8,ob2ndRout(a1)
		bgt.s	loc_18C6C
		cmpi.b	#4,ob2ndRout(a1)
		blt.s	loc_18C6C
		move.b	#7,obAnim(a0)

loc_18C6C:
		lea	(Ani_Eggman).l,a1
		jsr	(AnimateSprite).l

loc_18C78:
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

Obj7A_TubeMain:	; Routine 8
		movea.l	$34(a0),a1
		cmpi.b	#$A,ob2ndRout(a1)
		bne.s	loc_18CB8
		tst.b	obRender(a0)
		bpl.s	Obj7A_Delete

loc_18CB8:
		move.l	#Map_BossItems,obMap(a0)
		move.w	#ArtNem_Weapons,obGfx(a0)
		move.b	#3,obFrame(a0)
		bra.s	loc_18C78
; ===========================================================================

Obj7A_Delete:
		jmp	(DeleteObject).l