; ---------------------------------------------------------------------------
; Subroutine to draw the HUD

; Need to rewrite this to draw one of multiple HUDS
; First check if in Time Attack Mode. If yes, default to the Time Attack HUD for both Level and T.A.
; If not in Time Attack:

; Check if in Special Stage. If NOT, draw one of these HUDs:
; Routine for Level's Normal and Hard HUDS, and Bonus Stage (Can share same mappings)

; if in the special stage... Routine for Special Stage Ring HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

BuildHUD:
		tst.b 	(f_timeattack).w			; are we in Time Attack?
		beq.s	BuildHUD_NoTimeAttack		; if not, branch
;HUD_TimeAttack
		moveq	#0,d1
		btst	#3,(v_framebyte).w
		beq.s	@dontblink					; only blink on certain frames
		tst.w	(v_rings).w
		bne.s	@skiprings					; if yes, skip to time
		addq.w	#1,d1						; set mapping frame for ring count blink
	@skiprings:
		cmpi.b	#9,(v_timemin).w			; have 9 minutes elapsed?
		bne.s	@dontblink					; if not, branch
		addq.w	#2,d1						; set mapping frame time counter blink
	@dontblink:
		moveq	#0,d3
		move.b	(v_hudscrollpos).w,d3		; set X pos. Will scroll to $90.
		move.w	#128+136,d2					; set Y pos
		lea		(Map_HUD_TA).l,a1			; load Time Attack mappings to a1
		movea.w	#$6CA,a3					; set art tile and flags
		cmpi.b	#id_Special,(v_gamemode).w	; is this the Special Stage?
		bne.s	@notSS						; if not, branch ahead
		movea.w	#$1F5,a3					; set art tile and flags
	@notSS: ;load frame
		add.w	d1,d1
		adda.w	(a1,d1.w),a1				; load frame
		move.b	(a1)+,d1					; load # of pieces in frame
		subq.w	#1,d1
		bmi.s	@end
		bsr.w	DrawSprite_Loop				; draw frame
	@end:
		rts
; ===========================================================================

BuildHUD_NoTimeAttack:
		cmpi.b	#id_Special,(v_gamemode).w	; is this the Special Stage?
		beq.s	BuildHUD_Special			; if yes, branch ahead
;HUD_Standard
		moveq	#0,d1
		btst	#3,(v_framebyte).w
		bne.s	@dontblink					; only blink on certain frames
		tst.w	(v_rings).w
		bne.s	@skiprings					; if yes, skip to time
		addq.w	#1,d1						; set mapping frame for ring count blink
	@skiprings:
		cmpi.b	#9,(v_timemin).w			; have 9 minutes elapsed?
		bne.s	@dontblink					; if not, branch
		addq.w	#2,d1						; set mapping frame time counter blink
	@dontblink:
		cmpi.b	#difHard,(v_difficulty).w	; is this hard mode?
		bne.s	@notHard
		addq.w	#4,d1						; set mapping frame to Hard Mode HUD
	@notHard:
		moveq	#0,d3
		move.b	(v_hudscrollpos).w,d3		; set X pos. Will scroll to $90.
		move.w	#128+136,d2					; set Y pos
		lea		(Map_HUD).l,a1				; load standard HUD mappings to a1
		movea.w	#$6CA,a3					; set art tile and flags
;load frame
		add.w	d1,d1
		adda.w	(a1,d1.w),a1				; load frame
		move.b	(a1)+,d1					; load # of pieces in frame
		subq.w	#1,d1
		bmi.s	@end
		bsr.w	DrawSprite_Loop				; draw frame
	@end:
		rts

BuildHUD_Special:
		moveq	#0,d1
		btst	#3,(v_framebyte).w
		bne.s	@dontblink					; only blink on certain frames
		tst.w	(v_rings).w
		bne.s	@dontblink					; if yes, skip
		addq.w	#1,d1						; set mapping frame for ring count blink		
	@dontblink:
		moveq	#0,d3
		move.b	(v_hudscrollpos).w,d3		; set X pos. Will scroll to $90.
		move.w	#128+136,d2					; set Y pos
		lea		(Map_HUD_SS).l,a1			; load Special Stage mappings to a1
		movea.w	#$1F5,a3					; set art tile and flags
;load frame
		add.w	d1,d1
		adda.w	(a1,d1.w),a1				; load frame
		move.b	(a1)+,d1					; load # of pieces in frame
		subq.w	#1,d1
		bmi.s	@end
		bsr.w	DrawSprite_Loop				; draw frame
	@end:
		rts
; End of function BuildHUD
