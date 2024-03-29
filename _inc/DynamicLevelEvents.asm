; ---------------------------------------------------------------------------
; Dynamic level events
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DynamicLevelEvents:
		cmpi.b	#id_Title,(v_gamemode).w	;exit if on the Title
		beq.s	DLE_NoChg
		cmpi.b	#id_Special,(v_gamemode).w	;exit if in a Special Stage
		beq.s	DLE_NoChg
		moveq	#0,d0
		move.b	(v_zone).w,d0
		add.w	d0,d0
		move.w	DLE_Index(pc,d0.w),d0
		jsr		DLE_Index(pc,d0.w)	; run level-specific events
		moveq	#2,d1
		move.w	(v_limitbtm1).w,d0
		sub.w	(v_limitbtm2).w,d0	; has lower level boundary changed recently?
		beq.s	DLE_NoChg			; if not, branch
		bcc.s	loc_6DAC

		neg.w	d1
		move.w	(v_screenposy).w,d0
		cmp.w	(v_limitbtm1).w,d0
		bls.s	loc_6DA0
		move.w	d0,(v_limitbtm2).w
		andi.w	#$FFFE,(v_limitbtm2).w

loc_6DA0:
		add.w	d1,(v_limitbtm2).w
		move.b	#1,(f_bgscrollvert).w

DLE_NoChg:
		rts	
; ===========================================================================

loc_6DAC:
		move.w	(v_screenposy).w,d0
		addq.w	#8,d0
		cmp.w	(v_limitbtm2).w,d0
		bcs.s	loc_6DC4
		btst	#1,(v_player+obStatus).w
		beq.s	loc_6DC4
		add.w	d1,d1
		add.w	d1,d1

loc_6DC4:
		add.w	d1,(v_limitbtm2).w
		move.b	#1,(f_bgscrollvert).w
		rts	
; End of function DynamicLevelEvents

; ===========================================================================
; ---------------------------------------------------------------------------
; Offset index for dynamic level events
; ---------------------------------------------------------------------------
DLE_Index:
		dc.w DLE_GHZ-DLE_Index, DLE_LZ-DLE_Index
		dc.w DLE_MZ-DLE_Index, DLE_SLZ-DLE_Index
		dc.w DLE_SYZ-DLE_Index, DLE_SBZ-DLE_Index
		dc.w DLE_Ending-DLE_Index, DLE_GHZ-DLE_Index
		dc.w DLE_MZ-DLE_Index, DLE_SLZ-DLE_Index
; ===========================================================================
; ---------------------------------------------------------------------------
; Green	Hill Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_GHZ:
		moveq	#0,d0
		move.b	(v_act).w,d0
		lsl.w	#3,d0
		moveq	#0,d1
		move.b	(v_difficulty).w,d1
		lsl.w	#1,d1
		add.w	d1,d0
		move.w	DLE_GHZx(pc,d0.w),d0
		jmp		DLE_GHZx(pc,d0.w)
; ===========================================================================
DLE_GHZx:	; Normal			; Easy				; Hard
		dc.w DLE_GHZ1N-DLE_GHZx, DLE_GHZ1N-DLE_GHZx, DLE_GHZ1N-DLE_GHZx, 0 ; Act 1
		dc.w DLE_GHZ2N-DLE_GHZx, DLE_GHZ2E-DLE_GHZx, DLE_GHZ2N-DLE_GHZx, 0 ; Act 2
		dc.w DLE_GHZ3N-DLE_GHZx, DLE_GHZ3N-DLE_GHZx, DLE_GHZ3N-DLE_GHZx, 0 ; Act 3
; ===========================================================================

DLE_GHZ1N:
		move.w	#$300,(v_limitbtm1).w		; set initial lower y-boundary
		cmpi.w	#$1780,(v_screenposx).w		; has the camera reached $1780 on x-axis?
		bcs.s	@ret						; if not, branch
		move.w	#$400,(v_limitbtm1).w		; set lower y-boundary

	@ret:
		rts
; ===========================================================================

DLE_GHZ2N:
		move.w	#$300,(v_limitbtm1).w		; set initial lower y-boundary
		cmpi.w	#$ED0,(v_screenposx).w
		bcs.s	@ret
		move.w	#$200,(v_limitbtm1).w
		cmpi.w	#$1600,(v_screenposx).w
		bcs.s	@ret
		move.w	#$400,(v_limitbtm1).w
		cmpi.w	#$1D60,(v_screenposx).w
		bcs.s	@ret
		move.w	#$300,(v_limitbtm1).w

	@ret:
		rts
; ===========================================================================

DLE_GHZ2E:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_GHZ2E_Sub(pc,d0.w),d0
		jmp		DLE_GHZ2E_Sub(pc,d0.w)
