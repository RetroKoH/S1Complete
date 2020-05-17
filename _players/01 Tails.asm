; ---------------------------------------------------------------------------
; Object 02- Tails
; ---------------------------------------------------------------------------

TailsPlayer:
		tst.w	(v_debuguse).w	; is debug mode	being used?
		beq.s	Tails_Normal	; if not, branch
		jmp		(DebugMode).l
; ===========================================================================

Tails_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Tails_Index(pc,d0.w),d1
		jmp		Tails_Index(pc,d1.w)
; ===========================================================================

Tails_Index:
ptr_Tails_Init:		dc.w Tails_Init-Tails_Index
ptr_Tails_Control:	dc.w Tails_Control-Tails_Index
ptr_Tails_Hurt:		dc.w Tails_Hurt-Tails_Index
ptr_Tails_Death:	dc.w Tails_Death-Tails_Index
ptr_Tails_Reset:	dc.w Tails_ResetLevel-Tails_Index
ptr_Tails_Drown:	dc.w Tails_Drowned-Tails_Index

id_Tails_Init:		equ ptr_Tails_Init-Tails_Index		; 0
id_Tails_Control:	equ ptr_Tails_Control-Tails_Index	; 2
id_Tails_Hurt:		equ ptr_Tails_Hurt-Tails_Index		; 4
id_Tails_Death:		equ ptr_Tails_Death-Tails_Index		; 6
id_Tails_Reset:		equ ptr_Tails_Reset-Tails_Index		; 8
id_Tails_Drown:		equ ptr_Tails_Drown-Tails_Index		; $A
; ===========================================================================

Tails_Init:	; Routine 0
		move.b	#$C,(v_top_solid_bit).w	; MJ: set collision to 1st
		move.b	#$D,(v_lrb_solid_bit).w	; MJ: set collision to 1st
		addq.b	#2,obRoutine(a0)
		move.b	#$F,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.l	#Map_Tails,obMap(a0)
		move.w	#$780,obGfx(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		lea     (v_sonspeedmax).w,a2	; Load top speed into a2
		bsr.w   ApplySpeedSettings		; Fetch Speed settings
		move.b	#id_Effects,(v_effectspace).w
;		move.b	#id_TailsTails,(v_objspace+$380).w ; load Obj03 (Tails' Tails) at $FFFFD000
;		move.w	a0,(v_objspace+$380+parent).w ; set its parent object to this

Tails_Control:	; Routine 2
		tst.w	(f_debugmode).w			; is debug cheat enabled?
		beq.s	Tails_NoDebug			; if not, branch
		btst	#bitB,(v_jpadpress1).w	; is button B pressed?
		beq.s	Tails_NoDebug			; if not, branch
		move.w	#1,(v_debuguse).w		; change Tails into a ring/item
		clr.b	(f_lockctrl).w
		rts
; ===========================================================================

Tails_NoDebug:
		tst.b	(f_lockctrl).w						; are controls locked?
		bne.s	@skipjoypad							; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w 	; enable joypad control

	@skipjoypad:
		btst	#0,(f_lockmulti).w	; are controls locked?
		bne.s	Tails_SkipMode		; if yes, branch
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Tails_Modes(pc,d0.w),d1
		jsr		Tails_Modes(pc,d1.w)

Tails_SkipMode:
		bsr.w	Player_Display
		bsr.w	Player_RecordPosition
		bsr.w	Player_Water
		move.w	(v_anglebuffer).w,obFrontAngle(a0) ; Load to front and rear angles
		tst.b	(f_wtunnelmode).w
		beq.s	Tails_GoAnimate
		cmpi.b	#aniID_Walk,obAnim(a0)
		bne.s	Tails_GoAnimate
		move.b	obNextAni(a0),obAnim(a0)

Tails_GoAnimate:
		bsr.w	Tails_Animate
		tst.b	(f_lockmulti).w
		bmi.s	Tails_SkipReact
		jsr		(ReactToItem).l

Tails_SkipReact:
		bsr.w	Player_Loops
		bra.w	Tails_LoadGfx
; ===========================================================================
Tails_Modes:
		dc.w Tails_MdNormal-Tails_Modes
		dc.w Tails_MdJump-Tails_Modes
		dc.w Tails_MdRoll-Tails_Modes
		dc.w Tails_MdJump2-Tails_Modes
; ===========================================================================

		include	"_players\Tails RollSpeed.asm"
		include	"_players\Tails Roll.asm"
		include	"_players\Tails Jump.asm"
		include	"_players\Tails JumpHeight.asm"
		include	"_players\Tails SpinDash.asm"
		include	"_players\Tails Floor.asm"
		include	"_players\Tails ResetOnFloor.asm"
		include	"_players\Tails Animate.asm"
		include	"_players\Tails LoadGfx.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for controlling	Tails
; ---------------------------------------------------------------------------

