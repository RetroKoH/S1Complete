; ---------------------------------------------------------------------------
; Music	to play	after invincibility wears off
; ---------------------------------------------------------------------------
MusicList2:
		dc.b bgm_GHZ
		dc.b bgm_LZ
		dc.b bgm_MZ
		dc.b bgm_SLZ
		dc.b bgm_SYZ
		dc.b bgm_SBZ
		zonewarning MusicList2,1
		; The ending doesn't get an entry
		even

; ---------------------------------------------------------------------------
; Subroutine to display player characters and set music
; ---------------------------------------------------------------------------

Player_Display: 	; Invulnerability flashing
		move.b	obInvuln(a0),d0
		beq.s	@display
		subq.b	#1,obInvuln(a0)
		lsr.w	#3,d0
		bcc.s	@chkinvincible

	@display:
		jsr	(DisplaySprite).l

	@chkinvincible:
		btst	#stsInvinc,(v_status_secondary).w	; does the player have invincibility?
		beq.s	@chkshoes							; if not, branch
		tst.b	obInvinc(a0)						; check	time remaining for invinciblity
		beq.s	@chkshoes							; if no	time remains, branch
		move.b	(v_framebyte).w,d0
		andi.b	#7,d0                       ; invincibility timer decrements once every 8 frames
		bne.s	@chkshoes      			 	; if it's not the 8th frame, branch
		subq.b	#1,obInvinc(a0)						; subtract 1 from time
		bne.s	@chkshoes
		tst.b	(f_lockscreen).w
		bne.s	@removeinvincible
		cmpi.w	#$C,(v_air).w
		bcs.s	@removeinvincible
		moveq	#0,d0
		move.b	(v_zone).w,d0
		cmpi.w	#(id_LZ<<8)+3,(v_zone).w ; check if level is SBZ3
		bne.s	@music
		moveq	#5,d0		; play SBZ music

	@music:
		lea		(MusicList2).l,a1
		move.b	(a1,d0.w),d0
		jsr		(PlaySound).l	; play normal music

	@removeinvincible:
		bclr	#stsInvinc,(v_status_secondary).w ; cancel invincibility

	@chkshoes:
		btst	#stsShoes,(v_status_secondary).w	; does the player have speed shoes?
		beq.s	@exit				; if not, branch
		tst.b	obShoes(a0)			; check	time remaining
		beq.s	@exit
		move.b	(v_framebyte).w,d0
		andi.b	#7,d0                        ; shoe timer decrements once every 8 frames
		bne.s	@exit       			; if it's not the 8th frame, branch
		subq.b	#1,obShoes(a0)			; subtract 1 from time
		bne.s	@exit
		lea     (v_sonspeedmax).w,a2    ; Load Top speed into a2
		bsr.w   ApplySpeedSettings      ; Fetch Speed settings
		bclr	#stsShoes,(v_status_secondary).w	; cancel speed shoes
		music	bgm_Slowdown,1,0,0		; run music at normal speed

	@exit:
		rts	