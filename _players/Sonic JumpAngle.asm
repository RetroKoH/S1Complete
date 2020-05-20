; ---------------------------------------------------------------------------
; Subroutine to	return Sonic's angle to 0 as he jumps
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpAngle:
		move.b	obAngle(a0),d0		; get Sonic's angle
		beq.s	Sonic_JumpAngle_End	; if already 0,	branch
		bpl.s	@notNegative		; if higher than 0, branch

		addq.b	#2,d0		; increase angle
		bcc.s	Sonic_JumpAngleSet
		moveq	#0,d0
		bra.s	Sonic_JumpAngleSet
; ===========================================================================

	@notNegative:
		subq.b	#2,d0		; decrease angle
		bcc.s	Sonic_JumpAngleSet
		moveq	#0,d0

Sonic_JumpAngleSet:
		move.b	d0,obAngle(a0)

Sonic_JumpAngle_End:
		rts	
; End of function Sonic_JumpAngle
