; ---------------------------------------------------------------------------
; Object 8E - Eggman (LZ - 8-bit)
; ---------------------------------------------------------------------------

BossLabyrinth2:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj8E_Index(pc,d0.w),d1
		jmp		Obj8E_Index(pc,d1.w)
; ===========================================================================
Obj8E_Index:
		dc.w Obj8E_Main-Obj8E_Index
		dc.w Obj8E_ShipMain-Obj8E_Index
		dc.w Obj8E_FaceMain-Obj8E_Index

Obj8E_ObjData:	; routine number, animation
				; priority
		; Ship
		dc.b 2,	0
		dc.w $200
		; Face
		dc.b 4, 1
		dc.w $200
; ===========================================================================

Obj8E_Main:	; Routine 0
		move.w	obX(a0),obBossBufferX(a0)
		move.w	obX(a0),(v_boss_start_x).w	; new variable for positioning purposes between layouts (Difficulties, Boss Rush, etc.)
		move.w	obY(a0),obBossBufferY(a0)
		move.w	obY(a0),(v_boss_start_y).w	; new variable for positioning purposes between layouts (Difficulties, Boss Rush, etc.)

		; Temporarily put Ship Data up here
		move.b	#2,obRoutine(a0)
		move.b	#0,obAnim(a0)
		move.w	#$200,obPriority(a0)
		move.l	#Map_EggmanAlt,obMap(a0)
		move.w	#ArtNem_Eggman,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$20,obActWid(a0)

		move.b	#$F,obColType(a0)
		move.b	#8,obColProp(a0) ; set number of hits to 8
		cmpi.b	#difEasy,(v_difficulty).w
		bne.s	Obj8E_ShipMain;@notEasy
		move.b	#6,obColProp(a0)			; set number of hits to 6 for Easy Mode
;	@notEasy:
;		lea		Obj8E_ObjData(pc),a2
;		movea.l	a0,a1
;		moveq	#3,d1
;		bra.s	Obj8E_LoadBoss
; ===========================================================================

;Obj8E_Loop:
;		jsr		(FindNextFreeObj).l
;		bne.s	Obj8E_ShipMain
;		move.b	#id_BossLZ2,obID(a1)
;		move.w	obX(a0),obX(a1)
;		move.w	obY(a0),obY(a1)

;Obj8E_LoadBoss:
;		bclr	#staFacing,obStatus(a0)
;		clr.b	ob2ndRout(a1)
;		move.b	(a2)+,obRoutine(a1)
;		move.b	(a2)+,obAnim(a1)
;		move.w	(a2)+,obPriority(a1)
;		move.l	#Map_Eggman,obMap(a1)
;		move.w	#ArtNem_Eggman,obGfx(a1)
;		move.b	#4,obRender(a1)
;		move.b	#$20,obActWid(a1)
;		move.l	a0,obBossParent(a1)
;		dbf		d1,Obj8E_Loop	; repeat sequence 3 more times

Obj8E_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Obj8E_ShipIndex(pc,d0.w),d1
		jsr		Obj8E_ShipIndex(pc,d1.w)
		lea		(Ani_Eggman).l,a1
		jsr		(AnimateSprite).l
		moveq	#3,d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplaySprite).l
; ===========================================================================
Obj8E_ShipIndex:
					dc.w BLZ2_ShipStart-Obj8E_ShipIndex
					dc.w BLZ2_ShipMain-Obj8E_ShipIndex
ptr_BLZ2_Defeat:	dc.w BLZ2_ShipExplode-Obj8E_ShipIndex
					dc.w BLZ2_AfterExplosions-Obj8E_ShipIndex
					dc.w BLZ2_Retreat-Obj8E_ShipIndex

id_BLZ2Defeated: 	equ ptr_BLZ2_Defeat-Obj8E_ShipIndex
; ===========================================================================

BLZ2_ShipStart:
		move.w	#-$100,obVelY(a0)		; Move boss upward
		bsr.w	BossMove
		move.w	(v_boss_start_y).w,d0
		subi.w	#$48,d0
		move.w	obBossBufferY(a0),d1
		cmp.w	d0,d1					; has boss moved up $48 pixels?
		bne.s	BLZ2_AllRoutines				; if not, branch
		addq.b	#2,ob2ndRout(a0)
		clr.l	obVelY(a0)				; stop moving upward

