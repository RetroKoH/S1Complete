; ---------------------------------------------------------------------------
; Object 01 - Sonic
; ---------------------------------------------------------------------------

SonicPlayer:
		tst.w	(v_debuguse).w	; is debug mode	being used?
		beq.s	Sonic_Normal	; if not, branch
		jmp		(DebugMode).l
; ===========================================================================

Sonic_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Sonic_Index(pc,d0.w),d1
		jmp		Sonic_Index(pc,d1.w)
; ===========================================================================
Sonic_Index:
ptr_Sonic_Init:		dc.w Sonic_Init-Sonic_Index
ptr_Sonic_Control:	dc.w Sonic_Control-Sonic_Index
ptr_Sonic_Hurt:		dc.w Sonic_Hurt-Sonic_Index
ptr_Sonic_Death:	dc.w Sonic_Death-Sonic_Index
ptr_Sonic_Reset:	dc.w Sonic_ResetLevel-Sonic_Index
ptr_Sonic_Drown:	dc.w Sonic_Drowned-Sonic_Index

id_Sonic_Init:		equ ptr_Sonic_Init-Sonic_Index		; 0
id_Sonic_Control:	equ ptr_Sonic_Control-Sonic_Index	; 2
id_Sonic_Hurt:		equ ptr_Sonic_Hurt-Sonic_Index		; 4
id_Sonic_Death:		equ ptr_Sonic_Death-Sonic_Index		; 6
id_Sonic_Reset:		equ ptr_Sonic_Reset-Sonic_Index		; 8
id_Sonic_Drown:		equ ptr_Sonic_Drown-Sonic_Index		; $A
; ===========================================================================

Sonic_Init:	; Routine 0
		move.b	#$C,(v_top_solid_bit).w	; MJ: set collision to 1st
		move.b	#$D,(v_lrb_solid_bit).w	; MJ: set collision to 1st
		addq.b	#2,obRoutine(a0)
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#$780,obGfx(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		lea     (v_sonspeedmax).w,a2	; Load Sonic_top_speed into a2
		bsr.w   ApplySpeedSettings		; Fetch Speed settings
		move.b	#id_Effects,(v_effectspace).w

Sonic_Control:	; Routine 2
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	loc_12C58	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	loc_12C58	; if not, branch
		move.w	#1,(v_debuguse).w ; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts
; ===========================================================================

loc_12C58:
		tst.b	(f_lockctrl).w	; are controls locked?
		bne.s	loc_12C64	; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w ; enable joypad control

loc_12C64:
		btst	#0,(f_lockmulti).w ; are controls locked?
		bne.s	loc_12C7E	; if yes, branch
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Sonic_Modes(pc,d0.w),d1
		jsr		Sonic_Modes(pc,d1.w)

loc_12C7E:
		bsr.s	Player_Display
		bsr.w	Player_RecordPosition
		bsr.w	Player_Water
		move.w	(v_anglebuffer).w,obFrontAngle(a0) ; Load to front and rear angles
		tst.b	(f_wtunnelmode).w
		beq.s	loc_12CA6
		cmpi.b	#aniID_Walk,obAnim(a0)
		bne.s	loc_12CA6
		move.b	obNextAni(a0),obAnim(a0)

loc_12CA6:
		bsr.w	Sonic_Animate
		tst.b	(f_lockmulti).w
		bmi.s	loc_12CB6
		jsr		(ReactToItem).l

loc_12CB6:
		bsr.w	Player_Loops
		bra.w	Sonic_LoadGfx
; ===========================================================================
Sonic_Modes:
		dc.w Sonic_MdNormal-Sonic_Modes
		dc.w Sonic_MdJump-Sonic_Modes
		dc.w Sonic_MdRoll-Sonic_Modes
		dc.w Sonic_MdJump2-Sonic_Modes
; ===========================================================================

		include	"_players\Player Display.asm"
		include	"_players\Player RecordPosition.asm"
		include	"_players\Player Water.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for controlling	Sonic
