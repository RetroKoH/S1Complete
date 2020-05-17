; ---------------------------------------------------------------------------
; Subroutine for Tails to interact with	the floor after	jumping/falling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Tails_Floor:
		move.l	(v_colladdr1).w,(v_collindex).w		; MJ: load first collision data location
		cmpi.b	#$C,(v_top_solid_bit).w			; MJ: is second collision set to be used?
		beq.s	@first					; MJ: if not, branch
		move.l	(v_colladdr2).w,(v_collindex).w		; MJ: load second collision data location
	@first:
		move.b	(v_lrb_solid_bit).w,d5			; MJ: load L/R/B soldity bit
		move.w	obVelX(a0),d1
		move.w	obVelY(a0),d2
		jsr		(CalcAngle).l
		subi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	Tails_HitLeftWall
		cmpi.b	#$80,d0
		beq.w	Tails_HitCeilingAndWalls
		cmpi.b	#$C0,d0
		beq.w	Tails_HitRightWall
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	@135F0
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)

	@135F0:
		bsr.w	sub_14EB4
		tst.w	d1
		bpl.s	@13602
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)

	@13602:
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	@ret
		move.b	obVelY(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	@1361E
		cmp.b	d2,d0
		blt.s	@ret

	@1361E:
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		move.b	#aniID_Walk,obAnim(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	@1365C
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	@1364E
		asr		obVelY(a0)
		bra.s	@13670
; ===========================================================================

	@1364E:
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Tails_ResetOnFloor
; ===========================================================================

	@1365C:
		clr.w	obVelX(a0)
		cmpi.w	#$FC0,obVelY(a0)
		ble.s	@13670
		move.w	#$FC0,obVelY(a0)

	@13670:
		bsr.w	Tails_ResetOnFloor
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	@ret
		neg.w	obInertia(a0)

	@ret:
		rts	
; ===========================================================================

Tails_HitLeftWall:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	Tails_HitCeiling
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================

Tails_HitCeiling:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	Tails_136B4
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	@ret
		clr.w	obVelY(a0)

	@ret:
		rts	
; ===========================================================================

Tails_136B4:
		tst.w	obVelY(a0)
		bmi.s	@ret
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	@ret
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		move.b	#aniID_Walk,obAnim(a0)
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Tails_ResetOnFloor

	@ret:
		rts	
; ===========================================================================

Tails_HitCeilingAndWalls:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	@skipchk1
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)	; stop Tails since he hit a wall

	@skipchk1:
		bsr.w	sub_14EB4
		tst.w	d1
		bpl.s	@skipchk2
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)	; stop Tails since he hit a wall

	@skipchk2:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	@ret
		sub.w	d1,obY(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	@noceiling
		clr.w	obVelY(a0)	; stop Tails in y since he hit a ceiling
		rts	
; ===========================================================================

	@noceiling:
		move.b	d3,obAngle(a0)
		bsr.w	Tails_ResetOnFloor
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	@ret
		neg.w	obInertia(a0)

	@ret:
		rts	
; ===========================================================================

Tails_HitRightWall:
		bsr.w	sub_14EB4
		tst.w	d1
		bpl.s	Tails_HitCeiling2
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)	; stop Tails since he hit a wall
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================

Tails_HitCeiling2:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	Tails_HitFloor2
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	@ret
		clr.w	obVelY(a0)	; stop Tails in y since he hit a ceiling

	@ret:
		rts	
; ===========================================================================

Tails_HitFloor2:
		tst.w	obVelY(a0)
		bmi.s	@ret
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	@ret
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		move.b	#aniID_Walk,obAnim(a0)
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Tails_ResetOnFloor

	@ret:
		rts	
; End of function Tails_Floor
