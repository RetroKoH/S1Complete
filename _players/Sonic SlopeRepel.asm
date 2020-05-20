; ---------------------------------------------------------------------------
; Subroutine to	push Sonic down	a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_SlopeRepel:
		nop	
		tst.b	obOnWheel(a0)
		bne.s	@end
		tst.w	obLRLock(a0)
		bne.s	@decLock
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	@end
		move.w	obInertia(a0),d0
		bpl.s	@notNegative
		neg.w	d0

	@notNegative:
		cmpi.w	#$280,d0
		bcc.s	@end
		clr.w	obInertia(a0)
		bset	#staAir,obStatus(a0)
		move.w	#$1E,obLRLock(a0)

	@end:
		rts	
; ===========================================================================

	@decLock:
		subq.w	#1,obLRLock(a0)
		rts	
; End of function Sonic_SlopeRepel
