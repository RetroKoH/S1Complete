; ---------------------------------------------------------------------------
; Subroutine to react to obColType(a0)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ReactToItem:
		nop
		jsr	Touch_Rings

;		tst.b	character_id(a0)			; is the player character Sonic?
;		bne.s	@noInstaShield				; if not, branch
		move.b	(v_status_secondary).w,d0	; does the player have a Shield or Invincibility?
		andi.b	#stsChkShield,d0
		bne.s	@noInstaShield				; if yes, branch
; By this point, we're focussing purely on the Insta-Shield
		cmpi.b	#1,obJumpFlag(a0)			; is the insta-shield active?
		bne.s	@noInstaShield				; if not, branch
		move.b	(v_status_secondary).w,d0
		move.w	d0,-(sp)
		bset	#stsInvinc,(v_status_secondary).w		; Set invincibility
		move.w	obX(a0),d2
		move.w	obY(a0),d3
		subi.w	#$18,d2
		subi.w	#$18,d3
		move.w	#$30,d4
		move.w	#$30,d5
		bsr.s	@chkobjecttype						; check collision flags to see if object is negated by insta-shield
		move.w	(sp)+,d0
		btst	#stsInvinc,d0
		bne.s	@skipclr							; if yes, branch
		bclr	#stsInvinc,(v_status_secondary).w	; otherwise, remove invincibility

	@skipclr:
		moveq	#0,d0
		rts

	@noInstaShield:
		move.w	obX(a0),d2	; load Sonic's x-axis position
		move.w	obY(a0),d3	; load Sonic's y-axis position
		subq.w	#8,d2
		moveq	#0,d5
		move.b	obHeight(a0),d5	; load Sonic's height
		subq.b	#3,d5
		sub.w	d5,d3
		cmpi.b	#aniID_SpinDash,obAnim(a0)
		beq.s	@short
	
		cmpi.b	#aniID_Duck,obAnim(a0)
		bne.s	@notducking
		
	@short:
		addi.w	#$C,d3
		moveq	#$A,d5
		
	@notducking:
		move.w	#$10,d4
		add.w	d5,d5
	@chkobjecttype:
		lea		(v_lvlobjspace).w,a1 ; set object RAM start address
		move.w	#$5F,d6

@loop:
		tst.b	obRender(a1)
		bpl.s	@next
		move.b	obColType(a1),d0 ; load collision type
		bne.s	@proximity	; if nonzero, branch

	@next:
		lea		$40(a1),a1	; next object RAM
		dbf		d6,@loop	; repeat $5F more times

		moveq	#0,d0
		rts	
; ===========================================================================
@sizes:		;   width, height
		dc.b  $14, $14		; $01
		dc.b   $C, $14		; $02
		dc.b  $14,  $C		; $03
		dc.b	4, $10		; $04
		dc.b   $C, $12		; $05
		dc.b  $10, $10		; $06
		dc.b	6,   6		; $07
		dc.b  $18,  $C		; $08
		dc.b   $C, $10		; $09
		dc.b  $10,  $C		; $0A
		dc.b	8,   8		; $0B
		dc.b  $14, $10		; $0C
		dc.b  $14,   8		; $0D
		dc.b   $E,  $E		; $0E
		dc.b  $18, $18		; $0F
		dc.b  $28, $10		; $10
		dc.b  $10, $18		; $11
		dc.b	8, $10		; $12
		dc.b  $20, $70		; $13
		dc.b  $40, $20		; $14
		dc.b  $80, $20		; $15
		dc.b  $20, $20		; $16
		dc.b	8,   8		; $17
		dc.b	4,   4		; $18
		dc.b  $20,   8		; $19
		dc.b   $C,  $C		; $1A
		dc.b	8,   4		; $1B
		dc.b  $18,   4		; $1C
		dc.b  $28,   4		; $1D
		dc.b	4,   8		; $1E
		dc.b	4, $18		; $1F
		dc.b	4, $28		; $20
		dc.b	4, $20		; $21
		dc.b  $18, $18		; $22
		dc.b   $C, $18		; $23
		dc.b  $48,   8		; $24
; ===========================================================================