BLZ2_AllRoutines:
		move.w	obBossBufferY(a0),obY(a0)
		move.w	obBossBufferX(a0),obX(a0)

		cmpi.b	#id_BLZ2Defeated,ob2ndRout(a0)	; Has Eggman already been defeated?
		bcc.s	BLZ2_FlashRet					; if yes, branch
		tst.b	obStatus(a0)					; Did Eggman take the final hit?
		bmi.s	BLZ2_Defeat						; if yes, branch to adding points and setting routine
		tst.b	obColType(a0)					; can the boss be hit?
		bne.s	BLZ2_FlashRet					; if yes, branch
		tst.b	obBossFlashTime(a0)				; if not, is the boss flashing?
		bne.s	BLZ2_ShipFlash					; if yes, branch
		move.b	#$24,obBossFlashTime(a0)		; set number of	frames for ship to flash
		sfx		sfx_HitBoss,0,0,0				; play boss damage sound

BLZ2_ShipFlash:
		lea		(v_pal_dry+$22).w,a1		; load 2nd pallet, 2nd entry
		moveq	#0,d0						; move 0 (black) to d0
		tst.w	(a1)
		bne.s	BLZ2_SetColor
		move.w	#cWhite,d0					; move 0EEE (white) to d0

BLZ2_SetColor:
		move.w	d0,(a1)						; load colour stored in	d0
		subq.b	#1,obBossFlashTime(a0)		; decrement flash timer
		bne.s	BLZ2_FlashRet				; if time remains, branch
		move.b	#$F,obColType(a0)			; otherwise, make the boss vulnerable to damage again

BLZ2_FlashRet:
		rts	
; ===========================================================================

BLZ2_Defeat:
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

BLZ2_ShipMain:
; Start this routine in the bottom center.
		bra.w	BLZ2_AllRoutines
		rts

BLZ2_ShipExplode:
		subq.w	#1,obBossDelayTimer(a0)
		bmi.s	@notDefeated
		bra.w	BossDefeated
; ===========================================================================

	@notDefeated:
		bset	#staFacing,obStatus(a0)
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		addq.b	#2,ob2ndRout(a0)
		move.w	#-$26,obBossDelayTimer(a0)
		tst.b	(v_bossstatus).w
		bne.s	@end
		move.b	#1,(v_bossstatus).w
		clr.w	obVelY(a0)

	@end:
		rts	
; ===========================================================================

BLZ2_AfterExplosions:
		addq.w	#1,obBossDelayTimer(a0)
		beq.s	@stopYSpd
		bpl.s	@chkTimer

		move.w	(v_boss_start_y).w,d0
		addi.w	#$44,d0
		move.w	obBossBufferY(a0),d1
		cmp.w	d0,d1

		bcc.s	@stopYSpd
		addi.w	#$18,obVelY(a0)
		bra.s	@movement
; ===========================================================================

	@stopYSpd:
		clr.w	obVelY(a0)
		clr.w	obBossDelayTimer(a0)
		bra.s	@movement
; ===========================================================================

	@chkTimer:
		cmpi.w	#$30,obBossDelayTimer(a0)
		bcs.s	@moveup
		beq.s	@playMusic
		cmpi.w	#$38,obBossDelayTimer(a0)
		bcs.s	@movement
		addq.b	#2,ob2ndRout(a0)
		bra.s	@movement
; ===========================================================================

	@moveup:
		subq.w	#8,obVelY(a0)
		bra.s	@movement
; ===========================================================================

	@playMusic:
		clr.w	obVelY(a0)
		music	bgm_LZ,0,0,0		; play LZ music

	@movement:
		bsr.w	BossMove
		bra.w	BLZ2_AllRoutines
; ===========================================================================

BLZ2_Retreat: ; Modify this to move up or down based on obSubtype(a0)
		move.w	#$500,obVelX(a0)
		move.w	#-$40,obVelY(a0)

		move.w	(v_boss_start_x).w,d0
		addi.w	#$90,d0
		move.w	(v_limitright2).w,d1
		cmp.w	d0,d1

;		cmpi.w	#$1960,(v_limitright2).w
		bcc.s	@chkRender
		addq.w	#2,(v_limitright2).w
		bra.s	@moveShip
; ===========================================================================

	@chkRender:
		tst.b	obRender(a0)
		bpl.s	Obj8E_ShipDel

	@moveShip:
		bsr.w	BossMove
		bra.w	BLZ2_AllRoutines
; ===========================================================================

Obj8E_ShipDel:
		addq.l	#4,sp
		jmp		(DeleteObject).l
; ===========================================================================

Obj8E_FaceMain:	; Routine 4
		rts