; ===========================================================================
DLE_GHZ2E_Sub:
		dc.w DLE_GHZ2E_Main-DLE_GHZ2E_Sub
		dc.w DLE_GHZ2E_Boss-DLE_GHZ2E_Sub
		dc.w DLE_GHZ2E_End-DLE_GHZ2E_Sub
; ===========================================================================

DLE_GHZ2E_Main:
		bset	#0,(f_boss_active).w		; Note that this act has a boss

		move.w	#$300,(v_limitbtm1).w	; starting bottom limit
; Move the death plane up just before the platforms section
		cmpi.w	#$ED0,(v_screenposx).w
		bcs.s	@ret
		move.w	#$200,(v_limitbtm1).w
; Move the death plane back down AFTER the platforms section
		cmpi.w	#$1480,(v_screenposx).w
		bcs.s	@ret
		move.w	#$400,(v_limitbtm1).w
; Move death plane back to the default state leading to the boss arena
		cmpi.w	#$1BE0,(v_screenposx).w
		bcc.s	@gotoBoss

	@ret:
		rts
; ===========================================================================
	@gotoBoss:
		move.w	#$300,(v_limitbtm1).w
		addq.b	#2,(v_dle_routine).w
		rts
; ===========================================================================

DLE_GHZ2E_Boss:
		cmpi.w	#$1E0,(v_screenposx).w
		bcc.s	@cont
		subq.b	#2,(v_dle_routine).w

	@cont:
		cmpi.w	#$21E0,(v_screenposx).w
		bcs.s	@end
		bsr.w	FindFreeObj
		bne.s	@music
		move.b	#id_BossGreenHill,obID(a1) ; load GHZ boss object
		move.w	#$22E0,obX(a1)
		move.w	#$280,obY(a1)

	@music:
		music	bgm_Boss,0,1,0	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_Boss,d0
		bra.w	AddPLC		; load boss patterns
; ===========================================================================

	@end:
		rts	
; ===========================================================================

DLE_GHZ2E_End:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts	
; ===========================================================================

DLE_GHZ3N:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_GHZ3N_Sub(pc,d0.w),d0
		jmp		DLE_GHZ3N_Sub(pc,d0.w)
; ===========================================================================
DLE_GHZ3N_Sub:
		dc.w DLE_GHZ3N_Main-DLE_GHZ3N_Sub
		dc.w DLE_GHZ3N_Boss-DLE_GHZ3N_Sub
		dc.w DLE_GHZ3N_End-DLE_GHZ3N_Sub
; ===========================================================================

DLE_GHZ3N_Main:
		bset	#0,(f_boss_active).w		; Note that this act has a boss

		move.w	#$300,(v_limitbtm1).w
		cmpi.w	#$380,(v_screenposx).w
		bcs.s	@ret
		move.w	#$310,(v_limitbtm1).w
		cmpi.w	#$960,(v_screenposx).w
		bcs.s	@ret
		cmpi.w	#$280,(v_screenposy).w
		bcs.s	@gotoBoss
		move.w	#$400,(v_limitbtm1).w
		cmpi.w	#$1380,(v_screenposx).w
		bcc.s	@skip
		move.w	#$4C0,(v_limitbtm1).w
		move.w	#$4C0,(v_limitbtm2).w

	@skip:
		cmpi.w	#$1700,(v_screenposx).w
		bcc.s	@gotoBoss

	@ret:
		rts	
; ===========================================================================

	@gotoBoss:
		move.w	#$300,(v_limitbtm1).w
		addq.b	#2,(v_dle_routine).w
		rts	
; ===========================================================================

DLE_GHZ3N_Boss:
		cmpi.w	#$960,(v_screenposx).w
		bcc.s	@cont
		subq.b	#2,(v_dle_routine).w

	@cont:
		cmpi.w	#$2960,(v_screenposx).w
		bcs.s	@ret
		bsr.w	FindFreeObj
		bne.s	@music
		move.b	#id_BossGreenHill,obID(a1) ; load GHZ boss object
		move.w	#$2A60,obX(a1)
		move.w	#$280,obY(a1)

	@music:
		music	bgm_Boss,0,1,0	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_Boss,d0
		bra.w	AddPLC		; load boss patterns
; ===========================================================================

	@ret:
		rts	
; ===========================================================================

DLE_GHZ3N_End:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Labyrinth Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_LZ:
		moveq	#0,d0
		move.b	(v_act).w,d0
		lsl.w	#3,d0
		moveq	#0,d1
		move.b	(v_difficulty).w,d1
		lsl.w	#1,d1
		add.w	d1,d0
		move.w	DLE_LZx(pc,d0.w),d0
		jmp		DLE_LZx(pc,d0.w)
