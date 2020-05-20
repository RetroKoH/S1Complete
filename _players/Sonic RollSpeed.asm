; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's speed as he rolls
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollSpeed:
		move.w	(v_sonspeedmax).w,d6
		asl.w	#1,d6
		move.w	(v_sonspeedacc).w,d5
		asr.w	#1,d5
		move.w	(v_sonspeeddec).w,d4
		asr.w	#2,d4
		tst.b	(f_jumponly).w
		bne.w	Sonic_Roll_ResetScr
		tst.w	obLRLock(a0)
		bne.s	@applyrollspeed
		btst	#bitL,(v_jpadhold2).w	; is left being pressed?
		beq.s	@notleft				; if not, branch
		bsr.w	Sonic_RollLeft

	@notleft:
		btst	#bitR,(v_jpadhold2).w	; is right being pressed?
		beq.s	@applyrollspeed			; if not, branch
		bsr.w	Sonic_RollRight

	@applyrollspeed:
		move.w	obInertia(a0),d0
		beq.s	Sonic_CheckRollStop
		bmi.s	Sonic_ApplyRollSpeedLeft
; Sonic_ApplyRollSpeedRight:
		sub.w	d5,d0
		bcc.s	@setInertia
		move.w	#0,d0

	@setInertia:
		move.w	d0,obInertia(a0)
		bra.s	Sonic_CheckRollStop
; ===========================================================================

Sonic_ApplyRollSpeedLeft:
		add.w	d5,d0
		bcc.s	@setInertia
		move.w	#0,d0

	@setInertia:
		move.w	d0,obInertia(a0)

Sonic_CheckRollStop:
		tst.w	obInertia(a0)				; is Sonic moving?
		bne.s	Sonic_Roll_ResetScr			; if yes, branch
		bclr	#staSpin,obStatus(a0)
		move.b	#obPlayerHeight,obHeight(a0)
		move.b	#obPlayerWidth,obWidth(a0)
		move.b	#aniID_Wait,obAnim(a0)		; use "standing" animation
		subq.w	#obPlayerHeight-obBallHeight,obY(a0)

; resets the screen to normal while rolling, like Obj01_ResetScr
Sonic_Roll_ResetScr:
		cmp.w	#$60,(v_lookshift).w
		beq.s	Sonic_SetRollSpeeds
		bcc.s	@cont
		addq.w	#4,(v_lookshift).w

	@cont:
		subq.w	#2,(v_lookshift).w

Sonic_SetRollSpeeds:
		move.b	obAngle(a0),d0
		jsr		(CalcSine).l
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)	; set y velocity based on inertia and angle
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		cmpi.w	#$1000,d1
		ble.s	loc_131F0
		move.w	#$1000,d1	; limit Sonic's speed rolling right

loc_131F0:
		cmpi.w	#-$1000,d1
		bge.s	loc_131FA
		move.w	#-$1000,d1	; limit Sonic's speed rolling left

loc_131FA:
		move.w	d1,obVelX(a0)
		bra.w	Sonic_CheckWallsOnGround
; End of function Sonic_RollSpeed


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollLeft:
		move.w	obInertia(a0),d0
		beq.s	@skip
		bpl.s	Sonic_BrakeRollingRight

	@skip:
		bset	#staFacing,obStatus(a0)
		move.b	#aniID_Roll,obAnim(a0) ; use "rolling" animation
		rts	
; ===========================================================================

Sonic_BrakeRollingRight:
		sub.w	d4,d0		; reduce rightward rolling speed
		bcc.s	@skip
		clr.w	d0

	@skip:
		move.w	d0,obInertia(a0)
		rts	
; End of function Sonic_RollLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollRight:
		move.w	obInertia(a0),d0
		bmi.s	Sonic_BrakeRollingLeft
		bclr	#staFacing,obStatus(a0)
		move.b	#aniID_Roll,obAnim(a0) ; use "rolling" animation
		rts	
; ===========================================================================

Sonic_BrakeRollingLeft:
		add.w	d4,d0	; reduce leftward rolling speed
		bcc.s	@skip
		clr.w	d0

	@skip:
		move.w	d0,obInertia(a0)
		rts	
; End of function Sonic_RollRight
