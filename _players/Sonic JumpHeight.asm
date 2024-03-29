; ---------------------------------------------------------------------------
; Subroutine controlling Sonic's jump height/duration
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpHeight:
		tst.b	obJumping(a0)
		beq.s	Sonic_UpVelCap
		move.w	#-$400,d1
		btst	#staWater,obStatus(a0)
		beq.s	@noWater
		move.w	#-$200,d1

	@noWater:
		cmp.w	obVelY(a0),d1			; is Sonic going up faster than d1?
		ble.s	Sonic_DoubleJumpMoves	; if not, branch
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0			; is A, B or C pressed?
		bne.s	@end		;		 if yes, branch
		move.w	d1,obVelY(a0)

	@end:
		rts	
; ===========================================================================

Sonic_UpVelCap:
		tst.b	obStatus2(a0)	; is Sonic charging a spindash or in a rolling-only area?
		bne.s	@end			; if yes, branch
		cmpi.w	#-$FC0,obVelY(a0)
		bge.s	@end
		move.w	#-$FC0,obVelY(a0)

	@end:
		rts	
; End of function Sonic_JumpHeight
; ===========================================================================

; Shield Moves, and Drop Dash

Sonic_DoubleJumpMoves:
		tst.b	obJumpFlag(a0)						; is Sonic currently performing a double jump?
		bne.w	Sonic_ChkDropDash					; if yes, branch (Instead of doing nothing, we will check for DropDash)
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0							; are buttons A, B, or C being pressed?
		beq.w	Sonic_ShieldDoNothing				; if not, branch
		bclr	#staRollJump,obStatus(a0)			; clear Roll Jump flag
		btst	#stsSuper,(v_status_secondary).w	; is Sonic currently in his Super form?
		beq.s	Sonic_ShieldCheckFire				; if not, branch
	; super sonic
		move.b	#1,obJumpFlag(a0)					; if yes, just set Sonic's double jump flag
		rts

Sonic_ShieldCheckFire:
		btst	#stsInvinc,(v_status_secondary).w	; first, does Sonic have invincibility?
		bne.w	Sonic_JumpReset						; if yes, branch
		btst	#stsFlame,(v_status_secondary).w	; does Sonic have a Fire Shield?
		beq.s	Sonic_ShieldCheckLightning			; if not, branch
		addq.b	#1,(v_shieldspace+obAnim).w			; Set animation to aniID_FlameDash
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
		beq.s	Sonic_ShieldCheckBubble					; if not, branch
		addq.b	#1,(v_shieldspace+obAnim).w				; Set animation to aniID_LightningSpark
		move.b	#1,obJumpFlag(a0)
		move.w	#-$580,obVelY(a0)						; y speed set to -5.5, to spring him further upward
		clr.b	obJumping(a0)
		;move.w	#$45,d0
		;jmp	(Play_Sound_2).l
		rts

Sonic_ShieldCheckBubble:
		btst	#stsBubble,(v_status_secondary).w	; does Sonic have a Bubble Shield
		beq.s	Sonic_ShieldCheckSuper				; if not, branch
		addq.b	#1,(v_shieldspace+obAnim).w			; Set animation to aniID_BubbleBounce
		move.b	#1,obJumpFlag(a0)
		clr.w	obVelX(a0)
		clr.w	obInertia(a0)
		move.w	#$800,obVelY(a0)					; send Sonic straight down, to bounce himself up
		;move.w	#$44,d0
		;jmp	(Play_Sound_2).l
		rts

Sonic_ShieldCheckSuper:
;

Sonic_ShieldInsta:
		btst	#stsShield,(v_status_secondary).w	; does Sonic have a blue shield?
		bne.s	Sonic_JumpReset						; if yes, branch
		addq.b	#1,(v_shieldspace+obAnim).w			; Set animation
		move.b	#1,obJumpFlag(a0)
		;move.w	#$42,d0
		;jmp	(Play_Sound_2).l
		rts

Sonic_ChkDropDash:
		move.b	(v_status_secondary).w,d0	; Check for any elemental shields
		andi.b	#$E0,d0						; if he has, we will exit
		bne.s	Sonic_ShieldDoNothing
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0					; is A, B or C held down?
		beq.s	Sonic_JumpReset				; if no, branch
		addq.b	#1,obJumpFlag(a0)			; increment flag
		cmpi.b	#$16,obJumpFlag(a0)			; have we reached maximum?
		bne.s	Sonic_ShieldDoNothing
		move.b	#$16,obJumpFlag(a0)
		rts

Sonic_JumpReset:
		move.b	#1,obJumpFlag(a0) 			; Should use double jump property for this rev variable

Sonic_ShieldDoNothing:
		rts