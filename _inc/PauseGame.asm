; ---------------------------------------------------------------------------
; Subroutine to	pause the game
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PauseGame:
		nop	
		tst.b	(v_lives).w	; do you have any lives	left?
		beq.s	Unpause		; if not, branch
		tst.w	(f_pause).w	; is game already paused?
		bne.s	Pause_StopGame	; if yes, branch
		btst	#bitStart,(v_jpadpress1).w ; is Start button pressed?
		beq.s	Pause_DoNothing	; if not, branch

Pause_StopGame:
		move.w	#1,(f_pause).w	; freeze time
		move.b	#1,(v_snddriver_ram+f_pausemusic).w ; pause music

Pause_Loop:
		move.b	#$10,(v_vbla_routine).w
		bsr.w	WaitForVBla
		tst.b	(f_slomocheat).w ; is slow-motion cheat on?
		beq.s	Pause_ChkReset	; if not, branch
		btst	#bitA,(v_jpadpress1).w ; is button A pressed?
		beq.s	Pause_ChkBC	; if not, branch
		move.b	#id_Title,(v_gamemode).w ; set game mode to 4 (title screen)
		nop	
		bra.s	Pause_EndMusic
; ===========================================================================

Pause_ChkBC:
		btst	#bitB,(v_jpadhold1).w ; is button B pressed?
		bne.s	Pause_SlowMo	; if yes, branch
		btst	#bitC,(v_jpadpress1).w ; is button C pressed?
		bne.s	Pause_SlowMo	; if yes, branch

Pause_ChkReset:
		btst    #bitA,(v_jpadpress1).w ; is button A pressed?
		bne.s   Pause_Reset

Pause_ChkStart:
		btst	#bitStart,(v_jpadpress1).w ; is Start button pressed?
		beq.s	Pause_Loop	; if not, branch

Pause_EndMusic:
		move.b	#$80,(v_snddriver_ram+f_pausemusic).w	; unpause the music

Unpause:
		move.w	#0,(f_pause).w	; unpause the game

Pause_DoNothing:
		rts
; ===========================================================================

Pause_Reset: ; Iso Kilo; Concept by luluco
		cmp.b	#1,(v_lives).w			; Check if you only have 1 life
		beq.s	@ret					; If so branch (This way you don't get 0 lives and then underflow)
		cmp.b	#id_Sonic_Death,(v_player+obRoutine).w
		bge.s	@ret
		addq.b	#1,(f_lifecount).w		; update lives counter
		subq.b	#1,(v_lives).w			; subtract 1 from number of lives
		move.b	#0,(v_lastlamp).w		; clear lamppost counter
		move.b	#1,(f_restart).w		; Set the level reset flag
		move.b	#$80,(f_pausemusic).w 	; Unpause music
		clr.w	(f_pause).w
	@ret:
		rts 

Pause_SlowMo:
		move.w	#1,(f_pause).w
		move.b	#$80,(v_snddriver_ram+f_pausemusic).w	; Unpause the music
		rts	
; End of function PauseGame
