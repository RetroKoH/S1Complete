; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Jump:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0				; is A, B or C pressed?
		beq.w	@ret					; if not, branch and exit
		moveq	#0,d0
		move.b	obAngle(a0),d0
		addi.b	#$80,d0
		bsr.w	CalcRoomOverHead
		cmpi.w	#6,d1					; does Sonic have enough room to jump?
		blt.w	@ret					; if not, branch and exit
		move.w	#$680,d2
		btst	#staWater,obStatus(a0)	; Test if underwater
		beq.s	@noWater
		move.w	#$380,d2				; set lower jump speed if under

	@noWater:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr		(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)				; make Sonic jump (in X... this adds nothing on level ground)
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)				; make Sonic jump
		bset	#staAir,obStatus(a0)		; put Sonic in the air
		bclr	#staPush,obStatus(a0)		; no longer pushing
		addq.l	#4,sp
		move.b	#1,obJumping(a0)
		clr.b	obOnWheel(a0)				; take Sonic off the wheel
		sfx		sfx_Jump,0,0,0				; play jumping sound
		; Don't set height/width here
		btst	#staSpin,obStatus(a0)		; was Sonic already in a ball?
		bne.s	@rolljump					; this is a rolling jump
		move.b	#obBallHeight,obHeight(a0)
		move.b	#obBallWidth,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0)		; use "jumping" animation
		bset	#staSpin,obStatus(a0)
		addq.w	#obPlayerHeight-obBallHeight,obY(a0) ; 5

	@ret:
		rts
; ===========================================================================

	@rolljump:
		bset	#staRollJump,obStatus(a0)
		rts	
; End of function Sonic_Jump
