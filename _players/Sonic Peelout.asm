Sonic_Dash:
		btst	#staDash,obStatus2(a0)
		bne.s	Sonic_DashLaunch
		cmpi.b	#aniID_LookUp,obAnim(a0)
		bne.s	@return
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	@return
		move.b	#aniID_Run,obAnim(a0)
		clr.w	obRevSpeed(a0)
		move.w	#sfx_SpinDash,d0
		jsr		(PlaySound_Special).l
		addq.l	#4,sp
		bset	#staDash,obStatus2(a0)
 
		bsr.w	Player_LevelBound
		bsr.w	Player_AnglePos
 
	@return:
		rts	
; ---------------------------------------------------------------------------
 
Sonic_DashLaunch:
		move.b	#aniID_Peelout,obAnim(a0)
		move.b	(v_jpadhold2).w,d0
		btst	#bitUp,d0
		bne.w	Sonic_DashCharge
		bclr	#staDash,obStatus2(a0)	; stop Dashing
		cmpi.b	#$1E,obRevSpeed(a0)	; have we been charging long enough?
		bne.s	Sonic_DashResetScr
		move.b	#aniID_Dash,obAnim(a0)	; launches here
		move.w	#1,obVelX(a0)	; force X speed to nonzero for camera lag's benefit
		move.w	#$0C00,obInertia(a0)
		move.w	obInertia(a0),d0
		subi.w	#$800,d0
		add.w	d0,d0
		andi.w	#$1F00,d0
		neg.w	d0
		addi.w	#$2000,d0
		;move.w	d0,(v_cameralag).w
		btst	#staFacing,obStatus(a0)
		beq.s	@dontflip
		neg.w	obInertia(a0)
 
@dontflip:
		bclr	#7,obStatus(a0)
		move.w	#sfx_Teleport,d0
		jsr		(PlaySound_Special).l
		bra.w	Sonic_DashResetScr
; ---------------------------------------------------------------------------
 
Sonic_DashCharge:				; If still charging the dash...
		cmpi.b	#$1E,obRevSpeed(a0)
		beq.s	Sonic_DashResetScr
		addi.b	#1,obRevSpeed(a0)
		
 
Sonic_DashResetScr:
		addq.l	#4,sp			; increase stack ptr
		cmpi.w	#$60,(v_lookshift).w
		beq.s	@finish
		bcc.s	@skip
		addq.w	#4,(v_lookshift).w
 
	@skip:
		subq.w	#2,(v_lookshift).w
 
	@finish:
		bsr.w	Player_LevelBound
		bra.w	Player_AnglePos
		