; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Jump:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		beq.w	@dontjump	; if not, branch
		moveq	#0,d0
		move.b	obAngle(a0),d0
		addi.b	#$80,d0
		bsr.w	sub_14D48
		cmpi.w	#6,d1
		blt.w	@dontjump
		move.w	#$680,d2
		btst	#staWater,obStatus(a0)
		beq.s	@noWater
		move.w	#$380,d2

	@noWater:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)	; make Sonic jump
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)	; make Sonic jump
		bset	#staAir,obStatus(a0)
		bclr	#staPush,obStatus(a0)
		addq.l	#4,sp
		move.b	#1,obJumping(a0)
		clr.b	obOnWheel(a0)
		clr.b	obLRLock(a0)			; clear control lock
		sfx	sfx_Jump,0,0,0	; play jumping sound

		btst	#2,obStatus(a0)
		bne.s	@setRollJump
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0) ; use "jumping" animation
		bset	#staSpin,obStatus(a0)
		addq.w	#5,obY(a0)

	@dontjump:
		rts
; ===========================================================================

	@setRollJump:
		bset	#staRollJump,obStatus(a0)
		rts	
; End of function Sonic_Jump
