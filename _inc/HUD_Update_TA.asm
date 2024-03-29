; ---------------------------------------------------------------------------
; Subroutine to	update the HUD in Time Attack
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HUD_Update_TA:
;		tst.w	(f_debugmode).w	; is debug mode	on?
;		bne.w	HudDebug	; if yes, branch
;		tst.b	(f_scorecount).w ; does the score need updating?
;		beq.s	@chkrings	; if not, branch

;		clr.b	(f_scorecount).w
;		hudVRAM	$DC80		; set VRAM address
;		move.l	(v_score).w,d1	; load score
;		bsr.w	Hud_Score

;	@chkrings:
		tst.b	(f_ringcount).w	; does the ring	counter	need updating?
		beq.s	@chktime		; if not, branch
		bpl.s	@notzero
		bsr.w	Hud_LoadZero	; reset rings to 0 if Sonic is hit

	@notzero:
		clr.b	(f_ringcount).w
		hudVRAM	$DF40			; set VRAM address
		moveq	#0,d1
		move.w	(v_rings).w,d1	; load number of rings
		bsr.w	Hud_Rings

	@chktime:
		tst.b	(f_timecount).w	; does the time	need updating?
		beq.w	@chkbonus	; if not, branch
		tst.w	(f_pause).w	; is the game paused?
		bne.w	@chkbonus	; if yes, branch
		lea		(v_time).w,a1

		cmpi.l	#(9*$10000)+(59*$100)+59,(a1)+	; is the time 9:59:59?
		beq.w	TimeOver						; if yes, branch
		move.b	(v_centstep).w,d1
		addi.b	#1,d1
		cmpi.b	#3,d1
		bne.s	@skip
		move.b	#0,d1
		
	@skip:
		move.b	d1,(v_centstep).w
		cmpi.b	#2,d1
		beq.s	@skip2
		addi.b	#1,d1
		
	@skip2:
		add.b	d1,-(a1)	; increment centiseconds counter
		cmpi.b	#100,(a1)	; check if passed 100
		bcs.s	@updatecent

		move.b	#0,(a1)
		addq.b	#1,-(a1)	; increment second counter
		cmpi.b	#60,(a1)	; check if passed 60
		bcs.s	@updatetime
		move.b	#0,(a1)
		addq.b	#1,-(a1)	; increment minute counter
		cmpi.b	#9,(a1)		; check if passed 9
		bcs.s	@updatetime
		move.b	#9,(a1)		; keep as 9

	@updatetime:
		hudVRAM	$DD80
		moveq	#0,d1
		move.b	(v_timemin).w,d1 ; load	minutes
		bsr.w	Hud_Mins
		hudVRAM	$DE00
		moveq	#0,d1
		move.b	(v_timesec).w,d1 ; load	seconds
		bsr.w	Hud_Secs
	@updatecent:
		hudVRAM	$DEC0
		moveq	#0,d1
		move.b	(v_timecent).w,d1 ; load centiseconds
		bsr.w	Hud_Secs

	@chkbonus:
		tst.b	(f_endactbonus).w ; do time/ring bonus counters need updating?
		beq.s	@finish		; if not, branch
		clr.b	(f_endactbonus).w
		locVRAM	$AE00
		moveq	#0,d1
		move.w	(v_timebonus).w,d1 ; load time bonus
		bsr.w	Hud_TimeRingBonus
		moveq	#0,d1
		move.w	(v_ringbonus).w,d1 ; load ring bonus
		bsr.w	Hud_TimeRingBonus

	@finish:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed HUD patterns ("0", "')
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Base_TA:
		lea		($C00000).l,a6
		bsr.w	Hud_Rings
		locVRAM	$DC40 ; All unc data such as Score, etc, starts here
		lea		Hud_TilesBaseTA(pc),a2
		move.w	#$E,d2

Hud_BaseCont:
		lea		Art_Hud(pc),a1

	@1C842:
		move.w	#$F,d1
		move.b	(a2)+,d0
		bmi.s	@1C85E
		ext.w	d0
		lsl.w	#5,d0
		lea		(a1,d0.w),a3

	@1C852:
		move.l	(a3)+,(a6)
		dbf		d1,@1C852

	@1C858:
		dbf		d2,@1C842

		rts	
; ===========================================================================

	@1C85E:
		move.l	#0,(a6)
		dbf		d1,@1C85E

		bra.s	@1C858
; End of function Hud_Base_TA

; ===========================================================================
Hud_TilesBaseTA:	dc.b $FF, $FF, $FF, $FF, $FF, $0,  $18,	 0,  0, $1A, 0,  0
;					      ''  ''   ''   ''   ''   '0'  "'"  '0' '0' '"' '0' '0'
					dc.b $FF, $FF, 0, 0
; ===========================================================================
