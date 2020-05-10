; ---------------------------------------------------------------------------
; Object 38 - shield and invincibility stars
; ---------------------------------------------------------------------------

ShieldItem:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Shi_Index(pc,d0.w),d1
		jmp		Shi_Index(pc,d1.w)
; ===========================================================================
Shi_Index:
		dc.w Shi_Init-Shi_Index
		dc.w Shi_Shield-Shi_Index
		dc.w Shi_Stars-Shi_Index
		dc.w Shi_Flame-Shi_Index
		dc.w Shi_Bubble-Shi_Index
		dc.w Shi_Lightning-Shi_Index
		dc.w Shi_Insta-Shi_Index
		dc.w Shi_LightningSpark-Shi_Index
		dc.w Shi_LightningDestroy-Shi_Index

obArt:		equ $38
obDPLC:		equ $3C
; ===========================================================================

Shi_Init:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Shield,obMap(a0)
		move.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)
		move.b	#$10,obActWid(a0)
		move.w	#$2550,obGfx(a0)
		tst.b	obAnim(a0)					; is object a shield?
		beq.s	@shield						; if yes, branch
		cmpi.b	#5,obAnim(a0)     			; is object a flame shield?
		bne.s	@noflame        			; if not, branch
		move.l	#Map_FlameShield,obMap(a0)
		move.l	#Art_Shield_F,obArt(a0)
		move.l	#DPLC_FlameShield,obDPLC(a0)
		move.b	#5,obGfx(a0)				; quickly set to first palette line
		addq.b	#4,obRoutine(a0)
	@shield:
		rts

	@noflame:
		cmpi.b	#7,obAnim(a0)     ; is object a bubble shield?
		bne.s	@nobubble       ; if not, branch
		move.l	#Map_BubbleShield,obMap(a0)
		move.l	#Art_Shield_B,obArt(a0)
		move.l	#DPLC_BubbleShield,obDPLC(a0)
		bsr.w	ResumeMusic
		addq.b	#6,obRoutine(a0)
		rts

	@nobubble:
		cmpi.b	#$A,obAnim(a0)	; is object a lightning shield?
		bne.s	@nolightning
		move.l	#Map_LightningShield,obMap(a0)
		move.l	#Art_Shield_L,obArt(a0)
		move.l	#DPLC_LightningShield,obDPLC(a0)

		move.l	#Art_Shield_L2,d1		; Load art for sparks
		move.w	#$ACA0,d2				; load it just after the lightning shield art
		move.w	#$50,d3
		jsr		(QueueDMATransfer).l
		addq.b	#8,obRoutine(a0)
		rts

	@nolightning:
		cmpi.b	#$D,obAnim(a0)	; is object an InstaShield? (Sonic only)
		bne.s	@stars
		move.l	#Map_InstaShield,obMap(a0)
		move.l	#Art_Insta,obArt(a0)
		move.l	#DPLC_InstaShield,obDPLC(a0)
		move.b	#$C,obRoutine(a0)
		rts

	@stars:
		move.l	#Art_Stars,obArt(a0)
		move.l	#ShieldDynPLC,obDPLC(a0)
		addq.b	#2,obRoutine(a0) ; Stars specific code: goto Shi_Stars next
		rts
; ===========================================================================

Shi_Shield:	; Routine 2
		btst	#stsInvinc,(v_status_secondary).w	; does Sonic have invincibility?
		bne.s	@remove								; if yes, branch
		btst	#stsShield,(v_status_secondary).w	; does Sonic have shield?
		beq.s	@delete								; if not, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		lea		(Ani_Shield).l,a1
		jsr		(AnimateSprite).l
		bsr.w	Shield_LoadGfx
		jmp		(DisplaySprite).l

	@delete:
;		tst.b	(v_player+obCharID).w
;		bne.s	@notSonic
		clr.b	obRoutine(a0)
		move.b	#$D,obAnim(a0)	; Replace shield with instashield
	@remove:
		rts

;	@notSonic:
;		jmp	(DeleteObject).l
; ===========================================================================

Shi_Stars:	; Routine 4
		btst	#stsInvinc,(v_status_secondary).w	; does Sonic have invincibility?
		beq.s	Shi_Start_Delete					; if not, branch
		move.w	(v_trackpos).w,d0					; get index value for tracking data
		move.b	obAnim(a0),d1
		subq.b	#1,d1
