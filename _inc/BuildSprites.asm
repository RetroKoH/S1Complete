; ===========================================================================
BldSpr_ScrPos:
		dc.l 0							; blank
		dc.l v_screenposx&$FFFFFF		; main screen x-position
		dc.l v_bgscreenposx&$FFFFFF		; background x-position	1
		dc.l v_bg3screenposx&$FFFFFF	; background x-position	2

; ---------------------------------------------------------------------------
; Subroutine to	convert	mappings (etc) to proper Megadrive sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSprites:
		lea		(v_spritetablebuffer).w,a2 ; set address for sprite table
		moveq	#0,d5
		moveq	#0,d4
		tst.b	(f_level_started).w
		beq.s	@noRingsorHUD
		bsr.w	BuildHUD	; Sonic 2 HUD Manager

	@noRingsorHUD:
		lea		(v_spritequeue).w,a4
		moveq	#7,d7

BuildSprites_LevelLoop: ; The first part of this is for when we add S2 or S3K rings
		cmpi.b	#2,d7
		bne.s	@notpriority2
		move.l	a4,-(sp)
		jsr		BuildRings
		move.l	(sp)+,a4

	@notpriority2:
		tst.w	(a4)
		beq.w	loc_D72E
		moveq	#2,d6

loc_D672:
		movea.w	(a4,d6.w),a0
		tst.b	(a0)
		beq.w	loc_D726
		bclr	#7,obRender(a0)
		move.b	obRender(a0),d0
		move.b	d0,d4
		btst	#6,d0 						; is the multi-draw flag set?
		bne.w	BuildSprites_MultiDraw		; if it is, branch
		andi.w	#$C,d0 						; is this to be positioned by screen coordinates?
		beq.s	BuildSprites_ScreenSpaceObj	; if it is, branch
		movea.l	BldSpr_ScrPos(pc,d0.w),a1
		moveq	#0,d0
		move.b	obActWid(a0),d0
		move.w	obX(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D726
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#$140,d1
		bge.s	loc_D726
		addi.w	#$80,d3
		btst	#4,d4
		beq.s	loc_D6E8
		moveq	#0,d0
		move.b	obHeight(a0),d0
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	loc_D726
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#$E0,d1
		bge.s	loc_D726
		addi.w	#$80,d2
		bra.s	loc_D700
; ===========================================================================

BuildSprites_ScreenSpaceObj: ;loc_D6DE:
		move.w	$A(a0),d2
		move.w	obX(a0),d3
		bra.s	loc_D700
; ===========================================================================

loc_D6E8:
		move.w	obY(a0),d2
		sub.w	obMap(a1),d2
		addi.w	#$80,d2
		cmpi.w	#$60,d2
		blo.s	loc_D726
		cmpi.w	#$180,d2
		bhs.s	loc_D726

loc_D700:
		movea.l	obMap(a0),a1
		moveq	#0,d1
		btst	#5,d4
		bne.s	loc_D71C
		move.b	obFrame(a0),d1
		add.w	d1,d1					; MJ: changed from byte to word (we want more than 7F sprites)
		adda.w	(a1,d1.w),a1
		moveq	#0,d1					; MJ: clear d1 (because of our byte to word change)
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	loc_D720

loc_D71C:
		bsr.w	sub_D750

loc_D720:
		bset	#7,obRender(a0)

loc_D726:
		addq.w	#2,d6
		subq.w	#2,(a4)
		bne.w	loc_D672

loc_D72E:
		lea		$80(a4),a4
		dbf		d7,BuildSprites_LevelLoop
		move.b	d5,(v_spritecount).w
		cmpi.b	#$50,d5
		beq.s	loc_D748
		move.l	#0,(a2)
		rts	
; ===========================================================================

loc_D748:
		move.b	#0,-5(a2)
		rts	
; End of function BuildSprites


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSprites_MultiDraw:
		move.l	a4,-(sp)
		lea		(v_screenposx).w,a4
		movea.w	obGfx(a0),a3
		movea.l	obMap(a0),a5
		moveq	#0,d0

		 ; check if object is within X bounds
		move.b mainspr_width(a0),d0 ; load pixel width
		move.w obX(a0),d3
		sub.w (a4),d3
		move.w d3,d1
		add.w d0,d1
		bmi.w BuildSprites_MultiDraw_NextObj
		move.w d3,d1
		sub.w d0,d1
		cmpi.w #320,d1
		bge.w BuildSprites_MultiDraw_NextObj
		addi.w #128,d3

		; check if object is within Y bounds
		btst    #4,d4
		beq.s    @a
		moveq    #0,d0
		move.b    mainspr_height(a0),d0    ; load pixel height
		move.w    obY(a0),d2
		sub.w    4(a4),d2
		move.w    d2,d1
		add.w    d0,d1
		bmi.w    BuildSprites_MultiDraw_NextObj
		move.w    d2,d1
		sub.w    d0,d1
		cmpi.w    #224,d1
		bge.w    BuildSprites_MultiDraw_NextObj
		addi.w    #128,d2
		bra.s    @b

	@a:
		move.w    obY(a0),d2
		sub.w    4(a4),d2
		addi.w    #128,d2
		cmpi.w    #-32+128,d2
		blo.s    BuildSprites_MultiDraw_NextObj
		cmpi.w    #32+128+224,d2
		bhs.s    BuildSprites_MultiDraw_NextObj

	@b:
		moveq    #0,d1
		move.b    mainspr_mapframe(a0),d1    ; get current frame
		beq.s    @c
		add.w    d1,d1
		movea.l    a5,a1
		adda.w    (a1,d1.w),a1
		move.b   (a1)+,d1
		subq.w    #1,d1
		bmi.s    @c
		move.w    d4,-(sp)
		bsr.w    ChkDrawSprite    ; draw the sprite
		move.w    (sp)+,d4

	@c:
		ori.b    #$80,obRender(a0)    ; set onscreen flag
		lea    sub2_x_pos(a0),a6
		moveq    #0,d0
		move.b    mainspr_childsprites(a0),d0    ; get child sprite count
		subq.w    #1,d0        ; if there are 0, go to next object
		bcs.s    BuildSprites_MultiDraw_NextObj
	@loop:
		swap    d0
		move.w    (a6)+,d3    ; get X pos
		sub.w    (a4),d3
		addi.w    #128,d3
		move.w    (a6)+,d2    ; get Y pos
		sub.w    4(a4),d2
		addi.w    #128,d2
		andi.w    #$7FF,d2
		addq.w    #1,a6
		moveq    #0,d1
		move.b    (a6)+,d1    ; get mapping frame
		add.w    d1,d1
		movea.l    a5,a1
		adda.w    (a1,d1.w),a1
		move.b    (a1)+,d1
		subq.b    #1,d1
		bmi.s    @skip
		move.w    d4,-(sp)
		bsr.w    ChkDrawSprite
		move.w    (sp)+,d4
	@skip:
		swap    d0
		dbf    d0,@loop    ; repeat for number of child sprites

BuildSprites_MultiDraw_NextObj:
		movea.l    (sp)+,a4
		bra.w    loc_D726

DrawSprite_Done:
        rts

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
 
; sub_1680A:
ChkDrawSprite:
    cmpi.b    #$50,d5        ; has the sprite limit been reached?
    blo.s    DrawSprite_Cont    ; if it hasn't, branch
    rts    ; otherwise, return
; End of function ChkDrawSprite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_D750:
		movea.w	obGfx(a0),a3
        cmpi.b    #$50,d5
        bhs.s    DrawSprite_Done

DrawSprite_Cont:
		btst	#0,d4
		bne.s	loc_D796
		btst	#1,d4
		bne.w	loc_D7E4
; End of function sub_D750


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawSprite_Loop: ;sub_D762:
		cmpi.b	#$50,d5
		beq.s	locret_D794
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D78E
		addq.w	#1,d0

loc_D78E:
		move.w	d0,(a2)+
		dbf		d1,DrawSprite_Loop

locret_D794:
		rts	
; End of function DrawSprite_Loop

; ===========================================================================

loc_D796:
		btst	#1,d4
		bne.w	loc_D82A

loc_D79E:
		cmpi.b	#$50,d5
		beq.s	locret_D7E2
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$800,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		neg.w	d0
		add.b	d4,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D7DC
		addq.w	#1,d0

loc_D7DC:
		move.w	d0,(a2)+
		dbf	d1,loc_D79E

locret_D7E2:
		rts	
; ===========================================================================

loc_D7E4:
		cmpi.b	#$50,d5
		beq.s	locret_D828
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		lsl.b	#3,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1000,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D822
		addq.w	#1,d0

loc_D822:
		move.w	d0,(a2)+
		dbf	d1,loc_D7E4

locret_D828:
		rts	
; ===========================================================================

loc_D82A:
		cmpi.b	#$50,d5
		beq.s	locret_D87C
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		lsl.b	#3,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1800,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		neg.w	d0
		add.b	d4,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D876
		addq.w	#1,d0

loc_D876:
		move.w	d0,(a2)+
		dbf	d1,loc_D82A

locret_D87C:
		rts	