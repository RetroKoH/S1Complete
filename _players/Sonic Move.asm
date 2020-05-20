; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Move:
		move.w	(v_sonspeedmax).w,d6
		move.w	(v_sonspeedacc).w,d5
		move.w	(v_sonspeeddec).w,d4
		tst.b	(f_jumponly).w
		bne.w	Sonic_Traction
		tst.w	obLRLock(a0)
		bne.w	Sonic_ResetScr
		btst	#bitL,(v_jpadhold2).w	; is left being pressed?
		beq.s	@notleft				; if not, branch
		bsr.w	Sonic_MoveLeft

	@notleft:
		btst	#bitR,(v_jpadhold2).w	; is right being pressed?
		beq.s	@notright				; if not, branch
		bsr.w	Sonic_MoveRight

	@notright:
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0					; is Sonic on a	slope?
		bne.w	Sonic_ResetScr			; if yes, branch
		tst.w	obInertia(a0)			; is Sonic moving?
		bne.w	Sonic_ResetScr			; if yes, branch
		bclr	#staPush,obStatus(a0)
		move.b	#aniID_Wait,obAnim(a0)	; use "standing" animation
		btst	#staOnObj,obStatus(a0)
		beq.s	Sonic_Balance
		moveq	#0,d0
		move.b	obPlatformID(a0),d0		; get OST slot of object Sonic is on
		mulu.w	#obSize,d0				; get offset of object
		lea		(v_objspace).w,a1
		lea		(a1,d0.w),a1			; a1 = object
		tst.b	obStatus(a1)
		bmi.s	Sonic_LookUp
		moveq	#0,d1
		move.b	obActWid(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#4,d2
		add.w	obX(a0),d1
		sub.w	obX(a1),d1
		cmpi.w	#4,d1
		blt.s	Sonic_BalanceOnObjLeft
		cmp.w	d2,d1
		bge.s	Sonic_BalanceOnObjRight
		bra.s	Sonic_LookUp
; ===========================================================================

Sonic_Balance:
		jsr		(ObjFloorDist).l
		cmpi.w	#$C,d1
		blt.s	Sonic_LookUp
		cmpi.b	#3,obFrontAngle(a0)
		bne.s	Sonic_BalanceLeft

Sonic_BalanceOnObjRight:
		bclr	#staFacing,obStatus(a0)
		bra.s	Sonic_BalanceSetAnim
; ===========================================================================

Sonic_BalanceLeft:
		cmpi.b	#3,obRearAngle(a0)
		bne.s	Sonic_LookUp

Sonic_BalanceOnObjLeft:
		bset	#staFacing,obStatus(a0)

Sonic_BalanceSetAnim:
		move.b	#aniID_Balance,obAnim(a0) ; use "balancing" animation
		bra.w	Sonic_ResetScr
; ===========================================================================

Sonic_LookUp:
		btst	#bitUp,(v_jpadhold2).w		; is up being pressed?
		beq.s	Sonic_Duck					; if not, branch
		move.b	#aniID_LookUp,obAnim(a0)	; use "looking up" animation
; S2 Scroll Delay
		addq.b	#1,(v_scrolldelay).w	; add 1 to the scroll timer
		cmpi.b	#120,(v_scrolldelay).w	; is it equal to or greater than the scroll delay?
		bcs.s	Sonic_LookReset			; if not, skip ahead without looking up
		move.b	#120,(v_scrolldelay).w 	; move the scroll delay value into the scroll timer so it won't continue to count higher

		move.w	(v_screenposy).w,d0	; get camera top coordinate
		sub.w	(v_limittop2).w,d0	; subtract zone's top bound from it
		add.w	(v_lookshift).w,d0	; add default offset
		cmpi.w	#$C8,d0				; is offset <= $C8?
		ble.s	@skip				; if so, branch
		move.w	#$C8,d0				; set offset to $C8
		
	@skip:
		cmp.w	(v_lookshift).w,d0 	; Look Shift Fix
		ble.s	Sonic_UpdateSpeedOnGround
		addq.w	#2,(v_lookshift).w
		bra.s	Sonic_UpdateSpeedOnGround
; ===========================================================================

Sonic_Duck:
		btst	#bitDn,(v_jpadhold2).w	; is down being pressed?
		beq.s	Sonic_ResetScr			; if not, branch
		move.b	#aniID_Duck,obAnim(a0)	; use "ducking" animation
; S2 Scroll Delay
		addq.b	#1,(v_scrolldelay).w	; add 1 to the scroll timer
		cmpi.b	#120,(v_scrolldelay).w	; is it equal to or greater than the scroll delay?
		bcs.s	Sonic_LookReset			; if not, skip ahead without looking up
		move.b	#120,(v_scrolldelay).w 	; move the scroll delay value into the scroll timer so it won't continue to count higher

		move.w	(v_screenposy).w,d0	; get camera top coordinate
		sub.w	(v_limitbtm2).w,d0	; subtract zone's bottom bound from it (creating a negative number)
		add.w	(v_lookshift).w,d0	; add default offset
		cmpi.w	#8,d0				; is offset < 8?
		blt.s	@set				; if so, branch
		bgt.s	@skip				; if greater than 8, branch
		
	@set:
		move.w	#8,d0	; set offset to 8
		
	@skip:
		cmp.w	(v_lookshift).w,d0 ; Look Shift Fix
		bge.s	Sonic_UpdateSpeedOnGround
		subq.w	#2,(v_lookshift).w
		bra.s	Sonic_UpdateSpeedOnGround
; ===========================================================================

Sonic_ResetScr:
		move.b	#0,(v_scrolldelay).w	; clear the scroll timer, because up/down are not being held

Sonic_LookReset:	; added branch point that the new scroll delay code skips ahead to
		cmpi.w	#$60,(v_lookshift).w		; is screen in its default position?
		beq.s	Sonic_UpdateSpeedOnGround	; if yes, branch
		bcc.s	Sonic_LookReset2
		addq.w	#4,(v_lookshift).w		; move screen back to default

Sonic_LookReset2:
		subq.w	#2,(v_lookshift).w		; move screen back to default

; ---------------------------------------------------------------------------
; updates Sonic's speed on the ground
; ---------------------------------------------------------------------------

Sonic_UpdateSpeedOnGround:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0			; is left/right	pressed?
		bne.s	Sonic_Traction			; if yes, branch
		move.w	obInertia(a0),d0
		beq.s	Sonic_Traction
		bmi.s	Sonic_SettleLeft
; slow down when facing right and not pressing a direction
;Sonic_SettleRight:
		sub.w	d5,d0
		bcc.s	@setInertia
		move.w	#0,d0

	@setInertia:
		move.w	d0,obInertia(a0)
		bra.s	Sonic_Traction
; ===========================================================================
; slow down when facing left and not pressing a direction
Sonic_SettleLeft:
		add.w	d5,d0
		bcc.s	@setInertia
		move.w	#0,d0

	@setInertia:
		move.w	d0,obInertia(a0)

; increase or decrease speed on the ground
Sonic_Traction:
		move.b	obAngle(a0),d0
		jsr		(CalcSine).l
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)