;@trail:
		lsl.b	#3,d1		; multiply animation number by 8
		move.b	d1,d2
		add.b	d1,d1
		add.b	d2,d1		; multiply by 3
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	$30(a0),d1
		sub.b	d1,d0		; use earlier tracking data to create trail
		addq.b	#4,d1
		cmpi.b	#$18,d1
		bcs.s	@a
		moveq	#0,d1

	@a:
		move.b	d1,$30(a0)
		lea		(v_tracksonic).w,a1
		lea		(a1,d0.w),a1
		move.w	(a1)+,obX(a0)
		move.w	(a1)+,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		lea		(Ani_Shield).l,a1
		jsr		(AnimateSprite).l
		bsr.w	Stars_LoadGfx
		jmp		(DisplaySprite).l
; ===========================================================================

Shi_Start_Delete:	
		jmp	(DeleteObject).l
; ===========================================================================

Shi_Flame:	; Routine 6
		btst	#stsInvinc,(v_status_secondary).w	; does Sonic have invincibility?
		bne.s	@remove								; if yes, branch
;		cmpi.b	#$1C,(v_player+anim).w
;		beq.s	@remove
		btst	#stsShield,(v_status_secondary).w	; does Sonic have shield?
		beq.s	@delete								; if not, branch
		btst	#staWater,(v_player+obStatus).w	; is Sonic underwater?
		bne.s	@delete							; if yes, branch, and destroy the shield
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		cmpi.b	#6,obAnim(a0)		; is Sonic using the Dash ability?
		beq.s	@noshift			; if yes, branch
		move.b	(v_player+obStatus).w,obStatus(a0)
		andi.b	#1,obStatus(a0)		; Copy first bit, so the Shield is always facing in the same direction as the player.

	@noshift:
		lea		(Ani_Shield).l,a1
		jsr		AnimateSprite
		move.w	#$80,obPriority(a0)
		cmpi.b	#$F,obFrame(a0)
		bcs.s	@display
		move.w	#$200,obPriority(a0)

	@display:
		bsr.w	Shield_LoadGfx
		jmp		DisplaySprite

	@dissipate: ; SPECIAL EFFECT FOR UNDERWATER
	@delete:
		andi.b	#stsRmvShield,(v_status_secondary).w
;		tst.b	(v_player+character_id).w
;		bne.s	@notSonic
		clr.b	obRoutine(a0)
		move.b	#$D,obAnim(a0)	; Replace shield with instashield
	@remove:
		rts
;	@notSonic:
;		jmp	DeleteObject
; ===========================================================================

Shi_Bubble:	; Routine 8
		btst	#stsInvinc,(v_status_secondary).w	; does Sonic have invincibility?
		bne.s	@remove								; if yes, branch
;		cmpi.b	#$1C,(v_player+anim).w
;		beq.s	@remove
		btst	#stsShield,(v_status_secondary).w	; does Sonic have shield?
		beq.s	@delete								; if not, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		andi.b	#1,obStatus(a0)
		lea		(Ani_Shield).l,a1
		jsr		AnimateSprite
		move.w	#$80,obPriority(a0)
		cmpi.b	#$F,obFrame(a0)
		bcs.s	@display
		move.w	#$200,obPriority(a0)
	@display:
		bsr.w	Shield_LoadGfx
		jmp		DisplaySprite

	@delete:
		andi.b	#stsRmvShield,(v_status_secondary).w
;		tst.b	(v_player+character_id).w
;		bne.s	@notSonic
		clr.b	obRoutine(a0)
		move.b	#$D,obAnim(a0)	; Replace shield with instashield
	@remove:
		rts
;	@notSonic:
;		jmp	DeleteObject
; ===========================================================================

Shi_Lightning:	; Routine 8
		btst	#stsInvinc,(v_status_secondary).w	; does Sonic have invincibility?
		bne.s	@remove								; if yes, branch
;		cmpi.b	#$1C,(v_player+anim).w
;		beq.s	@remove
		btst	#stsShield,(v_status_secondary).w	; does Sonic have shield?
		beq.s	@delete								; if not, branch
		btst	#staWater,(v_player+obStatus).w	; is Sonic underwater?
		bne.s	@checkflash						; if yes, branch, and destroy the shield
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		andi.b	#1,obStatus(a0)
		lea		(Ani_Shield).l,a1
		jsr		AnimateSprite
		move.w	#$80,obPriority(a0)
		cmpi.b	#$F,obFrame(a0)
		bcs.s	@display
		move.w	#$200,obPriority(a0)
	@display:
		bsr.w	Shield_LoadGfx
		jmp		DisplaySprite

	@checkflash:
		;tst.w	(v_pcyc_time).w
		bra.s	Lightning_FlashWater

	@delete:
		andi.b	#stsRmvShield,(v_status_secondary).w
