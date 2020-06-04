; ---------------------------------------------------------------------------
; SONIC 2 OBJECTS MANAGER
; Subroutine that keeps track of any objects that need to remember
; their state, such as monitors or enemies.
; Made this into a 1:1 port of the S2 Object Manager
;
; writes:
;  d0, d1
;  d2 = respawn index of object to load
;  d6 = camera position
;
;  a0 = address in object placement list
;  a2 = respawn table
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjPosLoad:
		moveq	#0,d0
		move.b	(v_opl_routine).w,d0
		move.w	OPL_Index(pc,d0.w),d0
		jmp		OPL_Index(pc,d0.w)
; End of function ObjPosLoad

; ===========================================================================
OPL_Index:
		dc.w OPL_Main-OPL_Index
		dc.w OPL_Next-OPL_Index
; ===========================================================================

OPL_Main:
		addq.b	#2,(v_opl_routine).w
		move.b	(v_zone).w,d0
		lsl.l	#6,d0					; zones are separated in multiples of $80
		move.b	(v_act).w,d1
		lsl.b	#4,d1					; acts are separated in multiples of $20
		add.b	d1,d0
		move.b	(v_difficulty).w,d1
		lsl.b	#2,d1					; difficulties are separated in multiples of 8
		add.b	d1,d0
		lea		(ObjPos_Index).l,a0		; Next, we load the first pointer in the object layout list pointer index,
		movea.l	a0,a1					; then copy it for quicker use later.
		movea.l (a0,d0.w),a0			; Changed from adda.w to movea.l for new object layout pointers
		; initialize each object load address with the first object in the layout
		move.l	a0,(v_opl_data).w
		move.l	a0,(v_opl_data+4).w
		move.l	a1,(v_opl_data+8).w
		move.l	a1,(v_opl_data+$C).w
		lea		(v_objstate).w,a2
		move.w	#$101,(a2)+	; the first two bytes are not used as respawn values
		; instead, they are used to keep track of the current respawn indexes
		move.w	#$5E,d0		; set loop counter

OPL_ClrList:
		clr.l	(a2)+
		dbf		d0,OPL_ClrList				; clear	pre-destroyed object list
		cmpi.b	#id_SLZ,(v_zone).w			; are we currently in Star Light Zone?
		bne.s	@notSLZ						; if not, branch
		move.b	#id_Pylon,(v_lvlobjspace).w	; manually load pylons

	@notSLZ:
		lea	(v_objstate).w,a2	; reset a2
		moveq	#0,d2
		move.w	(v_screenposx).w,d6
		subi.w	#$80,d6			; look one chunk (128 pixels) to the left
		bhs.s	loc_D93C		; if the result is negative
		moveq	#0,d6			; cap at zero

loc_D93C:
		andi.w	#$FF80,d6			; limit to increments of $80 (width of a chunk)
		movea.l	(v_opl_data).w,a0	; load address of object placement list

loc_D944:		; at the beginning of a level this gives respawn table entries to any object that is one chunk
				; behind the left edge of the screen that needs to remember its state (Monitors, Badniks, etc.)
		cmp.w	(a0),d6				; is object's x position >= d6?
		bls.s	loc_D956			; if yes, branch
		tst.b	2(a0)				; does the object get a respawn table entry - WAS 4
		bpl.s	loc_D952			; if not, branch
		move.b	(a2),d2
		addq.b	#1,(a2)				; respawn index of next object to the right.

loc_D952:
		addq.w	#6,a0				; next object
		bra.s	loc_D944
; ===========================================================================

loc_D956:
		move.l	a0,(v_opl_data).w		; remember rightmost object that has been processed, so far (we still need to look forward)
		move.l	a0,(v_opl_data+8).w
		movea.l	(v_opl_data+4).w,a0		; reset a0
		subi.w	#$80,d6					; look even farther left (any object behind this is out of range)
		bcs.s	loc_D976				; branch, if camera position would be behind level's left boundary

loc_D964:	; count how many objects are behind the screen that are not in range and need to remember their state
		cmp.w	(a0),d6		; is object's x position >= d6?
		bls.s	loc_D976	; if yes, branch
		tst.b	2(a0)		; does the object get a respawn table entry? (MAKE THIS 2(a0)?)
		bpl.s	loc_D972	; if not, branch
		addq.b	#1,1(a2)	; respawn index of current object to the left

loc_D972:
		addq.w	#6,a0
		bra.s	loc_D964	; continue with next object
; ===========================================================================

loc_D976:
		move.l	a0,(v_opl_data+4).w
		move.l	a0,(v_opl_data+$C).w
		move.w	#-1,(v_opl_screen).w

OPL_Next:
		move.w	(v_screenposx).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		move.w	d1,(v_screenposx_coarse).w

		lea	(v_objstate).w,a2
		moveq	#0,d2
		move.w	(v_screenposx).w,d6
		andi.w	#$FF80,d6
		cmp.w	(v_opl_screen).w,d6	; is the X range the same as last time?
		beq.w	locret_DA3A		; if yes, branch (rts)
		bge.s	loc_D9F6		; if new pos is greater than old pos, branch
		; if the player is moving back
		move.w	d6,(v_opl_screen).w	; remember current position for next time
		movea.l	(v_opl_data+4).w,a0	; get current object from the left
		subi.w	#$80,d6			; look one chunk to the left
		bcs.s	loc_D9D2		; branch, if camera position would be behind level's left boundary

