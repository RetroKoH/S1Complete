;
; Applies to Sonic, Ray, Knuckles, and Mighty. Amy doesn't Spin Dash, and Metal Sonic uses a CD style Spindash
; Tails uses a slightly modified variation.

Sonic_SpinDash:
		btst	#0,obDashFlag(a0)
		bne.s	Sonic_UpdateSpindash          ; skip to updating spindash
		cmpi.b	#aniID_Duck,obAnim(a0)
		bne.s	locret_1AC8C
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	locret_1AC8C
		move.b	#aniID_Spindash,obAnim(a0)
;		move.w	#sfx_SpinDash,d0       ; sfx_SpinDash
;		jsr		(PlaySound_Special).l
		addq.l	#4,sp
		bset	#0,obDashFlag(a0)
		clr.w	obRevSpeed(a0)
;		cmpi.b	#$C,(v_air).w	; if he's drowning, branch to not make dust
;		bcs.s	@nodust
;		move.b	#1,(v_effectspace+obAnim).w
;	@nodust:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos

locret_1AC8C:
		rts
; ---------------------------------------------------------------------------

Sonic_UpdateSpindash:
		move.b	#aniID_Spindash,obAnim(a0)
		move.b	(v_jpadhold2).w,d0
		btst	#bitDn,d0
		bne.w	Sonic_ChargingSpindash

		; unleash the charged spindash and start rolling quickly:
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0)
		addq.w	#5,obY(a0)
		bclr	#0,obDashFlag(a0)
		moveq	#0,d0
		move.b	obRevSpeed(a0),d0
		add.w	d0,d0
		move.w	#1,obVelX(a0)	; force X speed to nonzero for camera lag's benefit
		move.w	SpinDashSpeeds(pc,d0.w),obInertia(a0)
;		tst.b	(f_supersonic).w
;		beq.s	@notsuper
;		move.w	SpinDashSpeedsSuper(pc,d0.w),obInertia(a0)
;	@notsuper:
		btst	#0,obStatus(a0)	;Mercury Constants - Facing
		beq.s	@dontflip
		neg.w	obInertia(a0)

	@dontflip:
		bset	#2,obStatus(a0)	;Mercury Constants - Spin
		bclr	#7,obStatus(a0)
;		move.b	#0,(v_effectspace+obAnim).w
		move.w	#sfx_Teleport,d0
		jsr	(PlaySound_Special).l
		bra.w	loc_1AD78
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
SpinDashSpeedsSuper:
		dc.w  $B00	; 0
		dc.w  $B80	; 1
		dc.w  $C00	; 2
		dc.w  $C80	; 3
		dc.w  $D00	; 4
		dc.w  $D80	; 5
		dc.w  $E00	; 6
		dc.w  $E80	; 7
		dc.w  $F00	; 8
; ---------------------------------------------------------------------------

Sonic_ChargingSpindash:				; If still charging the dash...
		tst.w	obRevSpeed(a0)
		beq.s	loc_1AD48

		move.w	obRevSpeed(a0),d0
		lsr.w	#5,d0
		sub.w	d0,obRevSpeed(a0)

		bcc.s	loc_1AD48
		clr.w	obRevSpeed(a0)

loc_1AD48:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	loc_1AD78
		;move.w	#(id_SpinDash<<8),obAnim(a0) ; id_SpinDash
		addi.w	#$200,obRevSpeed(a0)
		cmpi.w	#$800,obRevSpeed(a0)
		bcs.s	@sound
		move.w	#$800,obRevSpeed(a0)
	@sound:
;		move.w	#sfx_SpinDash,d0           ; sfx_SpinDash
;		jsr	(PlaySound_Special).l

loc_1AD78:
		addq.l	#4,sp			; increase stack ptr
		cmpi.w	#$60,(v_lookshift).w
		beq.s	loc_1AD8C
		bcc.s	loc_1AD88
		addq.w	#4,(v_lookshift).w

loc_1AD88:
		subq.w	#2,(v_lookshift).w

loc_1AD8C:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
		rts