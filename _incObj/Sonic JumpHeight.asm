; ---------------------------------------------------------------------------
; Subroutine controlling Sonic's jump height/duration
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpHeight:
		tst.b	obJumping(a0)
		beq.s	loc_134C4
		move.w	#-$400,d1
		btst	#staWater,obStatus(a0)
		beq.s	loc_134AE
		move.w	#-$200,d1

loc_134AE:
		cmp.w	obVelY(a0),d1
		ble.s	Sonic_DoubleJumpMoves
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0			; is A, B or C pressed?
		bne.s	locret_134C2		; if yes, branch
		move.w	d1,obVelY(a0)

locret_134C2:
		rts	
; ===========================================================================

loc_134C4:
;		tst.b	obDashFlag(a0)	; is Sonic charging his spin dash?
;		bne.s	locret_134D2		; if yes, branch
		cmpi.w	#-$FC0,obVelY(a0)
		bge.s	locret_134D2
		move.w	#-$FC0,obVelY(a0)

locret_134D2:
		rts	
; End of function Sonic_JumpHeight
; ===========================================================================

; Shield Moves, and Drop Dash

Sonic_DoubleJumpMoves:
		tst.b	obJumpFlag(a0)			; is Sonic currently performing a double jump?
		bne.w	Sonic_ShieldDoNothing	; if yes, branch
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0				; are buttons A, B, or C being pressed?
		beq.w	Sonic_ShieldDoNothing	; if not, branch
		bclr	#4,obStatus(a0)
		btst	#stsSuper,(v_status_secondary).w	; is Sonic currently in his Super form?
		beq.s	Sonic_ShieldCheckFire				; if not, branch
		move.b	#1,obJumpFlag(a0)					; if yes, set Sonic's double jump flag
		rts

Sonic_ShieldCheckFire:
		btst	#stsInvinc,(v_status_secondary).w	; first, does Sonic have invincibility?
		bne.w	Sonic_ShieldDoNothing				; if yes, branch
		btst	#stsFlame,(v_status_secondary).w	; does Sonic have a Fire Shield?
		beq.s	Sonic_ShieldCheckLightning			; if not, branch
		addq.b	#1,(v_shieldspace+obAnim).w			; Set animation
		move.b	#1,obJumpFlag(a0)					; Set double jump flag
		move.w	#$800,d0							; Set horizontal speed to 8
		btst	#staFacing,obStatus(a0)				; is Sonic facing left?
		beq.s	@noflip								; if not, branch
		neg.w	d0									; if yes, negate x speed value to move Sonic left

	@noflip:
		move.w	d0,obVelX(a0)						; apply speeds
		move.w	d0,obInertia(a0)
		clr.w	obVelY(a0)
		;move.w	#$43,d0
		;jmp	(Play_Sound_2).l
		rts

Sonic_ShieldCheckLightning:
		btst	#stsLightning,(v_status_secondary).w	; does Sonic have a Lightning Shield?
		beq.s	Sonic_ShieldCheckBubble		; if not, branch
		addq.b	#1,(v_shieldspace+obAnim).w	; Set animation
		move.b	#1,obJumpFlag(a0)
		move.w	#-$580,obVelY(a0)			; y speed set to -5.5, to spring him further upward
		clr.b	obJumping(a0)
		;move.w	#$45,d0
		;jmp	(Play_Sound_2).l
		rts

Sonic_ShieldCheckBubble:
		btst	#stsBubble,(v_status_secondary).w	; does Sonic have a Bubble Shield
		beq.s	Sonic_ShieldCheckSuper		; if not, branch
		addq.b	#1,(v_shieldspace+obAnim).w	; Set animation
		move.b	#1,obJumpFlag(a0)
		clr.w	obVelX(a0)
		clr.w	obInertia(a0)
		move.w	#$800,obVelY(a0)				; send Sonic straight down, to bounce himself up
		;move.w	#$44,d0
		;jmp	(Play_Sound_2).l
		rts

Sonic_ShieldCheckSuper:
;

Sonic_ShieldInsta:
		btst	#stsShield,(v_status_secondary).w	; does Sonic have a blue shield?
		bne.s	Sonic_ShieldDoNothing		; if yes, branch
		addq.b	#1,(v_shieldspace+obAnim).w	; Set animation
		move.b	#1,obJumpFlag(a0)
		;move.w	#$42,d0
		;jmp	(Play_Sound_2).l

Sonic_ShieldDoNothing:
		rts