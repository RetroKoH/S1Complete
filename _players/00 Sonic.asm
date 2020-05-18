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
		jsr	Sonic_Modes(pc,d1.w)

loc_12C7E:
		bsr.s	Sonic_Display
		bsr.w	Sonic_RecordPosition
		bsr.w	Sonic_Water
		move.b	(v_anglebuffer).w,$36(a0)
		move.b	($FFFFF76A).w,$37(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	loc_12CA6
		tst.b	obAnim(a0)
		bne.s	loc_12CA6
		move.b	obNextAni(a0),obAnim(a0)

loc_12CA6:
		bsr.w	Sonic_Animate
		tst.b	(f_lockmulti).w
		bmi.s	loc_12CB6
		jsr	(ReactToItem).l

loc_12CB6:
		bsr.w	Sonic_Loops
		bsr.w	Sonic_LoadGfx
		rts	
; ===========================================================================
Sonic_Modes:
		dc.w Sonic_MdNormal-Sonic_Modes
		dc.w Sonic_MdJump-Sonic_Modes
		dc.w Sonic_MdRoll-Sonic_Modes
		dc.w Sonic_MdJump2-Sonic_Modes

		include	"_players\Sonic Display.asm"
		include	"_players\Sonic RecordPosition.asm"
		include	"_players\Sonic Water.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for controlling	Sonic
; ---------------------------------------------------------------------------

Sonic_MdNormal:
		bsr.w	Sonic_Dash
		bsr.w	Sonic_SpinDash
		bsr.w	Sonic_Jump
		bsr.w	Sonic_SlopeResist
		bsr.w	Sonic_Move
		bsr.w	Sonic_Roll
		bsr.w	Sonic_LevelBound
		jsr		(SpeedToPos).l
		bsr.w	Player_AnglePos
		bsr.w	Sonic_SlopeRepel
		rts	
; ===========================================================================

Sonic_MdJump:
		bclr	#staDash,obStatus2(a0)
		bclr	#staSpinDash,obStatus2(a0)
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_JumpDirection
		bsr.w	Sonic_LevelBound
		jsr		(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	loc_12E5C
		subi.w	#$28,obVelY(a0)

loc_12E5C:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_Floor
		rts	
; ===========================================================================

Sonic_MdRoll:
		bsr.w	Sonic_Jump
		bsr.w	Sonic_RollRepel
		bsr.w	Sonic_RollSpeed
		bsr.w	Sonic_LevelBound
		jsr		(SpeedToPos).l
		bsr.w	Player_AnglePos
		bsr.w	Sonic_SlopeRepel
		rts	
; ===========================================================================

Sonic_MdJump2:
		bclr	#staDash,obStatus2(a0)
		bclr	#staSpinDash,obStatus2(a0)
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_JumpDirection
		bsr.w	Sonic_LevelBound
		jsr		(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	loc_12EA6
		subi.w	#$28,obVelY(a0)

loc_12EA6:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_Floor
		rts	

		include	"_players\Sonic Move.asm"
		include	"_players\Sonic RollSpeed.asm"
		include	"_players\Sonic JumpDirection.asm"
		include	"_players\Sonic LevelBound.asm"
		include	"_players\Sonic Roll.asm"
		include	"_players\Sonic Jump.asm"
		include	"_players\Sonic JumpHeight.asm"
		include	"_players\Sonic Peelout.asm"
		include	"_players\Sonic SpinDash.asm"
		include	"_players\Sonic SlopeResist.asm"
		include	"_players\Sonic RollRepel.asm"
		include	"_players\Sonic SlopeRepel.asm"
		include	"_players\Sonic JumpAngle.asm"
		include	"_players\Sonic Floor.asm"
		include	"_players\Sonic ResetOnFloor.asm"
		include	"_players\Sonic (part 2).asm"
		include	"_players\Sonic Loops.asm"
		include	"_players\Sonic Drowned.asm"
		include	"_players\Sonic Animate.asm"
		include	"_players\Sonic LoadGfx.asm"