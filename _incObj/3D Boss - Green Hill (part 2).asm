
BGHZ_MakeBall: 	; Sub-Routine 0
		move.w	#-$100,obVelX(a0)
		move.w	#-$40,obVelY(a0)
		bsr.w	BossMove

		move.w	(v_boss_start_x).w,d0
		subi.w	#$60,d0
		move.w	obBossBufferX(a0),d1
		cmp.w	d0,d1						; has Eggman reached the center of the arena? 

		bne.w	loc_177E6					; if not, branch
		clr.w	obVelX(a0)
		clr.w	obVelY(a0)					; stop all movement
		addq.b	#2,ob2ndRout(a0)			; BGHZ_ShipMove
		jsr		(FindNextFreeObj).l
		bne.s	loc_17910
		move.b	#id_BossBall,obID(a1)		; load swinging ball object
		move.w	obBossBufferX(a0),obX(a1)
		move.w	obBossBufferY(a0),obY(a1)
		move.l	a0,obBossParent(a1)			; Swinging Ball's parent = Eggman's ship (a0)

loc_17910:
		move.w	#$77,obBossDelayTimer(a0)	; it takes $77 frames for Eggman's ball to lower
		bra.w	loc_177E6
; ===========================================================================

BGHZ_ShipSetDirection:	; Sub-Routine 4
		subq.w	#1,obBossDelayTimer(a0)		; decrement delay timer
		bpl.s	BGHZ_Reverse
		addq.b	#2,ob2ndRout(a0)			; BGHZ_ShipMove
		move.w	#$3F,obBossDelayTimer(a0)	; Eggman moves for $3F frames again after turning
		move.w	#$100,obVelX(a0)			; move the ship sideways

		move.w	(v_boss_start_x).w,d0
		subi.w	#$60,d0
		move.w	obBossBufferX(a0),d1
		cmp.w	d0,d1						; has Eggman reached the center of the arena? 

		bne.s	BGHZ_Reverse				; if not, branch
		move.w	#$7F,obBossDelayTimer(a0)	; Eggman takes more time to move...
		move.w	#$40,obVelX(a0)				; ...and moves slower

BGHZ_Reverse:
		btst	#staFacing,obStatus(a0)		; is Eggman facing to the right?
		bne.w	loc_177E6					; if yes, branch
		neg.w	obVelX(a0)					; reverse direction of the ship
		bra.w	loc_177E6
; ===========================================================================

BGHZ_ShipMove:	; Sub-Routine 6
		subq.w	#1,obBossDelayTimer(a0)
		bmi.s	BGHZ_TurnAround
		bsr.w	BossMove
		bra.w	loc_177E6
; ===========================================================================

BGHZ_TurnAround:
		bchg	#staFacing,obStatus(a0)
		move.w	#$3F,obBossDelayTimer(a0)
		subq.b	#2,ob2ndRout(a0)			; BGHZ_ShipSetDirection
		clr.w	obVelX(a0)
		bra.w	loc_177E6
; ===========================================================================

BGHZ_ShipExplode:	; Sub-Routine 8
		subq.w	#1,obBossDelayTimer(a0)
		bmi.s	loc_17984
		bra.w	BossDefeated
; ===========================================================================

loc_17984:
		bset	#staFacing,obStatus(a0)		; Set Eggman to face right
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		addq.b	#2,ob2ndRout(a0)			; BGHZ_AfterExplosions
		move.w	#-$26,obBossDelayTimer(a0)
		tst.b	(v_bossstatus).w
		bne.s	locret_179AA
		move.b	#1,(v_bossstatus).w

locret_179AA:
		rts	
; ===========================================================================

BGHZ_AfterExplosions:	; Sub-Routine A
		addq.w	#1,obBossDelayTimer(a0)
		beq.s	loc_179BC
		bpl.s	loc_179C2
		addi.w	#$18,obVelY(a0)
		bra.s	loc_179EE
; ===========================================================================

loc_179BC:
		clr.w	obVelY(a0)
		bra.s	loc_179EE
; ===========================================================================