; ---------------------------------------------------------------------------

Sonic_MdNormal:
		bsr.w	Sonic_Dash
		bsr.w	Sonic_SpinDash
		bsr.w	Sonic_Jump
		bsr.w	Player_SlopeResist
		bsr.w	Player_Move
		bsr.w	Sonic_Roll
		bsr.w	Player_LevelBound
		jsr		SpeedToPos
		bsr.w	Player_AnglePos
		bra.w	Player_SlopeRepel	
; ===========================================================================

Sonic_MdJump:
		bclr	#staDash,obStatus2(a0)
		bclr	#staSpinDash,obStatus2(a0)
		bsr.w	Sonic_JumpHeight
		bsr.w	Player_JumpDirection
		bsr.w	Player_LevelBound
		jsr		ObjectFall
		btst	#staWater,obStatus(a0)
		beq.s	@noWater
		subi.w	#$28,obVelY(a0)

	@noWater:
		bsr.w	Player_JumpAngle
		bra.w	Sonic_Floor	
; ===========================================================================

Sonic_MdRoll:
		bsr.w	Sonic_Jump
		bsr.w	Player_RollRepel
		bsr.w	Sonic_RollSpeed
		bsr.w	Player_LevelBound
		jsr		SpeedToPos
		bsr.w	Player_AnglePos
		bra.w	Player_SlopeRepel
; ===========================================================================

Sonic_MdJump2:
		bclr	#staDash,obStatus2(a0)
		bclr	#staSpinDash,obStatus2(a0)
		bsr.w	Sonic_JumpHeight
		bsr.w	Player_JumpDirection
		bsr.w	Player_LevelBound
		jsr		ObjectFall
		btst	#staWater,obStatus(a0)
		beq.s	@noWater
		subi.w	#$28,obVelY(a0)

	@noWater:
		bsr.w	Player_JumpAngle
		bra.w	Sonic_Floor
; ===========================================================================

		include	"_players\Player Move.asm"
		include	"_players\Sonic RollSpeed.asm"
		include	"_players\Player JumpDirection.asm"
		include	"_players\Player LevelBound.asm"
		include	"_players\Sonic Roll.asm"
		include	"_players\Sonic Jump.asm"
		include	"_players\Sonic JumpHeight.asm"
		include	"_players\Sonic Peelout.asm"
		include	"_players\Sonic SpinDash.asm"
		include	"_players\Player SlopeResist.asm"
		include	"_players\Player RollRepel.asm"
		include	"_players\Player SlopeRepel.asm"
		include	"_players\Player JumpAngle.asm"
		include	"_players\Sonic Floor.asm"
		include	"_players\Sonic ResetOnFloor.asm"

; ---------------------------------------------------------------------------
; Sonic	when he	gets hurt
; ---------------------------------------------------------------------------

Sonic_Hurt:	; Routine 4
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	Sonic_Hurt_Normal	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	Sonic_Hurt_Normal	; if not, branch
		move.w	#1,(v_debuguse).w ; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts

Sonic_Hurt_Normal:
		clr.b	(v_cameralag).w
		jsr		(SpeedToPos).l
		addi.w	#$30,obVelY(a0)
		btst	#staWater,obStatus(a0)
		beq.s	@noWater
		subi.w	#$20,obVelY(a0)

	@noWater:
		bsr.w	Sonic_HurtStop
		bsr.w	Player_LevelBound
		bsr.w	Player_RecordPosition
		bsr.w	Player_Water ; Added water routine branch to fix hurt splash bug
		bsr.w	Sonic_Animate
		bsr.w	Sonic_LoadGfx
		jmp		DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to	stop Sonic falling after he's been hurt
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_HurtStop:
		bsr.w	Sonic_Floor
		btst	#staAir,obStatus(a0)
		bne.s	locret_13860
		clr.w	obVelY(a0)
		clr.w	obVelX(a0)
		clr.w	obInertia(a0)
		clr.b	(f_lockmulti).w
		move.b	#aniID_Walk,obAnim(a0)
		subq.b	#2,obRoutine(a0)
		move.b	#$78,obInvuln(a0)
		clr.b	obStatus2(a0)

