; ---------------------------------------------------------------------------
; Subroutine controlling Tails's jump height/duration
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Tails_JumpHeight:
		tst.b	obJumping(a0)
		beq.s	@notjumping
		move.w	#-$400,d1
		btst	#staWater,obStatus(a0)
		beq.s	@noWater
		move.w	#-$200,d1

	@noWater:
		cmp.w	obVelY(a0),d1
		ble.s	Tails_ChkFlight
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0			; is A, B or C pressed?
		bne.s	@dontstop		; if yes, branch
		move.w	d1,obVelY(a0)

	@dontstop:
		rts	
; ===========================================================================

	@notjumping:
		tst.b	obStatus2(a0)	; is Tails charging his spin dash?
		bne.s	@end		; if yes, branch
		cmpi.w	#-$FC0,obVelY(a0)
		bge.s	@end
		move.w	#-$FC0,obVelY(a0)

	@end:
		rts	
; End of function Tails_JumpHeight
; ===========================================================================

Tails_ChkFlight:
		rts