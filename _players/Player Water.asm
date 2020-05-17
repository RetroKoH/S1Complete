; ---------------------------------------------------------------------------
; Subroutine for player characters when underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Player_Water:
		cmpi.b	#id_LZ,(v_zone).w	; is level LZ?
		beq.s	@islabyrinth		; if yes, branch

	@exit:
		rts	
; ===========================================================================

	@islabyrinth:
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0	; is Sonic above the water?
		bge.s	@abovewater	; if yes, branch

		tst.w	obVelY(a0)	; check if player is moving upward (i.e. from jumping)
		bmi.s	@exit		; if yes, skip routine

		bset	#staWater,obStatus(a0)
		bne.s	@exit
		bsr.w	ResumeMusic
		move.b	#id_DrownCount,(v_objspace+$340).w ; load bubbles object from character's mouth
		move.b	#$81,(v_objspace+$340+obSubtype).w
		lea     (v_sonspeedmax).w,a2  ; Load top_speed into a2
		bsr.w   ApplySpeedSettings      ; Fetch Speed settings
		asr		obVelX(a0)
		asr		obVelY(a0)
		asr		obVelY(a0)	; slow the player
		beq.s	@exit		; branch if the player stops moving
		move.b	#id_Splash,(v_objspace+$300).w ; load splash object
		sfx		sfx_Splash,1,0,0	 ; play splash sound
; ===========================================================================

@abovewater:
		bclr	#6,obStatus(a0)
		beq.s	@exit
		bsr.w	ResumeMusic
		lea     (v_sonspeedmax).w,a2  ; Load top_speed into a2
		bsr.w   ApplySpeedSettings      ; Fetch Speed settings
		asl		obVelY(a0)
		beq.w	@exit
		move.b	#id_Splash,(v_objspace+$300).w ; load splash object
		cmpi.w	#-$1000,obVelY(a0)
		bgt.s	@belowmaxspeed
		move.w	#-$1000,obVelY(a0) ; set maximum speed on leaving water

	@belowmaxspeed:
		sfx	sfx_Splash,1,0,0	 ; play splash sound
; End of function Player_Water
