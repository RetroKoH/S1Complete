; ---------------------------------------------------------------------------
; Object 2E - contents of monitors
; ---------------------------------------------------------------------------

PowerUp:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Pow_Index(pc,d0.w),d1
		jmp		Pow_Index(pc,d1.w)
; ===========================================================================
Pow_Index:
		dc.w Pow_Init-Pow_Index
		dc.w Pow_Move-Pow_Index
		dc.w Pow_Delete-Pow_Index
; ===========================================================================

Pow_Init:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$680,obGfx(a0)
		move.b	#$24,obRender(a0)
		move.w	#$180,obPriority(a0)
		move.b	#8,obActWid(a0)
		move.w	#-$300,obVelY(a0)
		moveq	#0,d0
		move.b	obAnim(a0),d0	; get subtype
		addq.b	#2,d0
		move.b	d0,obFrame(a0)	; use correct frame
		movea.l	#Map_Monitor,a1
		add.b	d0,d0
		adda.w	(a1,d0.w),a1
		addq.w	#1,a1
		move.l	a1,obMap(a0)

Pow_Move:	; Routine 2
		tst.w	obVelY(a0)	; is object moving?
		bpl.w	Pow_Checks	; if not, branch
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)	; reduce object	speed
		bra.w	DisplaySprite
; ===========================================================================

Pow_Checks:
		addq.b	#2,obRoutine(a0)
		move.w	#29,obTimeFrame(a0) ; display icon for half a second
		moveq	#0,d0
		move.b	obAnim(a0),d0
		add.w	d0,d0
		move.w	Pow_Types(pc,d0.w),d0
		jsr		Pow_Types(pc,d0.w)
		bra.w	DisplaySprite

; Lookup table replaces the old system
; ===========================================================================

Pow_Types:
		dc.w Pow_Null-Pow_Types		; 0 - Static
		dc.w Pow_Eggman-Pow_Types	; 1 - Eggman/Robotnik
		dc.w Pow_Sonic-Pow_Types	; 2 - 1-Up
		dc.w Pow_Shoes-Pow_Types	; 3 - Speed Shoes
		dc.w Pow_Shield-Pow_Types	; 4 - Shield
		dc.w Pow_Invinc-Pow_Types	; 5 - Invincibility
		dc.w Pow_Rings-Pow_Types	; 6 - Rings
		dc.w Pow_S-Pow_Types		; 7 - S
		dc.w Pow_Goggles-Pow_Types	; 8 - Goggles
		dc.w Pow_Clock-Pow_Types	; 9 - Clock
		dc.w Pow_SlowShoes-Pow_Types; $A - Slow Shoes
		dc.w Pow_FShield-Pow_Types	; $B - Flame Shield
		dc.w Pow_BShield-Pow_Types	; $C - Lightning Shield
		dc.w Pow_LShield-Pow_Types	; $D - Bubble Shield
; ===========================================================================

Pow_Eggman:
		move.l  a0,a1            ; move a0 to a1, because Touch_ChkHurt wants the damaging object to be in a1
		move.l  a0,-(sp)         ; push a0 on the stack, and decrement stack pointer
		lea     (v_player).w,a0  ; put Sonic's ram address in a0, because Touch_ChkHurt wants the damaged object to be in a0
		jsr     React_ChkHurt    ; run the Touch_ChkHurt routine
		move.l  (sp)+,a0         ; pop the previous value of a0 from the stack, and increment stack pointer
Pow_Null:
		rts						; Eggman monitor does nothing
; ===========================================================================

Pow_Sonic:
ExtraLife:
		cmpi.b	#$63,(v_lives).w	; are lives at max?
		beq.s	@playbgm
		addq.b	#1,(v_lives).w	; add 1 to number of lives
		addq.b	#1,(f_lifecount).w ; update the lives counter
	@playbgm:
		music	bgm_ExtraLife,1,0,0	; play extra life music
; ===========================================================================

Pow_Shoes:
		bset	#stsShoes,(v_status_secondary).w	; set shoes flag
		move.b	#$96,(v_player+obShoes).w		; time limit for the power-up
		movem.l a0-a2,-(sp)						; Move a0, a1 and a2 onto stack
		lea     (v_player).w,a0					; Load Sonic to a0
		lea		(v_sonspeedmax).w,a2			; Load Sonic_top_speed into a2
		jsr		ApplySpeedSettings				; Fetch Speed settings
		movem.l (sp)+,a0-a2						; Move a0, a1 and a2 from stack
		btst  	#stsSuper,(v_status_secondary).w	; Is Sonic in his Super form?
		bne.s	@nomusic							; if yes, branch
		tst.b	(f_lockscreen).w		; is boss mode on?
		bne.s	@nomusic				; if yes, branch
		cmpi.w	#$C,(v_air).w			; is drowning countdown active?
		bls.s	@nomusic				; if yes, branch
		music	bgm_Speedup,1,0,0		; speed	up the music

	@nomusic:
		rts