locret_13860:
		rts	
; End of function Sonic_HurtStop

; ---------------------------------------------------------------------------
; Sonic	when he	dies
; ---------------------------------------------------------------------------

Sonic_Death:	; Routine 6
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	Sonic_Death_Normal	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	Sonic_Death_Normal	; if not, branch
		move.w	#1,(v_debuguse).w ; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts

Sonic_Death_Normal:
		clr.b	(v_cameralag).w
		bsr.w	GameOver
		jsr		(ObjectFall).l
		bsr.w	Player_RecordPosition
		bsr.w	Sonic_Animate
		bsr.w	Sonic_LoadGfx
		jmp		(DisplaySprite).l

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


GameOver:
		move.w	(v_screenposy).w,d0
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
		bge.w	locret_13900
		move.w	#-$38,obVelY(a0)
		addq.b	#2,obRoutine(a0)
		clr.b	(f_timecount).w	; stop time counter

		cmpi.b	#0,(v_lives).w	; are lives at min?
		beq.s	@skip
		addq.b	#1,(f_lifecount).w ; update lives counter
		subq.b	#1,(v_lives).w	; subtract 1 from number of lives
		bne.s	loc_138D4

	@skip:
		clr.w	obRestartTimer(a0)
		move.b	#id_GameOverCard,(v_objspace+$80).w ; load GAME object
		move.b	#id_GameOverCard,(v_objspace+$C0).w ; load OVER object
		move.b	#1,(v_objspace+$C0+obFrame).w ; set OVER object to correct frame
		clr.b	(f_timeover).w

loc_138C2:
		music	bgm_GameOver,0,0,0	; play game over music
		moveq	#3,d0
		jmp		(AddPLC).l	; load game over patterns
; ===========================================================================

loc_138D4:
		move.w	#60,obRestartTimer(a0)	; set time delay to 1 second
		tst.b	(f_timeover).w	; is TIME OVER tag set?
		beq.s	locret_13900	; if not, branch
		move.w	#0,obRestartTimer(a0)
		move.b	#id_GameOverCard,(v_objspace+$80).w ; load TIME object
		move.b	#id_GameOverCard,(v_objspace+$C0).w ; load OVER object
		move.b	#2,(v_objspace+$80+obFrame).w
		move.b	#3,(v_objspace+$C0+obFrame).w
		bra.s	loc_138C2
; ===========================================================================

locret_13900:
		rts	
; End of function GameOver

; ---------------------------------------------------------------------------
; Sonic	when the level is restarted
; ---------------------------------------------------------------------------

Sonic_ResetLevel:; Routine 8
		tst.w	obRestartTimer(a0)
		beq.s	locret_13914
		subq.w	#1,obRestartTimer(a0)	; subtract 1 from time delay
		bne.s	locret_13914
		move.w	#1,(f_restart).w ; restart the level

	locret_13914:
		rts

; ---------------------------------------------------------------------------
; Sonic when he's drowning
; ---------------------------------------------------------------------------
; Formerly handled by Obj0A: @loc_13F94

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Drowned:
        bsr.w   SpeedToPos              ; Make Sonic able to move
        addi.w  #$10,obVelY(a0)         ; Apply gravity
        bsr.w   Player_RecordPosition    ; Record position
        bsr.w   Sonic_Animate           ; Animate Sonic
        bsr.w   Sonic_LoadGfx           ; Load Sonic's DPLCs
        bra.w   DisplaySprite           ; And finally, display Sonic


		include	"_players\Player Loops.asm"
		include	"_players\Sonic Animate.asm"
		include	"_players\Sonic LoadGfx.asm"