; ===========================================================================
DLE_LZx:	; Normal			; Easy				; Hard
		dc.w DLE_LZ12N-DLE_LZx, DLE_LZ12N-DLE_LZx, DLE_LZ12N-DLE_LZx, 0 ; Act 1
		dc.w DLE_LZ12N-DLE_LZx, DLE_LZ2E-DLE_LZx, DLE_LZ12N-DLE_LZx, 0 ; Act 2
		dc.w DLE_LZ3N-DLE_LZx, DLE_LZ3N-DLE_LZx, DLE_LZ3N-DLE_LZx, 0 ; Act 3
		dc.w DLE_SBZ3N-DLE_LZx, DLE_SBZ3N-DLE_LZx, DLE_SBZ3N-DLE_LZx, 0 ; SBZ Act 3
; ===========================================================================

DLE_LZ12N:
		rts
; ===========================================================================

DLE_LZ2E:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_LZ2E_Sub(pc,d0.w),d0
		jmp		DLE_LZ2E_Sub(pc,d0.w)
; ===========================================================================
DLE_LZ2E_Sub:
		dc.w DLE_LZ2E_Main-DLE_LZ2E_Sub
		dc.w DLE_LZ2E_Boss-DLE_LZ2E_Sub
		dc.w DLE_LZ2E_End-DLE_LZ2E_Sub
; ===========================================================================

DLE_LZ2E_Main:
		bset	#0,(f_boss_active).w		; Note that this act has a boss

		cmpi.w	#$EF0,(v_screenposx).w
		bcs.s	@end
		move.w	#$E00,(v_limitleft2).w
		move.w	#$34A,(v_limitbtm1).w
		move.w	#$34A,(v_limittop2).w
		addq.b	#2,(v_dle_routine).w

	@end:
		rts	
; ===========================================================================

DLE_LZ2E_Boss:
		cmpi.w	#$10A0,(v_screenposx).w
		bcs.s	@end
		bsr.w	FindFreeObj
		bne.s	@music
		move.b	#id_BossLZ2,obID(a1) ; load test boss object
		move.w	#$1140,obX(a1)
		move.w	#$450,obY(a1)

	@music:
		music	bgm_Boss,0,1,0	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_BossAlt,d0
		bra.w	AddPLC		; load boss patterns
; ===========================================================================

	@end:
		rts
; ===========================================================================

DLE_LZ2E_End:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts
; ===========================================================================

DLE_LZ3N:
		bset	#0,(f_boss_active).w		; Note that this act has a boss

		tst.b	(f_switch+$F).w						; has switch $F	been pressed?
		beq.s	loc_6F28							; if not, branch
		cmpi.l	#Level_LZ3NoWall,(v_lvllayoutfg).w	; MJ: is current layout already set to wall version?
		beq.s	loc_6F28							; MJ: if so, branch to skip
		move.l	#Level_LZ3NoWall,(v_lvllayoutfg).w	; MJ: Set wall version of act 3's layout to be read
		sfx		sfx_Rumbling,0,1,0 					; play rumbling sound

loc_6F28:
		tst.b	(v_dle_routine).w
		bne.s	locret_6F62
		cmpi.w	#$1CA0,(v_screenposx).w
		bcs.s	locret_6F62
		cmpi.w	#$600,(v_screenposy).w
		bcc.s	locret_6F62
		bsr.w	FindFreeObj
		bne.s	loc_6F4A
		move.b	#id_BossLabyrinth,obID(a1) ; load LZ boss object

loc_6F4A:
		music	bgm_Boss,0,1,0	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_Boss,d0
		bra.w	AddPLC		; load boss patterns
; ===========================================================================

locret_6F62:
		rts	
; ===========================================================================

DLE_SBZ3N:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_SBZ3N_Sub(pc,d0.w),d0
		jmp		DLE_SBZ3N_Sub(pc,d0.w)
; ===========================================================================
DLE_SBZ3N_Sub:
		dc.w DLE_SBZ3N_Main-DLE_SBZ3N_Sub
		dc.w DLE_SBZ3N_TA-DLE_SBZ3N_Sub
; ===========================================================================