; ===========================================================================

Pow_Shield:
		andi.b	#stsRmvShield,(v_status_secondary).w	; remove shield status
		bset	#stsShield,(v_status_secondary).w		; give Sonic a blue shield
		move.b	#id_ShieldItem,(v_shieldspace).w		; load shield object
		clr.b	(v_shieldspace+obAnim).w
		clr.b	(v_shieldspace+obRoutine).w
		music	sfx_Shield,1,0,0						; play shield sound
; ===========================================================================

Pow_Invinc:
		btst  	#stsSuper,(v_status_secondary).w	; Is Sonic in his Super form?
		bne.s	@nomusic							; if yes, branch and don't do anything.
		bset	#stsInvinc,(v_status_secondary).w	; make Sonic invincible
		move.b	#$96,(v_player+obInvinc).w			; time limit for the power-up
		move.b	#id_ShieldItem,(v_invincspace).w	; load stars object ($3801)
		move.b	#1,(v_invincspace+obAnim).w
		move.b	#id_ShieldItem,(v_invincspace+$40).w	; load stars object ($3802)
		move.b	#2,(v_invincspace+$40+obAnim).w
		move.b	#id_ShieldItem,(v_invincspace+$80).w	; load stars object ($3803)
		move.b	#3,(v_invincspace+$80+obAnim).w
		move.b	#id_ShieldItem,(v_invincspace+$C0).w	; load stars object ($3804)
		move.b	#4,(v_invincspace+$C0+obAnim).w
		tst.b	(f_lockscreen).w					; is boss mode on?
		bne.s	@nomusic							; if yes, branch
		cmpi.w	#$C,(v_air).w			; is drowning countdown active?
		bls.s	@nomusic				; if yes, branch
		music	bgm_Invincible,1,0,0	; play invincibility music

	@nomusic:
		rts
; ===========================================================================

Pow_NoMusic:
		rts	
; ===========================================================================

Pow_Rings:
		addi.w	#10,(v_rings).w	  ; add 10 rings to the number of rings you have
		cmpi.w  #999,(v_rings).w  ; does Sonic have 999+ rings?
		bcs.s   @chk100           ; if not, branch
		move.w  #999,(v_rings).w  ; cap rings at 999.

	@chk100:
		ori.b	#1,(f_ringcount).w ; update the ring counter
		cmpi.w	#100,(v_rings).w ; check if you have 100 rings
		bcs.s	Pow_RingSound
		bset	#1,(v_lifecount).w
		beq.w	ExtraLife
		cmpi.w	#200,(v_rings).w ; check if you have 200 rings
		bcs.s	Pow_RingSound
		bset	#2,(v_lifecount).w
		beq.w	ExtraLife

	Pow_RingSound:
		music	sfx_Ring,1,0,0	; play ring sound
; ===========================================================================

Pow_S: ; Will make character Super
Pow_Goggles: ; Temporary drowning protection
Pow_Clock: ; Used in Time Attack OR used to freeze objects
Pow_SlowShoes: ; Used to slow down the player
		rts
; ===========================================================================

Pow_FShield:
		andi.b	#stsRmvShield,(v_status_secondary).w	; remove shield status
		bset	#stsShield,(v_status_secondary).w		; give Sonic a shield
		bset	#stsFlame,(v_status_secondary).w ; give Sonic a flame shield
		move.b	#id_ShieldItem,(v_shieldspace).w ; load shield object ($38)
		clr.b	(v_shieldspace+obRoutine).w
		move.b	#5,(v_shieldspace+obAnim).w
		music	sfx_Shield,1,0,0				; play shield sound
; ===========================================================================

Pow_BShield:
		andi.b	#stsRmvShield,(v_status_secondary).w	; remove shield status
		bset	#stsShield,(v_status_secondary).w		; give Sonic a shield
		bset	#stsBubble,(v_status_secondary).w ; give Sonic a bubble shield
		move.b	#id_ShieldItem,(v_shieldspace).w ; load shield object ($38)
		clr.b	(v_shieldspace+obRoutine).w
		move.b	#7,(v_shieldspace+obAnim).w
		music	sfx_Shield,1,0,0				; play shield sound
; ===========================================================================

Pow_LShield:
		andi.b	#stsRmvShield,(v_status_secondary).w	; remove shield status
		bset	#stsShield,(v_status_secondary).w		; give Sonic a shield
		bset	#stsLightning,(v_status_secondary).w ; give Sonic a lightning shield
		move.b	#id_ShieldItem,(v_shieldspace).w ; load shield object ($38)
		clr.b	(v_shieldspace+obRoutine).w
		move.b	#$A,(v_shieldspace+obAnim).w
		music	sfx_Shield,1,0,0				; play shield sound
; ===========================================================================

Pow_Delete:	; Routine 4
		subq.w	#1,obTimeFrame(a0)
		bmi.w	DeleteObject	; delete after half a second
		bra.w	DisplaySprite
