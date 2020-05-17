; ---------------------------------------------------------------------------
; Object 8D - Red Ring
; Emerald that is found in levels in Master System mode
; Object will destroy itself if not in correct mode.
; ---------------------------------------------------------------------------

RedRing:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	RedRing_Index(pc,d0.w),d1
		jmp		RedRing_Index(pc,d1.w)
; ===========================================================================
RedRing_Index:
		dc.w RedRing_Init-RedRing_Index
		dc.w RedRing_Animate-RedRing_Index
		dc.w RedRing_Collect-RedRing_Index
		dc.w RedRing_Sparkle-RedRing_Index
		dc.w RedRing_Delete-RedRing_Index
; ===========================================================================

RedRing_Init:	; Routine 0
		move.l	#Map_RedRing,obMap(a0)
		move.w	#$2574,obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)

		; Remove emerald if not in Complete Mode (Normal or Hard Difficulty only)
;		cmpi.b	#2,(v_optgamemode).w	; Are you playing in Complete Mode?
;		bne.w	LEm_Delete		; if not, branch and delete
;		move.b	subtype(a0),d0
;		btst	d0,(v_emeraldlist).w
;		beq.s	@okay
;		rts
; ===========================================================================

;	@okay:
		addq.b	#2,obRoutine(a0)
		move.w	#$280,obPriority(a0)
		move.b	#$47,obColType(a0)

RedRing_Animate:
		move.b	(v_ani2_frame).w,obFrame(a0) ; set frame
		bsr.s	RedRing_LoadGfx
		jmp		RememberState
; ===========================================================================

RedRing_Collect:	; Routine 4
		addq.b	#2,obRoutine(a0)
		clr.b	obColType(a0)
		move.w	#$80,obPriority(a0)
		move.b	obSubtype(a0),d0		; move emerald number to d0
		bset	d0,(v_redringlist).w	; set Red Ring as collected
		bne.s	@collected				; if this red ring is already collected, branch
		addq.b	#1,(v_redrings).w		; increment Red Rings count
	@collected:
		music	sfx_Continue,0,0,0		; play extra continue sound (We won't use Continues, let's use the jingle)
		lea		(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		move.b	$34(a0),d1
		bset	d1,2(a2,d0.w)

RedRing_Sparkle:	; Routine 6
		lea		(Ani_Ring).l,a1 ; Uses same animation for sparkle as standard rings
		jsr		AnimateSprite
		bsr.w	RedRing_LoadGfx
		jmp		DisplaySprite
; ===========================================================================

RedRing_Delete:	; Routine 6
		jmp		DeleteObject
; ===========================================================================

; ---------------------------------------------------------------------------
; Signpost dynamic pattern loading subroutine
; ---------------------------------------------------------------------------

RedRing_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		lea		(RedRingDynPLC).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5          ; read "number of entries" value
		subq.w	#1,d5
		bmi.s	RedRingDPLC_Return ; if zero, branch
		move.w	#$AE80,d4

RedRingPLC_ReadEntry:
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
		add.l	#Art_RedRing,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).l
		dbf		d5,RedRingPLC_ReadEntry	; repeat for number of entries

RedRingDPLC_Return:
		rts