DLE_SBZ3N_Main:
		bset	#0,(f_boss_active).w	; This act doesn't have a boss, but dont load EndofAct routine

		cmpi.w	#$D00,(v_screenposx).w
		bcs.s	@end
		cmpi.w	#$18,(v_player+obY).w ; has Sonic reached the top of the level?
		bcc.s	@end	; if not, branch

		move.b	#1,(f_lockmulti).w	; freeze Sonic
		tst.b	(f_timeattack).w 	; is this a Time Attack run?
		beq.s	@notTA
		addq.b	#2,(v_dle_routine).w
		clr.w	(v_player+obVelX).w
		clr.w	(v_player+obVelY).w
		clr.b	(f_timecount).w		; stop time counter
		jmp		GotThroughAct_TA

	@notTA:
		clr.b	(v_lastlamp).w
		move.l  (v_score).w,(v_startscore).w	; set level starting score.
		clr.b   (v_lifecount).w					; Reset ring life count at the end of the level.
		move.w	#1,(f_restart).w				; restart level
		move.w	#(id_SBZ<<8)+2,(v_zone).w		; set level number to 0502 (FZ)

	@end:
		rts
; ===========================================================================

DLE_SBZ3N_TA:
		rts

; ---------------------------------------------------------------------------
; Marble Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_MZ:
		moveq	#0,d0
		move.b	(v_act).w,d0
		lsl.w	#3,d0
		moveq	#0,d1
		move.b	(v_difficulty).w,d1
		lsl.w	#1,d1
		add.w	d1,d0
		move.w	DLE_MZx(pc,d0.w),d0
		jmp		DLE_MZx(pc,d0.w)
; ===========================================================================
DLE_MZx:	; Normal			; Easy			; Hard
		dc.w DLE_MZ1N-DLE_MZx, DLE_MZ1N-DLE_MZx, DLE_MZ1N-DLE_MZx, 0
		dc.w DLE_MZ2N-DLE_MZx, DLE_MZ2E-DLE_MZx, DLE_MZ2N-DLE_MZx, 0
		dc.w DLE_MZ3N-DLE_MZx, DLE_MZ3N-DLE_MZx, DLE_MZ3N-DLE_MZx, 0
; ===========================================================================

DLE_MZ1N:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	off_6FB2(pc,d0.w),d0
		jmp		off_6FB2(pc,d0.w)
; ===========================================================================
off_6FB2:
		dc.w loc_6FBA-off_6FB2
		dc.w loc_6FEA-off_6FB2
		dc.w loc_702E-off_6FB2
		dc.w loc_7050-off_6FB2
; ===========================================================================

loc_6FBA:
		move.w	#$1D0,(v_limitbtm1).w
		cmpi.w	#$700,(v_screenposx).w
		bcs.s	locret_6FE8
		move.w	#$220,(v_limitbtm1).w
		cmpi.w	#$D00,(v_screenposx).w
		bcs.s	locret_6FE8
		move.w	#$340,(v_limitbtm1).w
		cmpi.w	#$340,(v_screenposy).w
		bcs.s	locret_6FE8
		addq.b	#2,(v_dle_routine).w

locret_6FE8:
		rts	
; ===========================================================================

loc_6FEA:
		cmpi.w	#$340,(v_screenposy).w
		bcc.s	loc_6FF8
		subq.b	#2,(v_dle_routine).w
		rts	
; ===========================================================================

loc_6FF8:
		move.w	#0,(v_limittop2).w
		cmpi.w	#$E00,(v_screenposx).w
		bcc.s	locret_702C
		move.w	#$340,(v_limittop2).w
		move.w	#$340,(v_limitbtm1).w
		cmpi.w	#$A90,(v_screenposx).w
		bcc.s	locret_702C
		move.w	#$500,(v_limitbtm1).w
		cmpi.w	#$370,(v_screenposy).w
		bcs.s	locret_702C
		addq.b	#2,(v_dle_routine).w

locret_702C:
		rts	
; ===========================================================================

loc_702E:
		cmpi.w	#$370,(v_screenposy).w
		bcc.s	loc_703C
		subq.b	#2,(v_dle_routine).w
		rts	
; ===========================================================================

loc_703C:
		cmpi.w	#$500,(v_screenposy).w
		bcs.s	locret_704E
		cmpi.w	#$B80,(v_screenposx).w
		bcs.s	locret_704E
		move.w	#$500,(v_limittop2).w
		addq.b	#2,(v_dle_routine).w

locret_704E:
		rts	
; ===========================================================================

loc_7050:
		cmpi.w	#$B80,(v_screenposx).w
		bcc.s	loc_76B8
		cmpi.w	#$340,(v_limittop2).w
		beq.s	locret_7072
		subq.w	#2,(v_limittop2).w
		rts
loc_76B8:
		cmpi.w	#$500,(v_limittop2).w
		beq.s	loc_76CE
		cmpi.w	#$500,(v_screenposy).w
		bcs.s	locret_7072
		move.w	#$500,(v_limittop2).w
loc_76CE:

		cmpi.w	#$E70,(v_screenposx).w
		bcs.s	locret_7072
		move.w	#0,(v_limittop2).w
		move.w	#$500,(v_limitbtm1).w
		cmpi.w	#$1430,(v_screenposx).w
		bcs.s	locret_7072
		move.w	#$210,(v_limitbtm1).w

