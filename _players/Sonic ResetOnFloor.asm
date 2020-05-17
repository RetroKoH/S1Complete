; ---------------------------------------------------------------------------
; Subroutine to	reset Sonic's mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ResetOnFloor:
		btst	#staRollJump,obStatus(a0)
		beq.s	@noRollJump
		nop	
		nop	
		nop	

	@noRollJump:
		bclr	#staPush,obStatus(a0)
		bclr	#staAir,obStatus(a0)
		bclr	#staRollJump,obStatus(a0)
		btst	#staSpin,obStatus(a0)
		beq.s	@skip
		bclr	#staSpin,obStatus(a0)
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#aniID_Walk,obAnim(a0) ; use running/walking animation
		subq.w	#5,obY(a0)
		clr.b	obJumping(a0)
		clr.w	(v_itembonus).w
		tst.b	obJumpFlag(a0)
		beq.s	@skip
		btst	#stsBubble,(v_status_secondary).w ; does Sonic have a Bubble Shield?
		beq.s	@nobubble
		bra.s	BubbleShield_Bounce

	@nobubble:
		move.b	(v_status_secondary).w,d0	; Check for any elemental shields
		andi.b	#$E0,d0						; if he has, we will exit
		bne.s	@noability
		cmpi.b	#$16,obJumpFlag(a0)
		blt.s	@noability
		bra.w	DropDash
		
	@noability:
		clr.b	obJumpFlag(a0)

	@skip:
		rts	
; End of function Sonic_ResetOnFloor

; ---------------------------------------------------------------------------
; Subroutine to	bounce Sonic in the air when he has a bubble shield
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


BubbleShield_Bounce:
		movem.l	d1-d2,-(sp)
		move.w	#$780,d2
		btst	#staWater,obStatus(a0)
		beq.s	@nowater
		move.w	#$400,d2

	@nowater:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr		CalcSine
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)
		movem.l	(sp)+,d1-d2
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		move.b	#1,obJumping(a0)
		clr.b	obOnWheel(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0)
		bset	#2,obStatus(a0)
		move.b	obHeight(a0),d0
		sub.b	#$13,d0
		ext.w	d0
		sub.w	d0,obY(a0)
		move.b	#aniID_BubbleBounceUp,(v_shieldspace+obAnim).w
		clr.b	obJumpFlag(a0)
		rts
;		move.w	#$44,d0
;		jmp	(Play_Sound_2).l
; End of function BubbleShield_Bounce

; ---------------------------------------------------------------------------
; Subroutine to	allow Sonic to perform the Drop Dash
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


DropDash:
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0)
		addq.w	#5,obY(a0)
		move.w	#$C00,obInertia(a0)
		btst	#staFacing,obStatus(a0)
		beq.s	@dontflip
		neg.w	obInertia(a0)
	@dontflip:
		bset	#staSpin,obStatus(a0)
		clr.b	obJumpFlag(a0)
		rts