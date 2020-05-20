; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's direction while jumping
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpDirection:
		move.w	(v_sonspeedmax).w,d6
		move.w	(v_sonspeedacc).w,d5
		asl.w	#1,d5
		btst	#staRollJump,obStatus(a0)	; did Sonic jump from rolling?
		bne.s	Sonic_Jump_ResetScr			; if yes, branch to skip midair control
		move.w	obVelX(a0),d0
		btst	#bitL,(v_jpadhold2).w	; is left being pressed?
		beq.s	@skip				; if not, branch
		bset	#staFacing,obStatus(a0)
		sub.w	d5,d0		; add acceleration to the left
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	@skip
		add.w	d5,d0	; +++ remove this frame's acceleration change
		cmp.w	d1,d0	; +++ compare speed with top speed
		ble.s	@skip	; +++ if speed was already greater than the maximum, branch	
		move.w	d1,d0

	@skip:
		btst	#bitR,(v_jpadhold2).w	; is right being pressed?
		beq.s	@move					; if not, branch
		bclr	#staFacing,obStatus(a0)
		add.w	d5,d0		; add acceleration to the right
		cmp.w	d6,d0
		blt.s	@move
		sub.w	d5,d0		; +++ remove this frame's acceleration change
		cmp.w	d6,d0		; +++ compare speed with top speed
		bge.s	@move		; +++ if speed was already greater than the maximum, branch
		move.w	d6,d0

	@move:
		move.w	d0,obVelX(a0)	; change Sonic's horizontal speed

Sonic_Jump_ResetScr:
		cmpi.w	#$60,(v_lookshift).w ; is the screen in its default position?
		beq.s	Sonic_JumpPeakDecelerate	; if yes, branch
		bcc.s	@reset
		addq.w	#4,(v_lookshift).w

	@reset:
		subq.w	#2,(v_lookshift).w

Sonic_JumpPeakDecelerate:
		cmpi.w	#-$400,obVelY(a0) 		; is Sonic moving faster than -$400 upwards?
		bcs.s	Sonic_JumpPeakDecelEnd	; if yes, branch
		move.w	obVelX(a0),d0
		move.w	d0,d1
		asr.w	#5,d1							; d1 = x_velocity / 32
		beq.s	Sonic_JumpPeakDecelEnd			; branch if 0
		bmi.s	Sonic_JumpPeakDecelerateLeft	; branch if negative
; Sonic_JumpPeakDecelerateRight:
		sub.w	d1,d0
		bcc.s	@skip
		move.w	#0,d0

	@skip:
		move.w	d0,obVelX(a0)
		rts	
; ===========================================================================

Sonic_JumpPeakDecelerateLeft:
		sub.w	d1,d0		; reduce x velocity by d1
		bcs.s	@skip
		move.w	#0,d0

	@skip:
		move.w	d0,obVelX(a0)

Sonic_JumpPeakDecelEnd:
		rts	
; End of function Sonic_JumpDirection