locret_7072:
		rts	
; ===========================================================================

DLE_MZ2N:
		move.w	#$520,(v_limitbtm1).w
		cmpi.w	#$1700,(v_screenposx).w
		bcs.s	@ret
		move.w	#$200,(v_limitbtm1).w

	@ret:
		rts	
; ===========================================================================

DLE_MZ2E:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_MZ2E_Sub(pc,d0.w),d0
		jmp		DLE_MZ2E_Sub(pc,d0.w)
; ===========================================================================
DLE_MZ2E_Sub:
		dc.w DLE_MZ2E_Boss-DLE_MZ2E_Sub
		dc.w DLE_MZ2E_End-DLE_MZ2E_Sub
; ===========================================================================

DLE_MZ2E_Boss:
		bset	#0,(f_boss_active).w		; Note that this act has a boss

		move.w	#$520,(v_limitbtm1).w
		cmpi.w	#$1700,(v_screenposx).w
		bcs.s	@ret
		move.w	#$200,(v_limitbtm1).w
		cmpi.w	#$1A80,(v_screenposx).w
		bcs.s	@ret
		bsr.w	FindFreeObj
		bne.s	@music
		move.b	#id_BossMarble,obID(a1) ; load MZ boss object
		move.w	#$1C70,obX(a1)
		move.w	#$22C,obY(a1)

	@music:
		music	bgm_Boss,0,1,0	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_Boss,d0
		bra.w	AddPLC		; load boss patterns
; ===========================================================================

	@ret:
		rts	
; ===========================================================================

DLE_MZ2E_End:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts	
; ===========================================================================

DLE_MZ3N:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_MZ3N_Sub(pc,d0.w),d0
		jmp		DLE_MZ3N_Sub(pc,d0.w)
; ===========================================================================
DLE_MZ3N_Sub:
		dc.w DLE_MZ3N_Boss-DLE_MZ3N_Sub
		dc.w DLE_MZ3N_End-DLE_MZ3N_Sub
; ===========================================================================

DLE_MZ3N_Boss:
		bset	#0,(f_boss_active).w		; Note that this act has a boss

		move.w	#$720,(v_limitbtm1).w
		cmpi.w	#$1560,(v_screenposx).w
		bcs.s	@ret
		move.w	#$210,(v_limitbtm1).w
		cmpi.w	#$17F0,(v_screenposx).w
		bcs.s	@ret
		bsr.w	FindFreeObj
		bne.s	@music
		move.b	#id_BossMarble,obID(a1) ; load MZ boss object
		move.w	#$19F0,obX(a1)
		move.w	#$22C,obY(a1)

	@music:
		music	bgm_Boss,0,1,0	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_Boss,d0
		bra.w	AddPLC		; load boss patterns
; ===========================================================================

	@ret:
		rts	
; ===========================================================================

DLE_MZ3N_End:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Star Light Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_SLZ:
		moveq	#0,d0
		move.b	(v_act).w,d0
		lsl.w	#3,d0
		moveq	#0,d1
		move.b	(v_difficulty).w,d1
		lsl.w	#1,d1
		add.w	d1,d0
		move.w	DLE_SLZx(pc,d0.w),d0
		jmp		DLE_SLZx(pc,d0.w)
; ===========================================================================
DLE_SLZx:
		dc.w DLE_SLZ12N-DLE_SLZx, DLE_SLZ12N-DLE_SLZx, DLE_SLZ12N-DLE_SLZx, 0 ; Act 1
		dc.w DLE_SLZ12N-DLE_SLZx, DLE_SLZ2E-DLE_SLZx, DLE_SLZ12N-DLE_SLZx, 0 ; Act 2
		dc.w DLE_SLZ3N-DLE_SLZx, DLE_SLZ3N-DLE_SLZx, DLE_SLZ3N-DLE_SLZx, 0 ; Act 3
; ===========================================================================

DLE_SLZ12N:
		rts	
; ===========================================================================

DLE_SLZ2E:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_SLZ2E_Sub(pc,d0.w),d0
		jmp		DLE_SLZ2E_Sub(pc,d0.w)
; ===========================================================================
DLE_SLZ2E_Sub:
		dc.w DLE_SLZ2E_Main-DLE_SLZ2E_Sub
		dc.w DLE_SLZ2E_Boss-DLE_SLZ2E_Sub
		dc.w DLE_SLZ2E_End-DLE_SLZ2E_Sub
; ===========================================================================

