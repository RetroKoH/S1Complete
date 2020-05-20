; ---------------------------------------------------------------------------
; Subroutine to	push Sonic down	a slope	while he's rolling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollRepel:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#-$40,d0
		bcc.s	@ret
		move.b	obAngle(a0),d0
		jsr		(CalcSine).l
		muls.w	#$50,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		bmi.s	@isNegative
		tst.w	d0
		bpl.s	@applyspeed1
		asr.l	#2,d0

	@applyspeed1:
		add.w	d0,obInertia(a0)
		rts	
; ===========================================================================

	@isNegative:
		tst.w	d0
		bmi.s	@applyspeed2
		asr.l	#2,d0

	@applyspeed2:
		add.w	d0,obInertia(a0)

	@ret:
		rts	
; End of function Sonic_RollRepel
