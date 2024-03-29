; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to roll when he's moving
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Roll:
		tst.b	(f_jumponly).w
		bne.s	@noroll
		move.w	obInertia(a0),d0
		bpl.s	@ispositive
		neg.w	d0

	@ispositive:
		cmpi.w	#$100,d0				; is Sonic moving at $100 speed or faster?
		bcs.s	@noroll					; if not, branch
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0			; is left/right	being pressed?
		bne.s	@noroll					; if yes, branch
		btst	#bitDn,(v_jpadhold2).w	; is down being pressed?
		bne.s	Sonic_ChkRoll			; if yes, branch

	@noroll:
		rts	
; ===========================================================================

Sonic_ChkRoll:
		btst	#staSpin,obStatus(a0)	; is Sonic already rolling?
		beq.s	@roll					; if not, branch
		rts	
; ===========================================================================

	@roll:
		bset	#staSpin,obStatus(a0)
		move.b	#obBallHeight,obHeight(a0)
		move.b	#obBallWidth,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0) 					; use "rolling" animation
		move.b	#fr_SonRoll1,obFrame(a0)				; hard sets frame so no flicker when roll in tunnels
		addq.w	#obPlayerHeight-obBallHeight,obY(a0)	; 5
		sfx		sfx_Roll,0,0,0							; play rolling sound
		tst.w	obInertia(a0)
		bne.s	@ismoving
		move.w	#$200,obInertia(a0) 					; set inertia if 0

	@ismoving:
		rts	
; End of function Sonic_Roll
