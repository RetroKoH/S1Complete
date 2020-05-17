; ---------------------------------------------------------------------------
; Subroutine allowing Tails to roll when he's moving
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Tails_Roll:
		tst.b	(f_jumponly).w
		bne.s	@noroll
		move.w	obInertia(a0),d0
		bpl.s	@ispositive
		neg.w	d0

	@ispositive:
		btst	#bitDn,(v_jpadhold2).w ; is down being pressed?
		beq.s	@noroll    ; if not, branch
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0	; is left/right	being pressed?
		bne.s	@noroll   ; if yes, branch
		move.w	obInertia(a0),d0
		bpl.s	@cont ; If ground speed is positive, continue
		neg.w	d0 ; If not, negate it to get the absolute value

	@cont: ; Slow ducking, a la Sonic 3K
		cmpi.b	#aniID_Balance,obAnim(a0)	; is Tails balancing?
		blt.s	@no							; if not.... then, NO :)
		cmpi.b	#aniID_Balance3,obAnim(a0)	; Are you sure? There are 3 animations
		ble.s	@noroll						; Don't duck

	@no:
		cmpi.w	#$100,d0					; is Tails moving at $100 speed or faster?
		bhi.s	Tails_ChkRoll				; if yes, branch
		move.b	#aniID_Duck,obAnim(a0)		; use "ducking" animation

	@noroll:
		rts	
; ===========================================================================

Tails_ChkRoll:
		btst	#staSpin,obStatus(a0)	; is Tails already rolling?
		beq.s	@roll		; if not, branch
		rts	
; ===========================================================================

@roll:
		bset	#staSpin,obStatus(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0) 		; use "rolling" animation
		move.b	#70,obFrame(a0)				; hard sets frame so no flicker when roll in tunnels
		addq.w	#1,obY(a0)
		sfx		sfx_Roll,0,0,0				; play rolling sound
		tst.w	obInertia(a0)
		bne.s	@ismoving
		move.w	#$200,obInertia(a0) 		; set inertia if 0

	@ismoving:
		rts	
; End of function Tails_Roll
