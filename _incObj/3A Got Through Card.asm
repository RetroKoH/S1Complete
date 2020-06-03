; ---------------------------------------------------------------------------
; Object 3A - "SONIC GOT THROUGH" title	card
; ---------------------------------------------------------------------------

GotThroughCard:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Got_Index(pc,d0.w),d1
		jmp		Got_Index(pc,d1.w)
; ===========================================================================
Got_Index:
		dc.w Got_ChkPLC-Got_Index    ; 0
		dc.w Got_Move-Got_Index      ; 2
		dc.w Got_Wait-Got_Index      ; 4
		dc.w Got_TimeBonus-Got_Index ; 6
		dc.w Got_Wait-Got_Index      ; 8
		dc.w Got_NextLevel-Got_Index ; $A
		dc.w Got_Wait-Got_Index      ; $C
		dc.w Got_Move2-Got_Index     ; $E
		dc.w loc_C766-Got_Index      ; $10

got_mainX:	equ $30		; position for card to display on
got_finalX:	equ $32		; position for card to finish on
; ===========================================================================

Got_ChkPLC:	; Routine 0
		tst.l	(v_plc_buffer).w ; are the pattern load cues empty?
		beq.s	Got_Main	; if yes, branch
		rts	
; ===========================================================================

Got_Main:
		movea.l	a0,a1
		lea		(Got_Config).l,a2
		moveq	#6,d1
		tst.b	(f_timeattack).w
		beq.s	Got_Loop
		moveq	#3,d1

Got_Loop:
		move.b	#id_GotThroughCard,obID(a1)
		move.w	(a2),obX(a1)	; load start x-position
		move.w	(a2)+,got_finalX(a1) ; load finish x-position (same as start)
		move.w	(a2)+,got_mainX(a1) ; load main x-position
		move.w	(a2)+,obScreenY(a1) ; load y-position
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,d0
		cmpi.b	#6,d0
		bne.s	loc_C5CA
		add.b	(v_act).w,d0	; add act number to frame number
		cmpi.b	#3,(v_act).w
		bne.s	loc_C5CA
		sub.b	#1,d0

	loc_C5CA:
		move.b	d0,obFrame(a1)
		move.l	#Map_Got,obMap(a1)
		move.w	#$8580,obGfx(a1)
		clr.b	obRender(a1)
		lea		$40(a1),a1
		dbf		d1,Got_Loop	; repeat 6 times

; Add to this to implement Time Attack Elements

Got_Move:	; Routine 2
		moveq	#$10,d1		; set horizontal speed
		move.w	got_mainX(a0),d0
		cmp.w	obX(a0),d0	; has item reached its target position?
		beq.s	loc_C61A	; if yes, branch
		bge.s	Got_ChgPos
		neg.w	d1

	Got_ChgPos:
		add.w	d1,obX(a0)	; change item's position

	loc_C5FE:
		move.w	obX(a0),d0
		bmi.s	locret_C60E
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_C60E	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C60E:
		rts	
; ===========================================================================

loc_C610:
		move.b	#$E,obRoutine(a0)
		bra.w	Got_Move2
; ===========================================================================

loc_C61A:
		tst.b	(f_timeattack).w
		bne.s	@timeattackmode
		cmpi.b	#$E,(v_resultspace7+obRoutine).w	; Check routine for RING BONUS object
		beq.s	loc_C610
		cmpi.b	#4,obFrame(a0)
		bne.s	loc_C5FE
		addq.b	#2,obRoutine(a0)
		move.w	#180,obTimeFrame(a0)		; set time delay to 3 seconds
		bra.s	Got_Wait
	@timeattackmode:
		cmpi.b	#$E,(v_resultspace4+obRoutine).w	; Check routine for oval object
		beq.s	loc_C610
		cmpi.b	#5,obFrame(a0)						; Check if oval frame object
		bne.s	loc_C5FE							; because we only want to execute once
		move.b	#$8,obRoutine(a0)
		move.w	#360,obTimeFrame(a0)				; set time delay to 6 seconds

Got_Wait:	; Routine 4, 8, $C
		subq.w	#1,obTimeFrame(a0) ; subtract 1 from time delay
		bne.s	Got_Display
		addq.b	#2,obRoutine(a0)

Got_Display:
		bra.w	DisplaySprite
; ===========================================================================

Got_TimeBonus:	; Routine 6
		bsr.w	DisplaySprite
		move.b	#10,d1				; set score decrement to 10
		move.b	(v_jpadhold1).w,d0
		andi.b	#btnABC,d0			; is A, B or C pressed?
		beq.w	@dontspeedup		; if not, branch
		move.b	#100,d1				; increase score decrement to 100
		
	@dontspeedup:
		move.b	#1,(f_endactbonus).w ; set time/ring bonus update flag
		moveq	#0,d0
		tst.w	(v_timebonus).w		; is time bonus	= zero?
		beq.s	Got_RingBonus		; if yes, branch
		cmp.w	(v_timebonus).w,d1	; compare time bonus to score decrement
		blt.s	@skip				; if it's greater or equal, branch
		move.w	(v_timebonus).w,d1	; else, set the decrement to the remaining bonus
	@skip:
		add.w	d1,d0				; add decrement to score
		sub.w	d1,(v_timebonus).w	; subtract decrement from ring bonus