DLE_SLZ2E_Main:
		bset	#0,(f_boss_active).w		; Note that this act has a boss

		cmpi.w	#$1DF0,(v_screenposx).w
		bcs.s	@end
		move.w	#$210,(v_limitbtm1).w
		addq.b	#2,(v_dle_routine).w

	@end:
		rts	
; ===========================================================================

DLE_SLZ2E_Boss:
		cmpi.w	#$1F80,(v_screenposx).w
		bcs.s	@end
		bsr.w	FindFreeObj
		bne.s	@music
		move.b	#id_BossStarLight,obID(a1) ; load SLZ boss object
		move.w	#$2108,obX(a1)
		move.w	#$228,obY(a1)

	@music:
		music	bgm_Boss,0,0,0	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_Boss,d0
		bra.w	AddPLC		; load boss patterns
; ===========================================================================

	@end:
		rts	
; ===========================================================================

DLE_SLZ2E_End:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts
; ===========================================================================

DLE_SLZ3N:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_SLZ3N_Sub(pc,d0.w),d0
		jmp		DLE_SLZ3N_Sub(pc,d0.w)
; ===========================================================================
DLE_SLZ3N_Sub:
		dc.w DLE_SLZ3N_Main-DLE_SLZ3N_Sub
		dc.w DLE_SLZ3N_Boss-DLE_SLZ3N_Sub
		dc.w DLE_SLZ3N_End-DLE_SLZ3N_Sub
; ===========================================================================

DLE_SLZ3N_Main:
		bset	#0,(f_boss_active).w		; Note that this act has a boss

		cmpi.w	#$1E70,(v_screenposx).w
		bcs.s	@end
		move.w	#$210,(v_limitbtm1).w
		addq.b	#2,(v_dle_routine).w

	@end:
		rts	
; ===========================================================================

DLE_SLZ3N_Boss:
		cmpi.w	#$2000,(v_screenposx).w
		bcs.s	@end
		bsr.w	FindFreeObj
		bne.s	@music
		move.b	#id_BossStarLight,obID(a1) ; load SLZ boss object
		move.w	#$2188,obX(a1)
		move.w	#$228,obY(a1)

	@music:
		music	bgm_Boss,0,0,0	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_Boss,d0
		bra.w	AddPLC		; load boss patterns
; ===========================================================================

	@end:
		rts	
; ===========================================================================

DLE_SLZ3N_End:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Spring Yard Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_SYZ:
		moveq	#0,d0
		move.b	(v_act).w,d0
		lsl.w	#3,d0
		moveq	#0,d1
		move.b	(v_difficulty).w,d1
		lsl.w	#1,d1
		add.w	d1,d0
		move.w	DLE_SYZx(pc,d0.w),d0
		jmp	DLE_SYZx(pc,d0.w)
; ===========================================================================
DLE_SYZx:	; Normal			; Easy				; Hard
		dc.w DLE_SYZ1N-DLE_SYZx, DLE_SYZ1N-DLE_SYZx, DLE_SYZ1N-DLE_SYZx, 0 ; Act 1
		dc.w DLE_SYZ2N-DLE_SYZx, DLE_SYZ2E-DLE_SYZx, DLE_SYZ2N-DLE_SYZx, 0 ; Act 2
		dc.w DLE_SYZ3N-DLE_SYZx, DLE_SYZ3N-DLE_SYZx, DLE_SYZ3N-DLE_SYZx, 0 ; Act 3
; ===========================================================================

DLE_SYZ1N:
		rts	
; ===========================================================================

DLE_SYZ2N:
		move.w	#$520,(v_limitbtm1).w
		cmpi.w	#$25A0,(v_screenposx).w
		bcs.s	@end
		move.w	#$420,(v_limitbtm1).w
		cmpi.w	#$4D0,(v_player+obY).w
		bcs.s	@end
		move.w	#$520,(v_limitbtm1).w

	@end:
		rts	
; ===========================================================================

DLE_SYZ2E:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	DLE_SYZ2E_Sub(pc,d0.w),d0
		jmp		DLE_SYZ2E_Sub(pc,d0.w)
; ===========================================================================

DLE_SYZ2E_Sub:
		dc.w DLE_SYZ2E_Main-DLE_SYZ2E_Sub
		dc.w DLE_SYZ2E_Boss-DLE_SYZ2E_Sub
		dc.w DLE_SYZ2E_End-DLE_SYZ2E_Sub
; ===========================================================================

