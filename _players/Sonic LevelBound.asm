; ---------------------------------------------------------------------------
; Subroutine to	prevent	Sonic leaving the boundaries of	a level
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_LevelBound:
		move.l	obX(a0),d1
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		swap	d1
		move.w	(v_limitleft2).w,d0
		addi.w	#$10,d0
		cmp.w	d1,d0					; has Sonic touched the	side boundary?
		bhi.s	@sides					; if yes, branch
		move.w	(v_limitright2).w,d0
		addi.w	#$128,d0				; screen width - Sonic's width_pixels
		tst.b	(f_lockscreen).w
		bne.s	@screenlocked
		addi.w	#$40,d0

	@screenlocked:
		cmp.w	d1,d0		; has Sonic touched the	side boundary?
		bls.s	@sides		; if yes, branch

	@chkbottom: ; Recoded to suit my own preference. Allow Sonic to outrun camera, ALSO prevent sudden deaths.
		move.w	(v_limitbtm2).w,d0 ; current bottom boundary=d0
		cmp.w   (v_limitbtm1).w,d0 ; is the intended bottom boundary lower than the current one?
		bcc.s   @notlower          ; if not, branch
		move.w  (v_limitbtm1).w,d0 ; intended bottom boundary=d0
	@notlower:
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0	; has Sonic touched the	bottom boundary?
		blt.s	@bottom		; if yes, branch
		rts	
; ===========================================================================

	@bottom:
		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w	; is level SBZ2 ?
		bne.s	@killsonic					; if not, kill Sonic	; MJ: Fix out-of-range branch
		cmpi.w	#$2000,(v_player+obX).w
		bcs.s	@killsonic					; MJ: Fix out-of-range branch
		clr.b	(v_lastlamp).w				; clear	lamppost counter
		move.w	#1,(f_restart).w			; restart the level
		move.w	#(id_LZ<<8)+3,(v_zone).w	; set level to SBZ3 (LZ4)
	@nobottom:
		rts
	@killsonic:
		addq.l	#4,sp			; flamewing fix to prevent Sonic from interacting with solids when dying.
		jmp		(KillSonic).l	; MJ: Fix out-of-range branch
; ===========================================================================

	@sides:
		move.w	d0,obX(a0)
		clr.w	obX+2(a0)
		clr.w	obVelX(a0)	; stop Sonic moving
		clr.w	obInertia(a0)
		bra.s	@chkbottom
; ===========================================================================

; End of function Sonic_LevelBound