; stops Sonic from running through walls that meet the ground
Sonic_CheckWallsOnGround:
		move.b	obAngle(a0),d0
		addi.b	#$40,d0
		bmi.s	@end
		move.b	#$40,d1			; Rotate 90 degrees clockwise
		tst.w	obInertia(a0)	; Check inertia
		beq.s	@end			; If not moving, don't do anything
		bmi.s	@skip			; If negative, branch
		neg.w	d1				; Otherwise, we want to rotate counterclockwise

	@skip:
		move.b	obAngle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	CalcRoomInFront
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	@end
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	@ceiling
		cmpi.b	#$40,d0
		beq.s	@leftwall
		cmpi.b	#$80,d0
		beq.s	@floor
;	@rightwall:
		add.w	d1,obVelX(a0)
		bset	#staPush,obStatus(a0)
		clr.w	obInertia(a0)
		rts	
; ===========================================================================

	@floor:
		sub.w	d1,obVelY(a0)
		rts	
; ===========================================================================

	@leftwall:
		sub.w	d1,obVelX(a0)
		bset	#staPush,obStatus(a0)
		clr.w	obInertia(a0)
		rts	
; ===========================================================================

	@ceiling:
		add.w	d1,obVelY(a0)

	@end:
		rts	
; End of function Sonic_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveLeft:
		move.w	obInertia(a0),d0
		beq.s	@notMoving
		bpl.s	Sonic_TurnLeft

	@notMoving:
		bset	#staFacing,obStatus(a0)
		bne.s	@accelerate
		bclr	#staPush,obStatus(a0)
		move.b	#aniID_Run,obNextAni(a0)

	@accelerate:
		sub.w	d5,d0			; add acceleration to the left
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0			; compare new speed with top speed
		bgt.s	@setInertia		; if new speed is less than the maximum, branch
		add.w	d5,d0		; +++ remove this frame's acceleration change
		cmp.w	d1,d0		; +++ compare speed with top speed
		ble.s	@setInertia	; +++ if speed was already greater than the maximum, branch
		move.w	d1,d0			; limit speed on ground going left

	@setInertia:
		move.w	d0,obInertia(a0)
		move.b	#aniID_Walk,obAnim(a0) ; use walking animation
		rts	
; ===========================================================================

Sonic_TurnLeft:
		sub.w	d4,d0
		bcc.s	@setInertia
		move.w	#-$80,d0

	@setInertia:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	@ret
		cmpi.w	#$400,d0
		blt.s	@ret
		move.b	#aniID_Stop,obAnim(a0) ; use "stopping" animation
		bclr	#staFacing,obStatus(a0)
		sfx		sfx_Skid,0,0,0	; play stopping sound
		move.b	#6,(v_effectspace+obRoutine).w

	@ret:
		rts	
; End of function Sonic_MoveLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveRight:
		move.w	obInertia(a0),d0
		bmi.s	Sonic_TurnRight
		bclr	#staFacing,obStatus(a0)
		beq.s	@accelerate
		bclr	#staPush,obStatus(a0)
		move.b	#aniID_Run,obNextAni(a0)

	@accelerate:
		add.w	d5,d0			; add acceleration to the right
		cmp.w	d6,d0			; compare new speed with top speed
		blt.s	@setInertia		; if new speed is less than the maximum, branch
		sub.w	d5,d0		; +++ remove this frame's acceleration change
		cmp.w	d6,d0		; +++ compare speed with top speed
		bge.s	@setInertia	; +++ if speed was already greater than the maximum, branch
		move.w	d6,d0			; limit speed on ground going right

	@setInertia:
		move.w	d0,obInertia(a0)
		move.b	#aniID_Walk,obAnim(a0) ; use walking animation
		rts	
; ===========================================================================

Sonic_TurnRight:
		add.w	d4,d0
		bcc.s	@setInertia
		move.w	#$80,d0

	@setInertia:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	@ret
		cmpi.w	#-$400,d0
		bgt.s	@ret
		move.b	#aniID_Stop,obAnim(a0) ; use "stopping" animation
		bset	#staFacing,obStatus(a0)
		sfx		sfx_Skid,0,0,0	; play stopping sound
		move.b	#6,(v_effectspace+obRoutine).w

	@ret:
		rts	
; End of function Sonic_MoveRight