DLE_SYZ2E_Main:
		bset	#0,(f_boss_active).w		; Note that this act has a boss

		move.w	#$520,(v_limitbtm1).w
		cmpi.w	#$25A0,(v_screenposx).w
		bcs.s	@end
		move.w	#$420,(v_limitbtm1).w
		cmpi.w	#$4D0,(v_player+obY).w
		bcs.s	@chkBoss
		move.w	#$520,(v_limitbtm1).w

	@chkBoss:
		cmpi.w	#$29C0,(v_screenposx).w
		bcs.s	@end
		bsr.w	FindFreeObj
		bne.s	@end
		move.b	#id_BossBlock,obID(a1) ; load blocks that boss picks up
		move.w	#$2B10,obX(a1)
		move.w	#$4D2,obY(a1)
		addq.b	#2,(v_dle_routine).w

	@end:
		rts	
; ===========================================================================

DLE_SYZ2E_Boss:
		cmpi.w	#$2B00,(v_screenposx).w
		bcs.s	@end
		move.w	#$41C,(v_limitbtm1).w
		bsr.w	FindFreeObj
		bne.s	@music
		move.b	#id_BossSpringYard,obID(a1) ; load SYZ boss object
		move.w	#$2CB0,obX(a1) ; -$100
		move.w	#$42A,obY(a1) ; -$B0

	@music:
		music	bgm_Boss,0,0,0	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_Boss,d0
		bra.w	AddPLC		; load boss patterns
; ===========================================================================

	@end:
		rts	
; ===========================================================================

DLE_SYZ2E_End:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts	
; ===========================================================================

DLE_SYZ3N:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	off_71B2(pc,d0.w),d0
		jmp		off_71B2(pc,d0.w)
; ===========================================================================
off_71B2:
		dc.w DLE_SYZ3N_Main-off_71B2
		dc.w DLE_SYZ3N_Boss-off_71B2
		dc.w DLE_SYZ3N_End-off_71B2
; ===========================================================================

DLE_SYZ3N_Main:
		bset	#0,(f_boss_active).w		; Note that this act has a boss

		cmpi.w	#$2AC0,(v_screenposx).w
		bcs.s	locret_71CE
		bsr.w	FindFreeObj
		bne.s	locret_71CE
		move.b	#id_BossBlock,obID(a1) ; load blocks that boss picks up
		move.w	#$2C10,obX(a1)
		move.w	#$582,obY(a1)
		addq.b	#2,(v_dle_routine).w

locret_71CE:
		rts	
; ===========================================================================

DLE_SYZ3N_Boss:
		cmpi.w	#$2C00,(v_screenposx).w
		bcs.s	locret_7200
		move.w	#$4CC,(v_limitbtm1).w
		bsr.w	FindFreeObj
		bne.s	loc_71EC
		move.b	#id_BossSpringYard,obID(a1) ; load SYZ boss	object
		move.w	#$2DB0,obX(a1)
		move.w	#$4DA,obY(a1)

loc_71EC:
		music	bgm_Boss,0,0,0	; play boss music
		move.b	#1,(f_lockscreen).w ; lock screen
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_Boss,d0
		bra.w	AddPLC		; load boss patterns
; ===========================================================================

locret_7200:
		rts	
; ===========================================================================

DLE_SYZ3N_End:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Scrap	Brain Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_SBZ:
		moveq	#0,d0
		move.b	(v_act).w,d0
		lsl.w	#3,d0
		moveq	#0,d1
		move.b	(v_difficulty).w,d1
		lsl.w	#1,d1
		add.w	d1,d0
		move.w	DLE_SBZx(pc,d0.w),d0
		jmp		DLE_SBZx(pc,d0.w)
; ===========================================================================
DLE_SBZx:
		dc.w DLE_SBZ1N-DLE_SBZx, DLE_SBZ1N-DLE_SBZx, DLE_SBZ1N-DLE_SBZx, 0
		dc.w DLE_SBZ2N-DLE_SBZx, DLE_SBZ2E-DLE_SBZx, DLE_SBZ2N-DLE_SBZx, 0
		dc.w DLE_FZ-DLE_SBZx, 	 DLE_FZ-DLE_SBZx, 	 DLE_FZ-DLE_SBZx, 0
; ===========================================================================

DLE_SBZ1N:
		move.w	#$720,(v_limitbtm1).w
		cmpi.w	#$1880,(v_screenposx).w
		bcs.s	locret_7242
		move.w	#$620,(v_limitbtm1).w
		cmpi.w	#$2000,(v_screenposx).w
		bcs.s	locret_7242
		move.w	#$2A0,(v_limitbtm1).w

locret_7242:
		rts
; ===========================================================================

DLE_SBZ2N:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	off_SBZ2N(pc,d0.w),d0
		jmp		off_SBZ2N(pc,d0.w)
; ===========================================================================

DLE_SBZ2E:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	off_SBZ2E(pc,d0.w),d0
		jmp		off_SBZ2E(pc,d0.w)
; ===========================================================================