@proximity:
		andi.w	#$3F,d0
		add.w	d0,d0
		lea		@sizes-2(pc,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	obX(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	@outsidex	; branch if not touching
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	@withinx	; branch if touching
		bra.w	@next
; ===========================================================================

@outsidex:
		cmp.w	d4,d0
		bhi.w	@next

@withinx:
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	obY(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	@outsidey	; branch if not touching
		add.w	d1,d1
		add.w	d0,d1
		bcs.s	@withiny	; branch if touching
		bra.w	@next
; ===========================================================================

@outsidey:
		cmp.w	d5,d0
		bhi.w	@next

@withiny:
	@chktype:
		move.b	obColType(a1),d1 ; load collision type
		andi.b	#$C0,d1		; is obColType $40 or higher?
		beq.w	React_Enemy	; if not, branch
		cmpi.b	#$C0,d1		; is obColType $C0 or higher?
		beq.w	React_Special	; if yes, branch
		tst.b	d1		; is obColType $80-$BF?
		bmi.w	React_ChkHurt	; if yes, branch

; obColType is $40-$7F (powerups)

		move.b	obColType(a1),d0
		andi.b	#$3F,d0
		cmpi.b	#6,d0				; is collision type $46	?
		beq.s	React_Monitor		; if yes, branch
		cmpi.b	#$5A,obInvuln(a0)	; is Sonic invincible?
		bcc.w	@invincible			; if yes, branch
		addq.b	#2,obRoutine(a1) 	; advance the object's routine counter

	@invincible:
		rts	
; ===========================================================================

React_Monitor:
		tst.w	obVelY(a0)	; is Sonic moving upwards?
		bpl.s	@movingdown	; if not, branch

		move.w	obY(a0),d0
		subi.w	#$10,d0
		cmp.w	obY(a1),d0
		bcs.s	@donothing
		neg.w	obVelY(a0)	; reverse Sonic's vertical speed
		move.w	#-$180,obVelY(a1)
		tst.b	ob2ndRout(a1)
		bne.s	@donothing
		addq.b	#4,ob2ndRout(a1) ; advance the monitor's routine counter
		rts	
; ===========================================================================

@movingdown:
		cmpi.b	#aniID_Roll,obAnim(a0) ; is Sonic rolling/jumping?
		bne.s	@donothing
		neg.w	obVelY(a0)	; reverse Sonic's y-motion
		addq.b	#2,obRoutine(a1) ; advance the monitor's routine counter

	@donothing:
		rts	
; ===========================================================================

React_Enemy:
		btst	#stsInvinc,(v_status_secondary).w	; is Sonic invincible?
		bne.s	@donthurtsonic	; if yes, branch
		cmpi.b	#aniID_SpinDash,obAnim(a0)	; is Sonic Spin Dashing?
		beq.w	@breakenemy	; if yes, branch
		cmpi.b	#aniID_Roll,obAnim(a0) ; is Sonic rolling/jumping?
		bne.w	React_ChkHurt	; if not, branch

	@donthurtsonic:
		tst.b	obColProp(a1)
		beq.s	@breakenemy

		neg.w	obVelX(a0)	; repel Sonic
		neg.w	obVelY(a0)
		asr		obVelX(a0)
		asr		obVelY(a0)
		clr.b	obColType(a1)
		subq.b	#1,obColProp(a1)
		bne.s	@flagnotclear
		bset	#7,obStatus(a1)

	@flagnotclear:
		rts	
; ===========================================================================

@breakenemy:
		bset	#7,obStatus(a1)
		moveq	#0,d0
		move.w	(v_itembonus).w,d0
		addq.w	#2,(v_itembonus).w ; add 2 to item bonus counter
		cmpi.w	#6,d0
		bcs.s	@bonusokay
		moveq	#6,d0		; max bonus is lvl6

	@bonusokay:
		move.w	d0,$3E(a1)
		move.w	@points(pc,d0.w),d0
		cmpi.w	#$20,(v_itembonus).w ; have 16 enemies been destroyed?
		bcs.s	@lessthan16	; if not, branch
		move.w	#1000,d0	; fix bonus to 10000
		move.w	#$A,$3E(a1)

	@lessthan16:
		bsr.w	AddPoints
		move.b	#id_ExplosionItem,obID(a1) ; change object to explosion
		move.b	#0,obRoutine(a1)
		tst.w	obVelY(a0)
		bmi.s	@bouncedown
		move.w	obY(a0),d0
		cmp.w	obY(a1),d0
		bcc.s	@bounceup
		neg.w	obVelY(a0)
		rts	
; ===========================================================================

	@bouncedown:
		addi.w	#$100,obVelY(a0)
		rts	

	@bounceup:
		subi.w	#$100,obVelY(a0)
		rts	

@points:	dc.w 10, 20, 50, 100	; points awarded div 10

; ===========================================================================

React_Caterkiller:
		move.b	#1,d0
		move.w  obInertia(a0),d1
		bmi.s	@skip
		move.b	#0,d0

	@skip:
		move.b	obStatus(a1),d1
		andi.b	#1,d1
		cmp.b	d0,d1			;are Sonic and the Caterkiller facing the same way?
		bne.s	@hurt			;if not, move on
		btst	#1,obStatus(a0)	;is Sonic in the air?
		bne.s	@hurt			;if so, move on
		btst	#2,obStatus(a0)	;is Sonic spinning?
		beq.s	@hurt			;if not, move on
		moveq	#-1,d0			;else, he's rolling on the ground, and shouldn't be hurt
		rts				
	
@hurt:
		bset	#7,obStatus(a1) ; Caterkiller fix

React_ChkHurt:
		move.b	(v_status_secondary).w,d0
		andi.b	#stsChkShield,d0			; does the player have either a shield or invincibility?
		beq.s	@noPowerUp					; if not, branch
		and.b	obShieldProp(a1),d0			; is the object negated by player's current shield?
		bne.s	@ret						; if yes, branch
		btst	#0,(v_status_secondary).w	; does the player have a shield?
		bne.s	@haveShield					; if yes, branch

	@chkInv:
		btst	#stsInvinc,(v_status_secondary).w	; does Sonic have invincibility?
		bne.s	@ret								; if yes, branch
		cmpi.b	#$54,obID(a1)						; iis this the lava tag?
		bne.s	HurtSonic 							; Branch to standard HurtSonic
		cmpi.b	#difHard,(v_difficulty).w			; is this hard difficulty?
		beq.s	HurtSonic2							; if yes, enable spike bug behavior
		tst.b	(v_player+obInvuln).w				; +++ is Sonic invulnerable?
		bne.s	@ret								; +++ if yes, branch
		bra.s	HurtSonic							; if not, branch to standard routine

		;btst	#stsInvinc,(v_status_secondary).w	; does Sonic have invincibility?
		;beq.s	HurtSonic							; if not, branch

	@ret:
		moveq	#-1,d0
		rts

	@noPowerUp:
		cmpi.b	#1,obJumpFlag(a0)
		bne.s	@chkInv

	@haveShield:
		move.b	obShieldProp(a1),d0
		andi.b	#$10,d0				; is the object supposed to bounce off of shields?
		beq.s	@chkInv					; if not, branch

;Bounce_Projectile:
		move.w	obX(a0),d1
		move.w	obY(a0),d2
		sub.w	obX(a1),d1
		sub.w	obY(a1),d2
		jsr		(CalcAngle).l
		jsr		(CalcSine).l
		muls.w	#-$800,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a1)
		muls.w	#-$800,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a1)
		clr.b	obColType(a1)
		bra.s   @ret
; End of function ReactToItem
; ===========================================================================

; ---------------------------------------------------------------------------
; Hurting Sonic	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HurtSonic:
		nop
		tst.b	obInvuln(a0)	; is Sonic flashing?
		bne.w	HurtSonic_End	; if yes, branch
		movea.l	a1,a2

HurtSonic2:
		btst	#stsShield,(v_status_secondary).w	; does Sonic have a shield?
		bne.s	HurtSonic_HasShield					; if yes, branch
		tst.w	(v_rings).w			; does Sonic have any rings?
		beq.w	HurtSonic_NoRings	; if not, branch

		jsr		(FindFreeObj).l
		bne.s	HurtSonic_HasShield
		move.b	#id_RingLoss,obID(a1) ; load bouncing multi rings object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

HurtSonic_HasShield:
		andi.b	#stsRmvShield,(v_status_secondary).w	; remove shield
		move.b	#4,obRoutine(a0)
		jsr		Sonic_ResetOnFloor ; was bsr.w
		bset	#staAir,obStatus(a0)
		move.w	#-$400,obVelY(a0) ; make Sonic bounce away from the object
		move.w	#-$200,obVelX(a0)
		btst	#staWater,obStatus(a0)	; is Sonic underwater?
		beq.s	@isdry		; if not, branch

		move.w	#-$200,obVelY(a0) ; slower bounce
		move.w	#-$100,obVelX(a0)

	@isdry:
		move.w	obX(a0),d0
		cmp.w	obX(a2),d0
		bcs.s	@isleft		; if Sonic is left of the object, branch
		neg.w	obVelX(a0)	; if Sonic is right of the object, reverse

	@isleft:
		bclr	#staDash,obStatus2(a0)		; clear Dash flag
		bclr	#staSpinDash,obStatus2(a0)	; clear Spin Dash flag
		clr.w	obInertia(a0)
		move.b	#aniID_Hurt,obAnim(a0)
		move.b	#$78,d1			; set temp invincible time to 2 seconds

		cmpi.b	#difHard,(v_difficulty).w
		bne.s	@notHard
		lsr.b	#1,d1			;  set temp invincible time to 1 second

	@notHard:
		move.b	d1,obInvuln(a0)
		move.w	#sfx_Death,d0	; load normal damage sound
		cmpi.b	#id_Spikes,(a2)	; was damage caused by spikes?
		bne.s	@sound		; if not, branch
		cmpi.b	#id_Harpoon,(a2) ; was damage caused by LZ harpoon?
		bne.s	@sound		; if not, branch
		move.w	#sfx_HitSpikes,d0 ; load spikes damage sound

	@sound:
		jsr	(PlaySound_Special).l
		moveq	#-1,d0

HurtSonic_End:
		rts	
; ===========================================================================

HurtSonic_NoRings:
		tst.w	(f_debugmode).w		; is debug mode	cheat on?
		bne.w	HurtSonic_HasShield	; if yes, branch

; ---------------------------------------------------------------------------
; Subroutine to	kill Sonic
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


KillSonic:
		tst.w	(v_debuguse).w				; is debug mode	active?
		bne.s	@dontdie					; if yes, branch
		bclr	#1,(v_status_secondary).w	; remove invincibility
		move.b	#6,obRoutine(a0)
		jsr		Sonic_ResetOnFloor			; was bsr.w
		bset	#1,obStatus(a0)
		move.w	#-$700,obVelY(a0)
		move.w	#0,obVelX(a0)
		move.w	#0,obInertia(a0)
		move.b	#aniID_Death,obAnim(a0)
		bset	#7,obGfx(a0)
		move.w	#sfx_Death,d0				; play normal death sound
		cmpi.b	#id_Spikes,obID(a2)			; check	if you were killed by spikes
		bne.s	@sound
		move.w	#sfx_HitSpikes,d0			; play spikes death sound

	@sound:
		jsr	(PlaySound_Special).l

	@dontdie:
		moveq	#-1,d0
		rts	
; End of function KillSonic


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


React_Special:
		move.b	obColType(a1),d1
		andi.b	#$3F,d1
		cmpi.b	#$B,d1		; is collision type $CB	?
		beq.s	@caterkiller	; if yes, branch
		cmpi.b	#$C,d1		; is collision type $CC	?
		beq.s	@yadrin		; if yes, branch
		cmpi.b	#$17,d1		; is collision type $D7	?
		beq.s	@D7orE1		; if yes, branch
		cmpi.b	#$21,d1		; is collision type $E1	?
		beq.s	@D7orE1		; if yes, branch
		rts	
; ===========================================================================

@caterkiller:
		bra.w	React_Caterkiller
; ===========================================================================

@yadrin:
		sub.w	d0,d5
		cmpi.w	#8,d5
		bcc.s	@normalenemy
		move.w	obX(a1),d0
		subq.w	#4,d0
		btst	#0,obStatus(a1)
		beq.s	@noflip
		subi.w	#$10,d0

	@noflip:
		sub.w	d2,d0
		bcc.s	@loc_1B13C
		addi.w	#$18,d0
		bcs.s	@loc_1B140
		bra.s	@normalenemy
; ===========================================================================

	@loc_1B13C:
		cmp.w	d4,d0
		bhi.s	@normalenemy

	@loc_1B140:
		bra.w	React_ChkHurt
; ===========================================================================

	@normalenemy:
		bra.w	React_Enemy
; ===========================================================================

@D7orE1:
		addq.b	#1,obColProp(a1)
		rts	
; End of function React_Special