loc_179C2:
		cmpi.w	#$30,obBossDelayTimer(a0)
		bcs.s	loc_179DA
		beq.s	loc_179E0
		cmpi.w	#$38,obBossDelayTimer(a0)
		bcs.s	loc_179EE
		addq.b	#2,ob2ndRout(a0)			; BGHZ_Retreat
		bra.s	loc_179EE
; ===========================================================================

loc_179DA:
		subq.w	#8,obVelY(a0)
		bra.s	loc_179EE
; ===========================================================================

loc_179E0:
		clr.w	obVelY(a0)
		music	bgm_GHZ,0,0,0		; play GHZ music

loc_179EE:
		bsr.w	BossMove
		bra.w	loc_177E6
; ===========================================================================

BGHZ_Retreat:	; Sub-Routine C
;		move.b	#$F,obColType(a0)			; make the boss vulnerable to damage again
		move.w	#$400,obVelX(a0)
		move.w	#-$40,obVelY(a0)

		move.w	(v_boss_start_x).w,d0
		addi.w	#$60,d0
		move.w	(v_limitright2).w,d1
		cmp.w	d0,d1						; limitright2 should advance only $60 pixels ahead

		beq.s	loc_17A10
		addq.w	#2,(v_limitright2).w
		bra.s	loc_17A16
; ===========================================================================

loc_17A10:
		tst.b	obRender(a0)
		bpl.s	BGHZ_ShipDel

loc_17A16:
		bsr.w	BossMove
		bra.w	loc_177E6
; ===========================================================================

BGHZ_ShipDel:
		addq.l	#4,sp
		jmp		(DeleteObject).l
; ===========================================================================

BGHZ_FaceMain:	; Routine 4
		moveq	#0,d0
		moveq	#1,d1
		movea.l	obBossParent(a0),a1
		move.b	ob2ndRout(a1),d0
		subq.b	#4,d0
		bne.s	loc_17A3E

		move.w	(v_boss_start_x).w,d2
		subi.w	#$60,d2
		move.w	obBossBufferX(a1),d3
		cmp.w	d2,d3						; has Eggman reached the center of the arena? 

		bne.s	loc_17A46
		moveq	#4,d1

loc_17A3E:
		subq.b	#6,d0
		bmi.s	loc_17A46
		moveq	#$A,d1
		bra.s	loc_17A5A
; ===========================================================================

loc_17A46:
		tst.b	obColType(a1)
		bne.s	loc_17A50
		moveq	#5,d1
		bra.s	loc_17A5A
; ===========================================================================

loc_17A50:
		cmpi.b	#4,(v_player+obRoutine).w
		bcs.s	loc_17A5A
		moveq	#4,d1

loc_17A5A:
		move.b	d1,obAnim(a0)
		subq.b	#2,d0
		bne.s	BGHZ_FaceDisp
		move.b	#6,obAnim(a0)
		tst.b	obRender(a0)
		bpl.s	BGHZ_FaceDel

BGHZ_FaceDisp:
		bra.s	BGHZ_Display
; ===========================================================================

BGHZ_FaceDel:
		jmp		(DeleteObject).l
; ===========================================================================

BGHZ_FlameMain:	; Routine 6
		move.b	#7,obAnim(a0)
		movea.l	obBossParent(a0),a1
		cmpi.b	#$C,ob2ndRout(a1)
		bne.s	loc_17A96
		move.b	#$B,obAnim(a0)
		tst.b	obRender(a0)
		bpl.s	BGHZ_FlameDel
		bra.s	BGHZ_FlameDisp
; ===========================================================================

loc_17A96:
		move.w	obVelX(a1),d0
		beq.s	BGHZ_FlameDisp
		move.b	#8,obAnim(a0)

BGHZ_FlameDisp:
		bra.s	BGHZ_Display
; ===========================================================================

BGHZ_FlameDel:
		jmp		(DeleteObject).l
; ===========================================================================

BGHZ_Display:
		movea.l	obBossParent(a0),a1
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		lea		(Ani_Eggman).l,a1
		jsr		(AnimateSprite).l
		move.b	obStatus(a0),d0
		andi.b	#3,d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplaySprite).l
