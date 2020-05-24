; ---------------------------------------------------------------------------
; Object 40 - Moto Bug enemy (GHZ)
; ---------------------------------------------------------------------------

MotoBug:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Moto_Index(pc,d0.w),d1
		jmp		Moto_Index(pc,d1.w)
; ===========================================================================
Moto_Index:	dc.w Moto_Main-Moto_Index
		dc.w Moto_Action-Moto_Index
		dc.w Moto_Animate-Moto_Index
		dc.w Moto_Delete-Moto_Index
; ===========================================================================

Moto_Main:	; Routine 0
		move.l	#Map_Moto,obMap(a0)
		move.w	#ArtNem_Motobug,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$200,obPriority(a0)
		move.b	#$14,obActWid(a0)
		tst.b	obAnim(a0)	; is object a smoke trail?
		bne.s	@smoke		; if yes, branch
		move.b	#$E,obHeight(a0)
		move.b	#8,obWidth(a0)
		move.b	#$C,obColType(a0)
		bsr.w	ObjectFall
		jsr		(ObjFloorDist).l
		tst.w	d1
		bpl.s	@notonfloor
		add.w	d1,obY(a0)	; match	object's position with the floor
		clr.w	obVelY(a0)
		addq.b	#2,obRoutine(a0) ; goto Moto_Action next
		cmpi.b	#difHard,(v_difficulty).w	; are we playing on Hard mode?
		bne.s	@nothard
		move.b	#4,ob2ndRout(a0)	; set to Hard Mode actions
	@nothard:
		bchg	#0,obStatus(a0)

	@notonfloor:
		rts	
; ===========================================================================

@smoke:
		addq.b	#4,obRoutine(a0) ; goto Moto_Animate next
		bra.w	Moto_Animate
; ===========================================================================

Moto_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Moto_ActIndex(pc,d0.w),d1
		jsr		Moto_ActIndex(pc,d1.w)
		lea		(Ani_Moto).l,a1
		bsr.w	AnimateSprite

		include	"_incObj\sub RememberState.asm" ; Moto_Action terminates in this file

; ===========================================================================
Moto_ActIndex:
		dc.w @move-Moto_ActIndex
		dc.w @findfloor-Moto_ActIndex
		dc.w @move2-Moto_ActIndex
		dc.w @findfloor2-Moto_ActIndex


@time:		equ $30
@smokedelay:	equ $33
; ===========================================================================

@move:
		subq.w	#1,@time(a0)	; subtract 1 from pause	time
		bpl.s	@wait		; if time remains, branch
		addq.b	#2,ob2ndRout(a0)
		move.w	#-$100,obVelX(a0) ; move object to the left
		move.b	#1,obAnim(a0)
		bchg	#0,obStatus(a0)
		bne.s	@wait
		neg.w	obVelX(a0)	; change direction

	@wait:
		rts	
; ===========================================================================

@findfloor:
		bsr.w	SpeedToPos
		jsr	(ObjFloorDist).l
		cmpi.w	#-8,d1
		blt.s	@pause
		cmpi.w	#$C,d1
		bge.s	@pause
		add.w	d1,obY(a0)	; match	object's position with the floor
		subq.b	#1,@smokedelay(a0)
		bpl.s	@nosmoke
		move.b	#$F,@smokedelay(a0)
		bsr.w	FindFreeObj
		bne.s	@nosmoke
		move.b	#id_MotoBug,obID(a1) ; load exhaust smoke object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#2,obAnim(a1)

	@nosmoke:
		rts	

@pause:
		subq.b	#2,ob2ndRout(a0)
		move.w	#59,@time(a0)	; set pause time to 1 second
		clr.w	obVelX(a0)	; stop the object moving
		clr.b	obAnim(a0)
		rts	
; ===========================================================================

@move2:
		subq.w	#1,@time(a0)		; subtract 1 from pause	time
		bpl.s	@wait2				; if time remains, branch
		addq.b	#2,ob2ndRout(a0)
		move.w	#-$280,obVelX(a0)	; move object to the left
		move.b	#1,obAnim(a0)
		bchg	#0,obStatus(a0)
		bne.s	@wait2
		neg.w	obVelX(a0)			; change direction

	@wait2:
		rts
; ===========================================================================

@findfloor2:
		bsr.w	SpeedToPos

		move.w	#$80,d2
		bsr.w	Moto_ChkDistance	; is Sonic < $80 pixels from motobug?
		bge.s	@notfound			; if not, branch
		bra.s	@pause2

	@notfound:
		jsr		(ObjFloorDist).l
		cmpi.w	#-8,d1
		blt.s	@pause2
		cmpi.w	#$C,d1
		bge.s	@pause2
		add.w	d1,obY(a0)	; match	object's position with the floor
		subq.b	#1,@smokedelay(a0)
		bpl.s	@nosmoke2
		move.b	#$F,@smokedelay(a0)
		bsr.w	FindFreeObj
		bne.s	@nosmoke2
		move.b	#id_MotoBug,obID(a1) ; load exhaust smoke object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#2,obAnim(a1)

	@nosmoke2:
		rts

@pause2:
		subq.b	#2,ob2ndRout(a0)
		move.w	#29,@time(a0)	; set pause time to half second
		clr.w	obVelX(a0)	; stop the object moving
		clr.b	obAnim(a0)
		rts	
; ===========================================================================

Moto_Animate:	; Routine 4
		lea		(Ani_Moto).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Moto_Delete:	; Routine 6
		bra.w	DeleteObject

; ===========================================================================
; Subroutine to check Sonic's distance from the Motobug

; input:
;	d2 = distance to compare

; output:
;	d0 = distance between Sonic and motobug

Moto_ChkDistance:
		move.w	(v_player+obX).w,d0	; player obX = d0
		sub.w	obX(a0),d0
		bcc.s	@right				; if Sonic is right of motobug, branch

	@left:	; Sonic is to the left of Motobug
		neg.w	d0				; get absolute value
		tst.b	obStatus(a0)	; if Motobug already facing left?
		bne.s	@compare
		bra.s	@isfacing

	@right:
		tst.b	obStatus(a0)	; if Motobug already facing right?
		beq.s	@compare

	@isfacing:
		move.b 	#$FF,d0

	@compare:
		cmp.w	d2,d0
		rts	
; ===========================================================================