;		tst.b	(v_player+character_id).w
;		bne.s	@notSonic
		clr.b	obRoutine(a0)
		move.b	#$D,obAnim(a0)	; Replace shield with instashield
	@remove:
		rts
;	@notSonic:
;		jmp	DeleteObject
; ===========================================================================

Lightning_FlashWater:
		move.b	#$10,obRoutine(a0)
		andi.b	#stsRmvShield,(v_status_secondary).w
		lea		(v_pal_water).w,a1
		lea		(v_pal_water_dup).w,a2
		move.w	#$1F,d0

	@loop:
		move.l	(a1),(a2)+
		move.l	#$EEE0EEE,(a1)+
		dbf		d0,@loop
		move.w	#0,-$40(a1)
		rts
; ===========================================================================

Lightning_CreateSpark:
;		moveq	#$C,d2

;Metal_Create_Spark: ; Metal Sonic's double jump sparks use this too
;		lea	(v_sparkspace).w,a1
;		lea	(SparkVelocities).l,a2
;		moveq	#3,d1

;	@loop:
;		move.b	#id_ShieldItem,(a1)
;		move.b	#$E,routine(a1)
;		move.w	x_pos(a0),x_pos(a1)
;		move.w	y_pos(a0),y_pos(a1)
;		move.l	mappings(a0),mappings(a1)
;		move.w	art_tile(a0),art_tile(a1)
;		move.b	#4,render_flags(a1)
;		move.w	#$80,priority(a1)
;		move.b	#8,width_pixels(a1)
;		move.b	d2,anim(a1)
;		move.w	(a2)+,x_vel(a1)
;		move.w	(a2)+,y_vel(a1)
;		lea	$40(a1),a1
;		dbf	d1,@loop

;	@end:
		rts
; End of function Lightning_CreateSpark
; ===========================================================================

Shi_Insta:	; Routine $C
		btst	#stsInvinc,(v_status_secondary).w	; does Sonic have invincibility?
		bne.s	@remove								; if yes, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		andi.b	#1,obStatus(a0)
		lea		(Ani_Shield).l,a1
		jsr		AnimateSprite
		cmpi.b	#7,obFrame(a0)
		bne.s	@chkframe
		tst.b	(v_player+obJumpFlag).w
		beq.s	@chkframe
		move.b	#2,(v_player+obJumpFlag).w

	@chkframe:
		tst.b	obFrame(a0)
		beq.s	@loaddplc
		cmpi.b	#3,obFrame(a0)
		bne.s	@display

	@loaddplc:
		bsr.w	Shield_LoadGfx
	@display:
		jmp		DisplaySprite
	@remove:
		rts
; ===========================================================================

Shi_LightningSpark: ; Routine $E
		jsr	SpeedToPos
		addi.w	#$18,obVelY(a0)
		lea	(Ani_Shield).l,a1
		jsr	AnimateSprite
		cmpi.b	#$E,obRoutine(a0)
		bne.s	@delete
		jmp	DisplaySprite

	@delete:
		jmp	DeleteObject
; ===========================================================================

Shi_LightningDestroy: ; Routine $10
		subq.b	#1,obTimeFrame(a0)
		bpl.s	locret_198BC
;		tst.b	(v_player+character_id).w
;		bne.s	@notSonic
		move.b	#0,obRoutine(a0)
		move.b	#$D,obAnim(a0)	; Replace shield with instashield
;		bra.s	@continue

;	@notSonic:
;		jsr		DeleteObject

	@continue:
		lea	(v_pal_water_dup).w,a1
		lea	(v_pal_water).w,a2
		move.w	#$1F,d0

loc_198B6:
		move.l	(a1)+,(a2)+
		dbf	d0,loc_198B6

locret_198BC:
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Shield and Stars dynamic pattern loading subroutine
; ---------------------------------------------------------------------------

Stars_LoadGfx:
		moveq	#0,d0
		move.b	(v_invincspace+obFrame).w,d0	; load frame number
		bra.s   ShieldPLC_Cont

Shield_LoadGfx:
		moveq	#0,d0
		move.b	(v_shieldspace+obFrame).w,d0	; load frame number

ShieldPLC_Cont:
		movea.l	obDPLC(a0),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5          ; read "number of entries" value
		subq.w	#1,d5
		bmi.s	ShieldDPLC_Return ; if zero, branch
		move.w	#$AA00,d4

ShieldPLC_ReadEntry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	obArt(a0),d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,ShieldPLC_ReadEntry	; repeat for number of entries

ShieldDPLC_Return:
		rts