off_SBZ2N:
		dc.w DLE_SBZ2main-off_SBZ2N
		dc.w DLE_SBZ2boss-off_SBZ2N
		dc.w DLE_SBZ2boss2-off_SBZ2N
		dc.w DLE_SBZ2end-off_SBZ2N
; ===========================================================================

off_SBZ2E:
		dc.w DLE_SBZ2Emain-off_SBZ2E
		dc.w DLE_FZboss-off_SBZ2E
		dc.w DLE_FZend-off_SBZ2E
		dc.w locret_7322-off_SBZ2E
		dc.w DLE_FZend2-off_SBZ2E
; ===========================================================================

DLE_SBZ2main:
		move.w	#$800,(v_limitbtm1).w
		cmpi.w	#$1800,(v_screenposx).w
		bcs.s	locret_727A
		move.w	#$510,(v_limitbtm1).w
		cmpi.w	#$1E00,(v_screenposx).w
		bcs.s	locret_727A
		addq.b	#2,(v_dle_routine).w

locret_727A:
		rts
; ===========================================================================

DLE_SBZ2Emain:
		bset	#0,(f_boss_active).w		; Note that this act has a boss

		move.w	#$800,(v_limitbtm1).w
		cmpi.w	#$1800,(v_screenposx).w
		bcs.s	@ret
		move.w	#$510,(v_limitbtm1).w
		cmpi.w	#$2100,(v_screenposx).w
		bcs.s	@ret
		addq.b	#2,(v_dle_routine).w
		move.w	#$510,(v_limittop2).w
		moveq	#plcid_FZBoss,d0
		bsr.w	AddPLC				; load FZ boss patterns
		music	bgm_FZ, 0,0,0

	@ret:
		rts
; ===========================================================================


DLE_SBZ2boss:
		cmpi.w	#$1EB0,(v_screenposx).w
		bcs.s	locret_7298
		bsr.w	FindFreeObj
		bne.s	locret_7298
		move.b	#id_FalseFloor,obID(a1) ; load collapsing block object
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_EggmanSBZ2,d0
		bra.w	AddPLC		; load SBZ2 Eggman patterns
; ===========================================================================

locret_7298:
		rts	
; ===========================================================================

DLE_SBZ2boss2:
		cmpi.w	#$1F60,(v_screenposx).w
		bcs.s	loc_72B6
		bsr.w	FindFreeObj
		bne.s	loc_72B0
		move.b	#id_ScrapEggman,obID(a1) ; load SBZ2 Eggman object
		addq.b	#2,(v_dle_routine).w

loc_72B0:
		move.b	#1,(f_lockscreen).w ; lock screen

loc_72B6:
		bra.s	loc_72C2
; ===========================================================================

DLE_SBZ2end:
		cmpi.w	#$2050,(v_screenposx).w
		bcs.s	loc_72C2
		rts	
; ===========================================================================

loc_72C2:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts	
; ===========================================================================

DLE_FZ:
		moveq	#0,d0
		move.b	(v_dle_routine).w,d0
		move.w	off_72D8(pc,d0.w),d0
		jmp	off_72D8(pc,d0.w)
; ===========================================================================
off_72D8:
		dc.w DLE_FZmain-off_72D8, DLE_FZboss-off_72D8
		dc.w DLE_FZend-off_72D8, locret_7322-off_72D8
		dc.w DLE_FZend2-off_72D8
; ===========================================================================

DLE_FZmain:
		bset	#0,(f_boss_active).w		; Note that this act has a boss

		cmpi.w	#$2148,(v_screenposx).w
		bcs.s	loc_72F4
		addq.b	#2,(v_dle_routine).w
		moveq	#plcid_FZBoss,d0
		bsr.w	AddPLC		; load FZ boss patterns

loc_72F4:
		bra.s	loc_72C2
; ===========================================================================

DLE_FZboss:
		cmpi.w	#$2300,(v_screenposx).w
		bcs.s	loc_7312
		bsr.w	FindFreeObj
		bne.s	loc_7312
		move.b	#id_BossFinal,obID(a1) ; load FZ boss object
		addq.b	#2,(v_dle_routine).w
		move.b	#1,(f_lockscreen).w ; lock screen

loc_7312:
		bra.s	loc_72C2
; ===========================================================================

DLE_FZend:
		cmpi.w	#$2450,(v_screenposx).w
		bcs.s	loc_7320
		addq.b	#2,(v_dle_routine).w

loc_7320:
		bra.s	loc_72C2
; ===========================================================================

locret_7322:
		rts	
; ===========================================================================

DLE_FZend2:
		bra.s	loc_72C2
; ===========================================================================
; ---------------------------------------------------------------------------
; Ending sequence dynamic level events (empty)
; ---------------------------------------------------------------------------

DLE_Ending:
		rts	
