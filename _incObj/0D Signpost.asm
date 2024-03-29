; ---------------------------------------------------------------------------
; Object 0D - signpost at the end of a level
; ---------------------------------------------------------------------------

Signpost:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Sign_Index(pc,d0.w),d1
		jsr		Sign_Index(pc,d1.w)
		lea		(Ani_Sign).l,a1
		bsr.w	AnimateSprite

		; The below checks how close to the signpost the camera is,
		; If the sign is nearly onscreen, the art loads.
		move.w	(v_player+obX).w,d0		; Get the Character's X position.
		addi.w	#$E0,d0					; add 224 to it.
		sub.w	obX(a0),d0			; Subtract the signpost's x postion.
		tst.w	d0						; Check if d0 is 0 or great (Sonic is less than
		blt.s	@skip					; If d0 is lower than 0, branch.

; Add this to prevent DPLCs from loading AFTER the signpost stops spinning
; This will prevent graphic bugs in the Special Stage
		cmpi.b	#6,obRoutine(a0)
		bgt.s	@skip
		bsr.w	Signpost_LoadGfx
	@skip:
		out_of_range	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Sign_Index:
		dc.w Sign_Main-Sign_Index
		dc.w Sign_Touch-Sign_Index
		dc.w Sign_Spin-Sign_Index
		dc.w Sign_SonicRun-Sign_Index
		dc.w Sign_Exit-Sign_Index

spintime:		equ $30		; time for signpost to spin
sparkletime:	equ $32		; time between sparkles
sparkle_id:		equ $34		; counter to keep track of sparkles
; ===========================================================================

Sign_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Sign,obMap(a0)
		move.w	#ArtNem_Signpost,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$18,obActWid(a0)
		move.w	#$200,obPriority(a0)

Sign_Touch:	; Routine 2
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcs.s	@notouch
		cmpi.w	#$20,d0								; is Sonic within $20 pixels of	the signpost?
		bcc.s	@notouch							; if not, branch
		music	sfx_Signpost,0,0,0					; play signpost sound
		move.b	#1,(v_player+obShoes).w				; disable speed shoes - REV C EDIT
		clr.b	(f_timecount).w						; stop time counter
		move.w	(v_limitright2).w,(v_limitleft2).w	; lock screen position
		addq.b	#2,obRoutine(a0)

	@notouch:
		rts	
; ===========================================================================

Sign_Spin:	; Routine 4
		subq.w	#1,spintime(a0)	; subtract 1 from spin time
		bpl.s	@chksparkle	; if time remains, branch
		move.w	#60,spintime(a0) ; set spin cycle time to 1 second
		addq.b	#1,obAnim(a0)	; next spin cycle
		cmpi.b	#3,obAnim(a0)	; have 3 spin cycles completed?
		bne.s	@chksparkle	; if not, branch
		addq.b	#2,obRoutine(a0)

	@chksparkle:
		subq.w	#1,sparkletime(a0) ; subtract 1 from time delay
		bpl.s	@fail		; if time remains, branch
		move.w	#$B,sparkletime(a0) ; set time between sparkles to $B frames
		moveq	#0,d0
		move.b	sparkle_id(a0),d0 ; get sparkle id
		addq.b	#2,sparkle_id(a0) ; increment sparkle counter
		andi.b	#$E,sparkle_id(a0)
		lea		Sign_SparkPos(pc,d0.w),a2 ; load sparkle position data
		bsr.w	FindFreeObj
		bne.s	@fail
		move.b	#id_Rings,obID(a1)	; load rings object
		move.b	#id_Ring_Sparkle,obRoutine(a1) ; jump to ring sparkle subroutine
		move.b	(a2)+,d0
		ext.w	d0
		add.w	obX(a0),d0
		move.w	d0,obX(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	obY(a0),d0
		move.w	d0,obY(a1)
		move.l	#Map_Ring,obMap(a1)
		move.w	#ArtNem_Ring,obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#$100,obPriority(a1)
		move.b	#8,obActWid(a1)

	@fail:
		rts	
; ===========================================================================
Sign_SparkPos:	dc.b -$18,-$10		; x-position, y-position
		dc.b	8,   8
		dc.b -$10,   0
		dc.b  $18,  -8
		dc.b	0,  -8
		dc.b  $10,   0
		dc.b -$18,   8
		dc.b  $18, $10
; ===========================================================================

Sign_SonicRun:	; Routine 6
		sfx		bgm_Fade,0,0,0 ; fade music out at the end of the level
		tst.w	(v_debuguse).w	; is debug mode	on?
		bne.w	locret_ECEE	; if yes, branch
		move.b	#1,(f_lockctrl).w ; lock controls
		move.w	#btnR<<8,(v_jpadhold2).w ; make Sonic run to the right

	loc_EC70:
		tst.b	(v_player).w
		beq.s	loc_EC86
		move.w	(v_player+obX).w,d0
		move.w	(v_limitright2).w,d1
		addi.w	#$128,d1
		cmp.w	d1,d0
		bcs.w	locret_ECEE

	loc_EC86:
		addq.b	#2,obRoutine(a0)

; ---------------------------------------------------------------------------
; Subroutine to	set up bonuses at the end of an	act
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


GotThroughAct:
		tst.b	(v_resultspace).w
		bne.w	locret_ECEE
		move.w	(v_limitright2).w,(v_limitleft2).w

GotThroughAct_TA: ; For SBZ3 Time Attack
		tst.b	(v_resultspace).w
		bne.s	locret_ECEE
		bclr	#stsInvinc,(v_status_secondary).w 	; disable invincibility
		move.b	#id_GotThroughCard,(v_resultspace).w

		move.l  a0,-(sp) 				; save object address to stack
		move.l  #$70000002,($C00004)	; set mode "VRAM Write to $B000"
		lea 	Art_TitleCard,a0		; load title card patterns
		move.l  #((Art_TitleCard_End-Art_TitleCard)/32)-1,d0 ; the title card art lenght, in tiles
		jsr 	LoadUncArt				; load uncompressed art
		move.l  (sp)+,a0				; get object address from stack

		tst.b	(f_timeattack).w		; is this time attack?
		bne.s	@nobonuses				; if yes, branch
		move.b	#1,(f_endactbonus).w
		moveq	#0,d0
		move.b	(v_timemin).w,d0
		mulu.w	#60,d0				; convert minutes to seconds
		moveq	#0,d1
		move.b	(v_timesec).w,d1
		add.w	d1,d0				; add up your time
		divu.w	#15,d0				; divide by 15
		moveq	#$14,d1
		cmp.w	d1,d0				; is time 5 minutes or higher?
		bcs.s	@hastimebonus		; if not, branch
		move.w	d1,d0				; use minimum time bonus (0)

	@hastimebonus:
		add.w	d0,d0
		move.w	TimeBonuses(pc,d0.w),(v_timebonus).w	; set time bonus
		move.w	(v_rings).w,d0							; load number of rings
		mulu.w	#10,d0									; multiply by 10
		move.w	d0,(v_ringbonus).w						; set ring bonus

	@nobonuses:
		sfx		bgm_GotThrough,0,0,0					; play "Sonic got through" music

locret_ECEE:
		rts	
; End of function GotThroughAct

; ===========================================================================
TimeBonuses:
		dc.w 5000, 5000, 1000, 500, 400, 400, 300, 300,	200, 200
		dc.w 200, 200, 100, 100, 100, 100, 50, 50, 50, 50, 0
; ===========================================================================

Sign_Exit:	; Routine 8
		rts	

; ---------------------------------------------------------------------------
; Signpost dynamic pattern loading subroutine
; ---------------------------------------------------------------------------

Signpost_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
;		cmpi.b	#4,d0
;		bne.s	@notchar
;		add.b	(v_player+character_id).w,d0	; Add Character ID to d0
;	For now, only use Sonic's frame

	@notchar:
		lea	(SignpostDynPLC).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5          ; read "number of entries" value
		subq.w	#1,d5
		bmi.s	SignpostDPLC_Return ; if zero, branch
		move.w	#$D000,d4
		move.l	#Art_Signpost,d6

SignpostPLC_ReadEntry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,SignpostPLC_ReadEntry	; repeat for number of entries

SignpostDPLC_Return:
		rts
