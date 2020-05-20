; ---------------------------------------------------------------------------
; Subroutine to	slow Sonic walking up a	slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_SlopeResist:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bcc.s	@end
		move.b	obAngle(a0),d0
		jsr		(CalcSine).l
		muls.w	#$20,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		beq.s	@end
		bmi.s	@skip
		tst.w	d0
		beq.s	@end
	@skip:
		add.w	d0,obInertia(a0) ; change Sonic's inertia

	@end:
		rts
; End of function Sonic_SlopeResist
