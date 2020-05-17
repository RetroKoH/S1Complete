; ---------------------------------------------------------------------------
; Subroutine to	reset Tails's mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Tails_ResetOnFloor:
		btst	#staRollJump,obStatus(a0)
		beq.s	@noRollJump
		nop	
		nop	
		nop	

	@noRollJump:
		bclr	#staPush,obStatus(a0)
		bclr	#staAir,obStatus(a0)
		bclr	#staRollJump,obStatus(a0)
		clr.b	obJumping(a0)
		clr.w	(v_itembonus).w
		btst	#staSpin,obStatus(a0)
		beq.s	@skip
		bclr	#staSpin,obStatus(a0)
		move.b	#$F,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#aniID_Walk,obAnim(a0) ; use running/walking animation
		subq.w	#1,obY(a0)
		clr.b	obJumping(a0)
		clr.w	(v_itembonus).w
		clr.b	obJumpFlag(a0)

	@skip:
		rts	
; End of function Sonic_ResetOnFloor