loc_D9A6:	; load all objects left of the screen that are now in range
		cmp.w	-6(a0),d6
		bge.s	loc_D9D2
		subq.w	#6,a0
		tst.b	2(a0)		; does the object get a respawn table entry?
		bpl.s	loc_D9BC
		subq.b	#1,1(a2)
		move.b	1(a2),d2

loc_D9BC:
		bsr.w	OPL_ChkLoad
		bne.s	loc_D9C6
		subq.w	#6,a0
		bra.s	loc_D9A6
; ===========================================================================

loc_D9C6:
		tst.b	2(a0)		; does the object get a respawn table entry?
		bpl.s	loc_D9D0
		addq.b	#1,1(a2)

loc_D9D0:
		addq.w	#6,a0

loc_D9D2:
		move.l	a0,(v_opl_data+4).w
		movea.l	(v_opl_data).w,a0
		addi.w	#$300,d6

loc_D9DE:
		cmp.w	-6(a0),d6
		bgt.s	loc_D9F0
		tst.b	-4(a0)		; does the previous object get a respawn table entry?
		bpl.s	loc_D9EC
		subq.b	#1,(a2)

loc_D9EC:
		subq.w	#6,a0
		bra.s	loc_D9DE
; ===========================================================================

loc_D9F0:
		move.l	a0,(v_opl_data).w
		rts	
; ===========================================================================

loc_D9F6:
		move.w	d6,(v_opl_screen).w
		movea.l	(v_opl_data).w,a0
		addi.w	#$280,d6

loc_DA02:	; load all objects right of the screen that are now in range
		cmp.w	(a0),d6
		bls.s	loc_DA16
		tst.b	2(a0)	; does the object get a respawn table entry?
		bpl.s	loc_DA10
		move.b	(a2),d2
		addq.b	#1,(a2)

loc_DA10:
		bsr.w	OPL_ChkLoad
		beq.s	loc_DA02

loc_DA16:
		move.l	a0,(v_opl_data).w
		movea.l	(v_opl_data+4).w,a0
		subi.w	#$300,d6
		blo.s	loc_DA36

loc_DA24:	; subtract number of objects that have been moved out of range (from the left)
		cmp.w	(a0),d6
		bls.s	loc_DA36
		tst.b	2(a0)		; does the object get a respawn table entry?
		bpl.s	loc_DA32
		addq.b	#1,1(a2)

loc_DA32:
		addq.w	#6,a0
		bra.s	loc_DA24
; ===========================================================================

loc_DA36:
		move.l	a0,(v_opl_data+4).w

locret_DA3A:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to check if an object needs to be loaded.
;
; input variables:
;  d2 = respawn index of object to be loaded
;
;  a0 = address in object placement list
;  a2 = object respawn table
;
; writes:
;  d0, d1
;  a1 = object
; ---------------------------------------------------------------------------
OPL_ChkLoad: ;loc_DA3C:
		tst.b	2(a0)         ; does the object get a respawn table entry? WAS 4
		bpl.s	OPL_MakeItem  ; if not, branch
		bset	#7,2(a2,d2.w) ; mark object as loaded
		beq.s	OPL_MakeItem  ; branch if it wasn't already loaded
		addq.w	#6,a0         ; next object
		moveq	#0,d0         ; let the objects manager know that it can keep going
		rts
; ===========================================================================

OPL_MakeItem:
		bsr.w	FindFreeObj		; find empty slot
		bne.s	locret_DA8A		; branch, if there is no room to load an object
		move.w	(a0)+,obX(a1)
		move.w	(a0)+,d0		; there are three things stored in this word
		bpl.s	@norespawn		; branch, if the object doesn't get a respawn table entry
		move.b	d2,obRespawnNo(a1)

	@norespawn:
		move.w	d0,d1
		andi.w	#$FFF,d0             ; get y-position
		move.w	d0,obY(a1)
		rol.w	#3,d1                ; adjust bits
		andi.b	#3,d1                ; get render flags & status
		move.b	d1,obRender(a1)
		move.b	d1,obStatus(a1)
		move.b	(a0)+,obID(a1)          ; load obj
		move.b	(a0)+,obSubtype(a1)

	; S3K Monitor setting check
		moveq	#0,d0
		cmpi.b	#id_Monitor,obID(a1)	; is the current object a monitor?
		bne.s	@return					; if not, exit now
		move.b	obSubtype(a1),d0
		andi.b	#$F,d0					; Omit extra monitor flag
		cmpi.b	#$B,d0					; $B-D = Elemental Shield
		blt.s	@return
		cmpi.b	#$E,d0					; $E = Broken Monitor
		beq.s	@return
		tst.b	(f_optmonitor).w		; Are elemental shields enabled?
		bne.s	@return					; if yes, branch and exit
; at this point, we don't want elemental shields. We can revert it or destroy it.
		move.b	obSubtype(a1),d0
		btst	#7,d0 					; should this monitor be destroyed?
		beq.s	@revert	 	 	 	 	; if not, branch
		move.b	#$FF,obSubtype(a1)		; to be deleted
		bra.s	@return

	@revert:
		move.b	#4,obSubtype(a1)		; if not, default to blue shield

	@return:
		moveq	#0,d0

locret_DA8A:
		rts
