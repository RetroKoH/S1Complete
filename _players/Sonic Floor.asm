; ---------------------------------------------------------------------------
; Subroutine for Sonic to interact with	the floor after	jumping/falling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Floor:
		move.l	(v_colladdr1).w,(v_collindex).w		; MJ: load first collision data location
		cmpi.b	#$C,(v_top_solid_bit).w				; MJ: is second collision set to be used?
		beq.s	@first								; MJ: if not, branch
		move.l	(v_colladdr2).w,(v_collindex).w		; MJ: load second collision data location
@first:
		move.b	(v_lrb_solid_bit).w,d5				; MJ: load L/R/B soldity bit
		move.w	obVelX(a0),d1
		move.w	obVelY(a0),d2
		jsr		(CalcAngle).l
		subi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	Sonic_HitLeftWall
		cmpi.b	#$80,d0
		beq.w	Sonic_HitCeilingAndWalls
		cmpi.b	#$C0,d0
		beq.w	Sonic_HitRightWall
		bsr.w	CheckLeftWallDist
		tst.w	d1
		bpl.s	@noLeftWall
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0) ; stop Sonic since he hit a wall

	@noLeftWall:
		bsr.w	CheckRightWallDist
		tst.w	d1
		bpl.s	@noRightWall
		add.w	d1,obX(a0)
		clr.w	obVelX(a0) ; stop Sonic since he hit a wall

	@noRightWall:
		bsr.w	Sonic_CheckFloor
		tst.w	d1
		bpl.s	locret_1367E
		move.b	obVelY(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	@skip
		cmp.b	d2,d0
		blt.s	locret_1367E

	@skip:
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		move.b	#aniID_Walk,obAnim(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_1365C
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	loc_1364E
		asr		obVelY(a0)
		bra.s	loc_13670
; ===========================================================================

loc_1364E:
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Sonic_ResetOnFloor
; ===========================================================================

loc_1365C:
		clr.w	obVelX(a0)
		cmpi.w	#$FC0,obVelY(a0)
		ble.s	loc_13670
		move.w	#$FC0,obVelY(a0)

loc_13670:
		bsr.w	Sonic_ResetOnFloor
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_1367E
		neg.w	obInertia(a0)

locret_1367E:
		rts	
; ===========================================================================

Sonic_HitLeftWall:
		bsr.w	CheckLeftWallDist
		tst.w	d1
		bpl.s	Sonic_HitCeiling
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================

Sonic_HitCeiling:
		bsr.w	Sonic_CheckCeiling
		tst.w	d1
		bpl.s	Sonic_HitFloor
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	@end
		clr.w	obVelY(a0)

	@end:
		rts	
; ===========================================================================

Sonic_HitFloor:
		tst.w	obVelY(a0)
		bmi.s	@noFloor
		bsr.w	Sonic_CheckFloor
		tst.w	d1
		bpl.s	@noFloor
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		move.b	#aniID_Walk,obAnim(a0)
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Sonic_ResetOnFloor

	@noFloor:
		rts	
; ===========================================================================

Sonic_HitCeilingAndWalls:
		bsr.w	CheckLeftWallDist
		tst.w	d1
		bpl.s	@noLeftWall
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)

	@noLeftWall:
		bsr.w	CheckRightWallDist
		tst.w	d1
		bpl.s	@noRightWall
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)

	@noRightWall:
		bsr.w	Sonic_CheckCeiling
		tst.w	d1
		bpl.s	@end
		sub.w	d1,obY(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	@setAngle
		clr.w	obVelY(a0)
		rts

	@setAngle:
		move.b	d3,obAngle(a0)
		bsr.w	Sonic_ResetOnFloor
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	@end
		neg.w	obInertia(a0)

	@end:
		rts	
; ===========================================================================

Sonic_HitRightWall:
		bsr.w	CheckRightWallDist
		tst.w	d1
		bpl.s	Sonic_HitCeiling2
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================
; identical to Sonic_HitCeiling...
Sonic_HitCeiling2:
		bsr.w	Sonic_CheckCeiling
		tst.w	d1
		bpl.s	Sonic_HitFloor2
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	@end
		clr.w	obVelY(a0)

	@end:
		rts	
; ===========================================================================
; identical to Sonic_HitFloor...
Sonic_HitFloor2:
		tst.w	obVelY(a0)
		bmi.s	@end
		bsr.w	Sonic_CheckFloor
		tst.w	d1
		bpl.s	@end
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		move.b	#aniID_Walk,obAnim(a0)
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Sonic_ResetOnFloor

	@end:
		rts	
; End of function Sonic_Floor
