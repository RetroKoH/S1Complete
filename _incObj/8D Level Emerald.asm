; ---------------------------------------------------------------------------
; Object 8D - Emerald that is found in levels in Master System mode
; Object will destroy itself if not in correct mode.
; ---------------------------------------------------------------------------

LvlEmerald:				; XREF: Obj_Index
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	LEm_Index(pc,d0.w),d1
		jmp		LEm_Index(pc,d1.w)
; ===========================================================================
LEm_Index:
		dc.w LEm_Main-LEm_Index
		dc.w LEm_Flicker-LEm_Index
		dc.w LEm_Collect-LEm_Index
		dc.w LEm_Delete-LEm_Index

origY:		= $30		; original y-axis position
; ===========================================================================

LEm_Main:	; Routine 0
		move.l	#Map_ChaosEm,obMap(a0)
		move.w	#$574,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	obY(a0),origY(a0) ; save position on y-axis
		move.b	#$10,obActWid(a0)

		; Remove emerald if not in Master System Mode
		cmpi.b	#modeHandheld,(v_optgamemode).w	; Are you playing in Handheld Mode?
		bne.w	LEm_Delete						; if not, branch and delete
		move.b	obSubtype(a0),d0
		btst	d0,(v_emeraldlist).w
		beq.s	@okay
		bra.w	LEm_Delete						; if you already got this emerald, delete object
; ===========================================================================

	@okay:
		addq.b	#2,obRoutine(a0)
		move.w	#$280,obPriority(a0)
		move.b	#$47,obColType(a0)
		move.b	d0,obFrame(a0)			; set mapping frame to the appropriate emerald frame

LEm_Flicker:	; Routine 2 - Modified RememberState routine
		out_of_range	@offscreen
		btst	#2,(v_framebyte).w
		beq.s	@even					; branch on even frames to flicker
		jmp		DisplaySprite
	@even:
		rts

	@offscreen:
		lea		(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	@delete
		bclr	#7,2(a2,d0.w)

	@delete:
		jmp		DeleteObject

; ===========================================================================
LEm_Collect:	; Routine 4
		addq.b	#2,obRoutine(a0)
		clr.b	obColType(a0)			; can no longer collide with the item
		move.w	#$80,obPriority(a0)		; collected emerald will sparkle like a ring.
		move.b	obSubtype(a0),d0		; move emerald number to d0
		bset	d0,(v_emeraldlist).w	; set emerald as collected
		bne.s	@collected				; if emerald is already collected, branch
		addq.b	#1,(v_emeralds).w		; increment emerald count
	@collected:
		move.w	#bgm_ExtraLife,d0		; play extra life music (replace with SMS emerald music)
		jmp		(PlaySound_Special).l
		lea		(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		bset	d1,2(a2,d0.w)

LEm_Delete:	; Routine 6
		jmp		DeleteObject
