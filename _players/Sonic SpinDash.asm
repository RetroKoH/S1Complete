; ---------------------------------------------------------------------------
; Subroutine to check for starting to charge a spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_SpinDash:
		btst	#staSpinDash,obStatus2(a0)
		bne.s	Sonic_UpdateSpindash
		cmpi.b	#aniID_Duck,obAnim(a0)
		bne.s	@ret
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	@ret
		move.b	#aniID_SpinDash,obAnim(a0)
		move.b	#1,(v_effectspace+obAnim).w
		clr.b	(v_effectspace+obTimeFrame).w
		move.w	#$80,obRevSpeed(a0) ; Spin Dash Cancel
		move.w	#sfx_SpinDash,d0
		jsr		(PlaySound_Special).l
		addq.l	#4,sp
		bset	#staSpinDash,obStatus2(a0)
		bsr.w	Sonic_LevelBound
		bra.w	Player_AnglePos

	@ret:
		rts	
; ---------------------------------------------------------------------------
 
Sonic_UpdateSpindash:
		move.b	(v_jpadhold2).w,d0
		btst	#bitDn,d0
		bne.w	Sonic_ChargingSpindash
		move.b	#obBallHeight,obHeight(a0)
		move.b	#obBallWidth,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0)
		addq.w	#obPlayerHeight-obBallHeight,obY(a0)
		bclr	#staSpinDash,obStatus2(a0)
		moveq	#0,d0
		move.b	obRevSpeed(a0),d0
		add.w	d0,d0
		move.w	#1,obVelX(a0)	; force X speed to nonzero for camera lag's benefit
		move.w	SpinDashSpeeds(pc,d0.w),obInertia(a0)
		
		move.b	obInertia(a0),d0
		subi.b	#$8,d0
		add.b	d0,d0
		andi.b	#$1F,d0
		neg.b	d0
		addi.b	#$20,d0
		move.b	d0,(v_cameralag).w ; Apply spindash camera lag
		
		btst	#staFacing,obStatus(a0)
		beq.s	@dontflip
		neg.w	obInertia(a0)

	@dontflip:
		bset	#staSpin,obStatus(a0)
		move.w	#sfx_Teleport,d0
		jsr		(PlaySound_Special).l
; added to fix spindash bug
		move.b	obAngle(a0),d0
		jsr		(CalcSine).l
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		bra.w	SpinDash_ResetScr
; ---------------------------------------------------------------------------
SpinDashSpeeds:
		dc.w  $800		; 0
		dc.w  $880		; 1
		dc.w  $900		; 2
		dc.w  $980		; 3
		dc.w  $A00		; 4
		dc.w  $A80		; 5
		dc.w  $B00		; 6
		dc.w  $B80		; 7
		dc.w  $C00		; 8
; ---------------------------------------------------------------------------
 
Sonic_ChargingSpindash:				; If still charging the dash...
		tst.w	obRevSpeed(a0)
		beq.s	@chkInput
		
		move.w	obRevSpeed(a0),d0
		lsr.w	#5,d0
		sub.w	d0,obRevSpeed(a0)
		
; Spin Dash Cancel
		cmpi.w	#$1F,obRevSpeed(a0)
		bne.s	@skip
		clr.w	obRevSpeed(a0)				; clear SpinDash Counter
		bclr	#staSpinDash,obStatus2(a0)	; cancel SpinDash
		bra.s	SpinDash_ResetScr			; branch
		
	@skip:
		bcc.s	@chkInput
		clr.w	obRevSpeed(a0)

	@chkInput:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	SpinDash_ResetScr
		addi.w	#$200,obRevSpeed(a0)
		cmpi.w	#$800,obRevSpeed(a0)
		bcs.s	@sound
		move.w	#$800,obRevSpeed(a0)
	@sound:
		move.w	#sfx_SpinDash,d0
		jsr	(PlaySound_Special).l
 
SpinDash_ResetScr:
		addq.l	#4,sp					; increase stack ptr
		cmpi.w	#$60,(v_lookshift).w	; is screen in its default position?
		beq.s	@finish					; if yes, branch
		bcc.s	@scroll
		addq.w	#4,(v_lookshift).w
 
	@scroll:
		subq.w	#2,(v_lookshift).w
 
	@finish:
		bsr.w	Sonic_LevelBound
		bra.w	Player_AnglePos
