; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Move:
		move.w	(v_sonspeedmax).w,d6
		move.w	(v_sonspeedacc).w,d5
		move.w	(v_sonspeeddec).w,d4
		tst.b	(f_jumponly).w
		bne.w	loc_12FEE
		tst.w	$3E(a0)
		bne.w	Sonic_ResetScr
		btst	#bitL,(v_jpadhold2).w ; is left being pressed?
		beq.s	@notleft	; if not, branch
		bsr.w	Sonic_MoveLeft

	@notleft:
		btst	#bitR,(v_jpadhold2).w ; is right being pressed?
		beq.s	@notright	; if not, branch
		bsr.w	Sonic_MoveRight

	@notright:
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0		; is Sonic on a	slope?
		bne.w	Sonic_ResetScr	; if yes, branch
		tst.w	obInertia(a0)	; is Sonic moving?
		bne.w	Sonic_ResetScr	; if yes, branch
		bclr	#5,obStatus(a0)
		move.b	#aniID_Wait,obAnim(a0) ; use "standing" animation
		btst	#3,obStatus(a0)
		beq.s	Sonic_Balance
		moveq	#0,d0
		move.b	$3D(a0),d0
		lsl.w	#6,d0
		lea	(v_objspace).w,a1
		lea	(a1,d0.w),a1
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
		blt.s	loc_12F6A
		cmp.w	d2,d1
		bge.s	loc_12F5A
		bra.s	Sonic_LookUp
; ===========================================================================

Sonic_Balance:
		jsr	(ObjFloorDist).l
		cmpi.w	#$C,d1
		blt.s	Sonic_LookUp
		cmpi.b	#3,$36(a0)
		bne.s	loc_12F62

loc_12F5A:
		bclr	#0,obStatus(a0)
		bra.s	loc_12F70
; ===========================================================================

loc_12F62:
		cmpi.b	#3,$37(a0)
		bne.s	Sonic_LookUp

loc_12F6A:
		bset	#staFacing,obStatus(a0)

loc_12F70:
		move.b	#aniID_Balance,obAnim(a0) ; use "balancing" animation
		bra.w	Sonic_ResetScr
; ===========================================================================

Sonic_LookUp:
		btst	#bitUp,(v_jpadhold2).w ; is up being pressed?
		beq.s	Sonic_Duck	; if not, branch
		move.b	#aniID_LookUp,obAnim(a0) ; use "looking up" animation
; S2 Scroll Delay
		addq.b	#1,(v_scrolldelay).w			; add 1 to the scroll timer
		cmpi.b	#120,(v_scrolldelay).w	; is it equal to or greater than the scroll delay?
		bcs.s	Sonic_LookReset				; if not, skip ahead without looking up
		move.b	#120,(v_scrolldelay).w 	; move the scroll delay value into the scroll timer so it won't continue to count higher

		move.w	(v_screenposy).w,d0	; get camera top coordinate
		sub.w	(v_limittop2).w,d0	; subtract zone's top bound from it
		add.w	(v_lookshift).w,d0	; add default offset
		cmpi.w	#$C8,d0				; is offset <= $C8?
		ble.s	@skip				; if so, branch
		move.w	#$C8,d0				; set offset to $C8
		
	@skip:
		cmp.w	(v_lookshift).w,d0 	; Look Shift Fix
		ble.s	loc_12FC2
		addq.w	#2,(v_lookshift).w
		bra.s	loc_12FC2
; ===========================================================================

Sonic_Duck:
		btst	#bitDn,(v_jpadhold2).w ; is down being pressed?
		beq.s	Sonic_ResetScr	; if not, branch
		move.b	#aniID_Duck,obAnim(a0) ; use "ducking" animation
; S2 Scroll Delay
		addq.b	#1,(v_scrolldelay).w			; add 1 to the scroll timer
		cmpi.b	#120,(v_scrolldelay).w	; is it equal to or greater than the scroll delay?
		bcs.s	Sonic_LookReset				; if not, skip ahead without looking up
		move.b	#120,(v_scrolldelay).w 	; move the scroll delay value into the scroll timer so it won't continue to count higher

		move.w	(v_screenposy).w,d0	; get camera top coordinate
		sub.w	(v_limitbtm2).w,d0	; subtract zone's bottom bound from it (creating a negative number)
		add.w	(v_lookshift).w,d0	; add default offset
		cmpi.w	#8,d0			; is offset < 8?
		blt.s	@set			; if so, branch
		bgt.s	@skip			; if greater than 8, branch
		
	@set:
		move.w	#8,d0	; set offset to 8
		
	@skip:
		cmp.w	(v_lookshift).w,d0 ; Look Shift Fix
		bge.s	loc_12FC2
		subq.w	#2,(v_lookshift).w
		bra.s	loc_12FC2
