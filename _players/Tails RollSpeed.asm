; ---------------------------------------------------------------------------
; Subroutine to	change Tails's speed as he rolls
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Tails_RollSpeed:
		move.w	(v_sonspeedmax).w,d6
		asl.w	#1,d6
		move.w	(v_sonspeedacc).w,d5
		asr.w	#1,d5
		move.w	(v_sonspeeddec).w,d4
		asr.w	#2,d4
		tst.b	(f_jumponly).w
		bne.w	@131CC
		tst.w	obLRLock(a0)
		bne.s	@notright
		btst	#bitL,(v_jpadhold2).w	; is left being pressed?
		beq.s	@notleft				; if not, branch
		bsr.w	Tails_RollLeft

	@notleft:
		btst	#bitR,(v_jpadhold2).w	; is right being pressed?
		beq.s	@notright				; if not, branch
		bsr.w	Tails_RollRight

	@notright:
		move.w	obInertia(a0),d0
		beq.s	@131AA
		bmi.s	@1319E
		sub.w	d5,d0
		bcc.s	@13198
		move.w	#0,d0

@13198:
		move.w	d0,obInertia(a0)
		bra.s	@131AA
; ===========================================================================

@1319E:
		add.w	d5,d0
		bcc.s	@131A6
		move.w	#0,d0

@131A6:
		move.w	d0,obInertia(a0)

@131AA:
		tst.w	obInertia(a0)	; is Tails moving?
		bne.s	@131CC	; if yes, branch
		bclr	#staSpin,obStatus(a0)
		move.b	#$F,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#aniID_Wait,obAnim(a0) ; use "standing" animation
		subq.w	#1,obY(a0)

	@131CC:
		cmp.w	#$60,(v_lookshift).w
		beq.s	@cont2
		bcc.s	@cont1
		addq.w	#4,(v_lookshift).w

	@cont1:
		subq.w	#2,(v_lookshift).w

	@cont2:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		cmpi.w	#$1000,d1
		ble.s	@131F0
		move.w	#$1000,d1

	@131F0:
		cmpi.w	#-$1000,d1
		bge.s	@131FA
		move.w	#-$1000,d1

	@131FA:
		move.w	d1,obVelX(a0)
		bra.w	Player_CheckWallsOnGround
; End of function Tails_RollSpeed


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Tails_RollLeft:
		move.w	obInertia(a0),d0
		beq.s	@1320A
		bpl.s	@13218

	@1320A:
		bset	#staFacing,obStatus(a0)
		move.b	#aniID_Roll,obAnim(a0) ; use "rolling" animation
		rts	
; ===========================================================================

	@13218:
		sub.w	d4,d0
		bcc.s	@13220
		clr.w	d0

	@13220:
		move.w	d0,obInertia(a0)
		rts	
; End of function Tails_RollLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Tails_RollRight:
		move.w	obInertia(a0),d0
		bmi.s	@1323A
		bclr	#staFacing,obStatus(a0)
		move.b	#aniID_Roll,obAnim(a0) ; use "rolling" animation
		rts	
; ===========================================================================

	@1323A:
		add.w	d4,d0
		bcc.s	@13242
		clr.w	d0

	@13242:
		move.w	d0,obInertia(a0)
		rts	
; End of function Tails_RollRight