Got_RingBonus:
		tst.w	(v_ringbonus).w		; is ring bonus	= zero?
		beq.s	Got_ChkBonus		; if yes, branch
		cmp.w	(v_ringbonus).w,d1	; compare ring bonus to score decrement
		blt.s	@skip				; if it's greater or equal, branch
		move.w	(v_ringbonus).w,d1	; else, set the decrement to the remaining bonus
	@skip:
		add.w	d1,d0				; add decrement to score
		sub.w	d1,(v_ringbonus).w	; subtract decrement from ring bonus

Got_ChkBonus:
		tst.w	d0							; is there any bonus?
		bne.s	Got_AddBonus				; if yes, branch
		sfx		sfx_Cash,0,0,0				; play "ker-ching" sound
		addq.b	#2,obRoutine(a0)
		tst.b	(f_timeattack).w			; Time attack mode omits the SBZ2 cutscene
		bne.s	Got_SetDelay
		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w
		bne.s	Got_SetDelay
		addq.b	#4,obRoutine(a0)

Got_SetDelay:
		move.w	#180,obTimeFrame(a0) ; set time delay to 3 seconds

locret_C692:
		rts	
; ===========================================================================

Got_AddBonus:
		jsr		(AddPoints).l
		move.b	(v_vbla_byte).w,d0
		andi.b	#3,d0
		bne.s	locret_C692
		sfx		sfx_Switch,1,0,0	; play "blip" sound
; ===========================================================================

Got_NextLevel:	; Routine $A
		tst.b	(f_timeattack).w
		beq.s	@notTimeAttack
		move.b	#id_MenuScreen,(v_gamemode).w
		clr.b	(v_lastlamp).w
		bra.s	Got_Display2

	@notTimeAttack:
		clr.b	(v_lifecount).w		; clear ring life counter for next zone.
		move.b	(v_zone).w,d0
		cmpi.b 	#id_EndZ,d0
		blt.s	@skip
		subq.b	#1,d0

	@skip:
;		andi.w	#7,d0
		lsl.w	#3,d0
		move.b	(v_act).w,d1
		andi.w	#3,d1
		add.w	d1,d1
		add.w	d1,d0				; d0 contains Zone+Act word

		moveq	#0,d1
		move.b	(v_optgamemode).w,d1
		lsl.b	#3,d1
		cmpi.b	#difEasy,(v_difficulty).w
		bne.s	@skip2
		addq.b	#4,d1
	@skip2:	
		lea		LevelOrderArrays(pc,d1.w),a2
		movea.l (a2),a1			; load correct level array to a1
		adda.l	d0,a1
		move.w	(a1),d0			; load level from level order array
		move.w	d0,(v_zone).w	; set level number
		tst.w	d0
		bne.s	Got_ChkSS
		move.b	#id_Sega,(v_gamemode).w
		bra.s	Got_Display2
; ===========================================================================

Got_ChkSS:
		clr.b	(v_lastlamp).w	; clear	lamppost counter
		tst.b	(f_bigring).w	; has Sonic jumped into	a giant	ring?
		beq.s	VBla_08A	; if not, branch
		move.b	#id_Special,(v_gamemode).w ; set game mode to Special Stage (10)
		bra.s	Got_Display2
; ===========================================================================

VBla_08A:
		move.w	#1,(f_restart).w ; restart level

Got_Display2:
		bra.w	DisplaySprite
; ===========================================================================

LevelOrderArrays:
		dc.l LevelOrder_Classic, LevelOrderEasy_Classic
		dc.l LevelOrder_Original, LevelOrderEasy_Original
		dc.l LevelOrder_Handheld, LevelOrderEasy_Handheld
		dc.l LevelOrder_Complete, LevelOrderEasy_Complete
; ===========================================================================

Got_Move2:	; Routine $E
		moveq	#$20,d1			; set horizontal speed
		move.w	got_finalX(a0),d0
		cmp.w	obX(a0),d0		; has item reached its finish position?
		beq.s	Got_SBZ2		; if yes, branch
		bge.s	Got_ChgPos2
		neg.w	d1

	Got_ChgPos2:
		add.w	d1,obX(a0)	; change item's position
		move.w	obX(a0),d0
		bmi.s	locret_C748
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_C748	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C748:
		rts	
; ===========================================================================

Got_SBZ2:
		cmpi.b	#4,obFrame(a0)
		bne.w	DeleteObject
		addq.b	#2,obRoutine(a0)
		clr.b	(f_lockctrl).w	; unlock controls
		music	bgm_FZ,1,0,0	; play FZ music
; ===========================================================================

loc_C766:	; Routine $10
		addq.w	#2,(v_limitright2).w
		cmpi.w	#$2100,(v_limitright2).w
		beq.w	DeleteObject
		rts	
; ===========================================================================

		;    x-start,	x-main,	y-main,
		;				routine, frame number

Got_Config:	dc.w 4,		$124,	$BC		; "_____ HAS"		$D5C0
		dc.b 				2,	0

		dc.w -$120,	$120,	$D0			; "PASSED"			$D600
		dc.b 				2,	1

		dc.w $40C,	$14C,	$D6			; "ACT" 1/2/3		$D640
		dc.b 				2,	6

		dc.w $20C,	$14C,	$CC			; oval				$D680
		dc.b 				2,	5

		dc.w $520,	$120,	$EC			; score				$D6C0
		dc.b 				2,	2

		dc.w $540,	$120,	$FC			; time bonus		$D700
		dc.b 				2,	3

		dc.w $560,	$120,	$10C		; ring bonus		$D740
		dc.b 				2,	4
; ===========================================================================
