; ---------------------------------------------------------------------------
; Subroutine translating object	speed to update	object position
; Optimized by applying speed to the pos directly, instead of to d2 and d3.
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SpeedToPos:
		move.w	obVelX(a0),d0	; load horizontal speed
		ext.l	d0
		lsl.l	#8,d0			; multiply speed by $100
		add.l	d0,obX(a0)		; add to x-axis	position
		move.w	obVelY(a0),d0	; load vertical	speed
		ext.l	d0
		lsl.l	#8,d0			; multiply by $100
		add.l	d0,obY(a0)		; add to y-axis	position
		rts	

; End of function SpeedToPos
