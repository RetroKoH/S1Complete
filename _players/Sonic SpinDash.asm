Sonic_SpinDash:
		btst	#staSpinDash,obStatus2(a0)
		bne.s	loc_1AC8E
		cmpi.b	#aniID_Duck,obAnim(a0)
		bne.s	locret_1AC8C
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	locret_1AC8C
		move.b	#aniID_SpinDash,obAnim(a0)
		
		move.b	#1,(v_effectspace+obAnim).w
		move.b	#0,(v_effectspace+obTimeFrame).w
	
		move.w	#$80,obRevSpeed(a0) ; Spin Dash Cancel
	
		move.w	#sfx_SpinDash,d0
		jsr		(PlaySound_Special).l
		addq.l	#4,sp
		bset	#staSpinDash,obStatus2(a0)
 
		bsr.w	Player_LevelBound
		bsr.w	Player_AnglePos
 
locret_1AC8C:
		rts	
; ---------------------------------------------------------------------------
 
loc_1AC8E:
		move.b	#aniID_SpinDash,obAnim(a0)
		move.b	(v_jpadhold2).w,d0
		btst	#bitDn,d0
		bne.w	loc_1AD30
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0)
		addq.w	#5,obY(a0)
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
		bclr	#7,obStatus(a0)
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
 
loc_1AD30:				; If still charging the dash...
		tst.w	obRevSpeed(a0)
		beq.s	loc_1AD48
		
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
		bcc.s	loc_1AD48
		clr.w	obRevSpeed(a0)
 
loc_1AD48:
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
		addq.l	#4,sp			; increase stack ptr
		cmpi.w	#$60,(v_lookshift).w
		beq.s	loc_1AD8C
		bcc.s	loc_1AD88
		addq.w	#4,(v_lookshift).w
 
loc_1AD88:
		subq.w	#2,(v_lookshift).w
 
loc_1AD8C:
		bsr.w	Player_LevelBound
		bra.w	Player_AnglePos
