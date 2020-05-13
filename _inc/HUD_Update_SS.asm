; ---------------------------------------------------------------------------
; Subroutine to	update the HUD in the Special Stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HUD_Update_SS:
		lea		($C00000).l,a6
		tst.w	(f_debugmode).w	; is debug mode	on?
		bne.w	HudDebug_SS	; if yes, branch

	@chkrings:
		tst.b	(f_ringcount).w	; does the ring	counter	need updating?
		beq.s	Hud_ChkLives_SS	; if not, branch
		bpl.s	@dorings
		bsr.w	Hud_LoadZero_SS

	@dorings:
		clr.b	(f_ringcount).w
		hudVRAM	$44A0;$4520	;Mercury Macros
		moveq	#0,d1
		move.w	(v_rings).w,d1	; load number of rings
		bsr.w	Hud_Rings

Hud_ChkLives_SS:
		tst.b	(f_lifecount).w ; does the lives counter need updating?
		beq.s	@return		; if not, branch
		clr.b	(f_lifecount).w
		bsr.w	Hud_Lives_SS

	@return:
		rts
; ===========================================================================

HudDebug_SS:				; XREF: HUD_Update
		bsr.w	HudDb_XY_SS
		tst.b	(f_ringcount).w	; does the ring	counter	need updating?
		beq.s	HudDb_ObjCount_SS	; if not, branch
		bpl.s	HudDb_Rings_SS
		bsr.w	Hud_LoadZero_SS

HudDb_Rings_SS:
		clr.b	(f_ringcount).w
		hudVRAM	$44A0 ;$4520	;Mercury Macros
		moveq	#0,d1
		move.w	(v_rings).w,d1	; load number of rings
		bsr.w	Hud_Rings

HudDb_ObjCount_SS:
		hudVRAM	$4420 ;$44A0	;Mercury Macros
		moveq	#0,d1
		move.b	(v_spritecount).w,d1 ; load "number of objects" counter
		bsr.w	Hud_Secs
		tst.b	(f_lifecount).w ; does the lives counter need updating?
		beq.s	@return		; if not, branch
		clr.b	(f_lifecount).w
		bsr.w	Hud_Lives_SS

	@return:
		rts
; End of function HUD_Update_SS

; ---------------------------------------------------------------------------
; Subroutine to	load "0" on the	HUD in the Special Stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_LoadZero_SS:				; XREF: HUD_Update_SS
		locVRAM	$44A0 ;$4520	;Mercury Macros
		lea		Hud_TilesZero(pc),a2
		move.w	#2,d2
		bra.w	loc_1C83E
; End of function Hud_LoadZero_SS

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed HUD patterns ("E", "0", colon) in Special Stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Base_SS:				; XREF: GM_Special
		lea		($C00000).l,a6
		bsr.w	Hud_Lives_SS
		locVRAM	$41A0 ;$4220	;Mercury Macros
		lea		Hud_TilesBase(pc),a2
		move.w	#$E,d2
		bra.w	loc_1C83E
; End of function Hud_Base_SS

; ---------------------------------------------------------------------------
; Subroutine to	load debug mode	numbers	patterns in Special Stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudDb_XY_SS:				; XREF: HudDebug_SS
		locVRAM	$41A0 ;$4220	;Mercury Macros
		move.w	(v_screenposx).w,d1 ; load camera x-position
		swap	d1
		move.w	(v_player+obX).w,d1 ; load Sonic's x-position
		bsr.w	HudDb_XY2
		move.w	(v_screenposy).w,d1 ; load camera y-position
		swap	d1
		move.w	(v_player+obY).w,d1 ; load Sonic's y-position
		bra.w	HudDb_XY2
; End of function HudDb_XY_SS

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed lives	counter	patterns in Special Stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Lives_SS:				; XREF: Hud_ChkLives_SS
		hudVRAM	$4680 ;$4700	;Mercury Macros
		moveq	#0,d1
		move.b	(v_lives).w,d1	; load number of lives
		lea		(Hud_10).l,a2
		moveq	#1,d6
		moveq	#0,d4
		lea		Art_LivesNums(pc),a1
		bra.w	Hud_LivesLoop
; End of function Hud_Lives_SS