Tails_MdNormal:
		bsr.w	Tails_SpinDash
		bsr.w	Tails_Jump
		bsr.w	Player_SlopeResist
		bsr.w	Player_Move
		bsr.w	Tails_Roll
		bsr.w	Player_LevelBound
		jsr		SpeedToPos
		bsr.w	Player_AnglePos
		bra.w	Player_SlopeRepel
; ===========================================================================

Tails_MdJump:
		bclr	#staDash,obStatus2(a0)
		bclr	#staSpinDash,obStatus2(a0)
		bsr.w	Tails_JumpHeight
		bsr.w	Player_JumpDirection
		bsr.w	Player_LevelBound
		jsr		ObjectFall
		btst	#staWater,obStatus(a0)
		beq.s	@noWater
		subi.w	#$28,obVelY(a0)

	@noWater:
		bsr.w	Player_JumpAngle
		bra.w	Tails_Floor	
; ===========================================================================

Tails_MdRoll:
		bsr.w	Tails_Jump
		bsr.w	Player_RollRepel
		bsr.w	Tails_RollSpeed
		bsr.w	Player_LevelBound
		jsr		(SpeedToPos).l
		bsr.w	Player_AnglePos
		bra.w	Player_SlopeRepel	
; ===========================================================================

Tails_MdJump2:
		bclr	#staDash,obStatus2(a0)
		bclr	#staSpinDash,obStatus2(a0)
		bsr.w	Tails_JumpHeight
		bsr.w	Player_JumpDirection
		bsr.w	Player_LevelBound
		jsr		ObjectFall
		btst	#staWater,obStatus(a0)
		beq.s	@noWater
		subi.w	#$28,obVelY(a0)

	@noWater:
		bsr.w	Player_JumpAngle
		bra.w	Tails_Floor
; ===========================================================================


Tails_Hurt:	; Routine 4
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	Tails_Hurt_Normal	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	Tails_Hurt_Normal	; if not, branch
		move.w	#1,(v_debuguse).w ; change Tails into a ring/item
		clr.b	(f_lockctrl).w
		rts

Tails_Hurt_Normal:
		clr.b	(v_cameralag).w
		jsr		(SpeedToPos).l
		addi.w	#$30,obVelY(a0)
		btst	#staWater,obStatus(a0)
		beq.s	@noWater
		subi.w	#$20,obVelY(a0)

	@noWater:
		bsr.w	Tails_HurtStop
		bsr.w	Player_LevelBound
		bsr.w	Player_RecordPosition
		bsr.w	Player_Water		; Added water routine branch to fix hurt splash bug
		bsr.w	Tails_Animate
		bsr.w	Tails_LoadGfx
		jmp		DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to	stop Tails falling after he's been hurt
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Tails_HurtStop:
		bsr.w	Tails_Floor
		btst	#staAir,obStatus(a0)
		bne.s	@skip
		clr.w	obVelY(a0)
		clr.w	obVelX(a0)
		clr.w	obInertia(a0)
		clr.b	(f_lockmulti).w
		move.b	#aniID_Walk,obAnim(a0)
		subq.b	#2,obRoutine(a0)
		move.b	#$78,obInvuln(a0)
		clr.b	obStatus2(a0)

	@skip:
		rts	
; End of function Tails_HurtStop

; ---------------------------------------------------------------------------
; Tails	when he	dies
; ---------------------------------------------------------------------------

Tails_Death:	; Routine 6
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	Tails_Death_Normal	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	Tails_Death_Normal	; if not, branch
		move.w	#1,(v_debuguse).w ; change Tails into a ring/item
		clr.b	(f_lockctrl).w
		rts

Tails_Death_Normal:
		clr.b	(v_cameralag).w
		bsr.w	GameOver
		jsr		ObjectFall
		bsr.w	Player_RecordPosition
		bsr.w	Tails_Animate
		bsr.w	Tails_LoadGfx
		jmp		DisplaySprite

; ---------------------------------------------------------------------------
; Tails	when the level is restarted
; ---------------------------------------------------------------------------

Tails_ResetLevel:; Routine 8
		tst.w	obRestartTimer(a0)
		beq.s	@end
		subq.w	#1,obRestartTimer(a0)	; subtract 1 from time delay
		bne.s	@end
		move.w	#1,(f_restart).w ; restart the level

	@end:
		rts

; ---------------------------------------------------------------------------
; Tails when he's drowning
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_Drowned:
        jsr 	SpeedToPos              ; Make Tails able to move
        addi.w  #$10,obVelY(a0)         ; Apply gravity
        bsr.w   Player_RecordPosition   ; Record position
        bsr.w   Tails_Animate           ; Animate Tails
        bsr.w   Tails_LoadGfx           ; Load Tails's DPLCs
        jsr   	DisplaySprite           ; And finally, display Tails