; ===========================================================================

Sonic_ResetScr:
		move.b	#0,(v_scrolldelay).w	; clear the scroll timer, because up/down are not being held

Sonic_LookReset:	; added branch point that the new scroll delay code skips ahead to
		cmpi.w	#$60,(v_lookshift).w ; is screen in its default position?
		beq.s	loc_12FC2	; if yes, branch
		bcc.s	loc_12FBE
		addq.w	#4,(v_lookshift).w ; move screen back to default

loc_12FBE:
		subq.w	#2,(v_lookshift).w ; move screen back to default

loc_12FC2:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0	; is left/right	pressed?
		bne.s	loc_12FEE	; if yes, branch
		move.w	obInertia(a0),d0
		beq.s	loc_12FEE
		bmi.s	loc_12FE2
		sub.w	d5,d0
		bcc.s	loc_12FDC
		move.w	#0,d0

loc_12FDC:
		move.w	d0,obInertia(a0)
		bra.s	loc_12FEE
; ===========================================================================

loc_12FE2:
		add.w	d5,d0
		bcc.s	loc_12FEA
		move.w	#0,d0

loc_12FEA:
		move.w	d0,obInertia(a0)

loc_12FEE:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)

loc_1300C:
		move.b	obAngle(a0),d0
		addi.b	#$40,d0
		bmi.s	locret_1307C
		move.b	#$40,d1
		tst.w	obInertia(a0)
		beq.s	locret_1307C
		bmi.s	loc_13024
		neg.w	d1

loc_13024:
		move.b	obAngle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	Sonic_WalkSpeed
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_1307C
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_13078
		cmpi.b	#$40,d0
		beq.s	loc_13066
		cmpi.b	#$80,d0
		beq.s	loc_13060
		add.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts	
; ===========================================================================

loc_13060:
		sub.w	d1,obVelY(a0)
		rts	
; ===========================================================================

loc_13066:
		sub.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts	
; ===========================================================================

loc_13078:
		add.w	d1,obVelY(a0)

locret_1307C:
		rts	
; End of function Sonic_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveLeft:
		move.w	obInertia(a0),d0
		beq.s	loc_13086
		bpl.s	loc_130B2

loc_13086:
		bset	#0,obStatus(a0)
		bne.s	loc_1309A
		bclr	#5,obStatus(a0)
		move.b	#aniID_Run,obNextAni(a0)

loc_1309A:
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_130A6
		add.w	d5,d0		; +++ remove this frame's acceleration change
		cmp.w	d1,d0		; +++ compare speed with top speed
		ble.s	loc_130A6	; +++ if speed was already greater than the maximum, branch
		move.w	d1,d0

loc_130A6:
		move.w	d0,obInertia(a0)
		move.b	#aniID_Walk,obAnim(a0) ; use walking animation
		rts	
; ===========================================================================

loc_130B2:
		sub.w	d4,d0
		bcc.s	loc_130BA
		move.w	#-$80,d0

loc_130BA:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_130E8
		cmpi.w	#$400,d0
		blt.s	locret_130E8
		move.b	#aniID_Stop,obAnim(a0) ; use "stopping" animation
		bclr	#0,obStatus(a0)
		sfx	sfx_Skid,0,0,0	; play stopping sound
		move.b	#6,(v_effectspace+obRoutine).w

locret_130E8:
		rts	
; End of function Sonic_MoveLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveRight:
		move.w	obInertia(a0),d0
		bmi.s	loc_13118
		bclr	#0,obStatus(a0)
		beq.s	loc_13104
		bclr	#5,obStatus(a0)
		move.b	#aniID_Run,obNextAni(a0)

loc_13104:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_1310C
		sub.w	d5,d0		; +++ remove this frame's acceleration change
		cmp.w	d6,d0		; +++ compare speed with top speed
		bge.s	loc_1310C	; +++ if speed was already greater than the maximum, branch
		move.w	d6,d0

loc_1310C:
		move.w	d0,obInertia(a0)
		move.b	#aniID_Walk,obAnim(a0) ; use walking animation
		rts	
; ===========================================================================

loc_13118:
		add.w	d4,d0
		bcc.s	loc_13120
		move.w	#$80,d0

loc_13120:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_1314E
		cmpi.w	#-$400,d0
		bgt.s	locret_1314E
		move.b	#aniID_Stop,obAnim(a0) ; use "stopping" animation
		bset	#0,obStatus(a0)
		sfx	sfx_Skid,0,0,0	; play stopping sound
		move.b	#6,(v_effectspace+obRoutine).w

locret_1314E:
		rts	
; End of function Sonic_MoveRight
