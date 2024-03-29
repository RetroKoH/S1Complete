; ---------------------------------------------------------------------------
; Object 25 - rings
; ---------------------------------------------------------------------------

Rings:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Ring_Index(pc,d0.w),d1
		jmp		Ring_Index(pc,d1.w)
; ===========================================================================
Ring_Index:
ptr_Ring_Main:		dc.w Ring_Main-Ring_Index
ptr_Ring_Animate:	dc.w Ring_Animate-Ring_Index
ptr_Ring_Collect:	dc.w Ring_Collect-Ring_Index
ptr_Ring_Sparkle:	dc.w Ring_Sparkle-Ring_Index
ptr_Ring_Delete:	dc.w Ring_Delete-Ring_Index

id_Ring_Main:		equ ptr_Ring_Main-Ring_Index	; 0
id_Ring_Animate:	equ ptr_Ring_Animate-Ring_Index	; 2
id_Ring_Collect:	equ ptr_Ring_Collect-Ring_Index	; 4
id_Ring_Sparkle:	equ ptr_Ring_Sparkle-Ring_Index	; 6
id_Ring_Delete:		equ ptr_Ring_Delete-Ring_Index	; 8
; ===========================================================================

Ring_Main:	; Routine 0 - Completely stripped out all placement code and respawn index code, as it's not needed anymore
		addq.b	#2,obRoutine(a1)
		move.w	obX(a0),$32(a1)
		move.l	#Map_Ring,obMap(a1)
		move.w	#ArtNem_Ring,obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#$100,obPriority(a1)
		move.b	#$47,obColType(a1)
		move.b	#8,obActWid(a1)

Ring_Animate:	; Routine 2
		move.b	(v_ani2_frame).w,obFrame(a0) ; set frame
		out_of_range.s	Ring_Delete,$32(a0)
		bra.w	DisplaySprite
; ===========================================================================

Ring_Collect:	; Routine 4
		addq.b	#2,obRoutine(a0)
		clr.b	obColType(a0)
		move.w	#$80,obPriority(a0)
		bsr.w	CollectRing

Ring_Sparkle:	; Routine 6
		lea		(Ani_Ring).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Ring_Delete:	; Routine 8
		bra.w	DeleteObject

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CollectRing:
		move.w	#sfx_Ring,d0	 ; prepare to play ring sound
		cmpi.w	#999,(v_rings).w ; did the Sonic collect 999+ rings? < Added ring cap
		bcc.s	@playsnd         ; if yes, branch
		addq.w	#1,(v_rings).w	 ; add 1 to rings
		ori.b	#1,(f_ringcount).w ; update the rings counter

; Lives check
		cmpi.b	#difHard,(v_difficulty).w
		beq.s	@playsnd
		move.w	#50,d1
		tst.b	(v_difficulty).w
		bne.s	@easy
		lsl.b	#1,d1
	@easy:
		move.w	(v_rings).w,d2
		cmp.w	d1,d2 ; do you have < 50/100 rings?
		bcs.s	@playsnd	; if yes, branch
		bset	#1,(v_lifecount).w ; update lives counter
		beq.s	@got100
		lsl.b	#1,d1
		cmp.w	d1,d2 ; do you have < 100/200 rings?
		bcs.s	@playsnd	; if yes, branch
		bset	#2,(v_lifecount).w ; update lives counter
		bne.s	@playsnd

	@got100:
		cmpi.b	#$63,(v_lives).w	; are lives at max?
		beq.s	@playbgm
		addq.b	#1,(v_lives).w	; add 1 to number of lives
		addq.b	#1,(f_lifecount).w ; update the lives counter
	@playbgm:
		move.w	#bgm_ExtraLife,d0 ; play extra life music

	@playsnd:
		jmp	(PlaySound_Special).l
; End of function CollectRing

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 37 - rings flying out of Sonic	when he's hit
; ---------------------------------------------------------------------------

RingLoss:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	RLoss_Index(pc,d0.w),d1
		jmp		RLoss_Index(pc,d1.w)
; ===========================================================================
RLoss_Index:
		dc.w RLoss_Count-RLoss_Index
		dc.w RLoss_Bounce-RLoss_Index
		dc.w RLoss_Collect-RLoss_Index
		dc.w RLoss_Sparkle-RLoss_Index
		dc.w RLoss_Delete-RLoss_Index
		; Attracted Ring
		dc.w RAttract_Init-RLoss_Index
		dc.w RAttract_Main-RLoss_Index
		dc.w RLoss_Collect-RLoss_Index
		dc.w RLoss_Sparkle-RLoss_Index
		dc.w RLoss_Delete-RLoss_Index
; ===========================================================================

RLoss_Count:	; Routine 0
		movea.l	a0,a1
		moveq	#0,d5						; d5 will contain # rings to spawn
		move.w	(v_rings).w,d5				; check number of rings you have
		cmpi.b	#difEasy,(v_difficulty).w	; is this easy mode?
		bne.s	@loadSpeeds					; if no, branch
		move.w	d5,d4						; We'll subtract d4 from our ring count (preset)
		; We set it twice. If rings aren't halved then the second instruction is skipped.
		cmpi.b	#6,d5						; do you have more than 5 rings?
		blt.s	@loadSpeeds					; if not, don't halve rings
		lsr.b	#1,d5						; lose half rings (rounded down)
		move.w	d5,d4						; We'll subtract d4 from our ring count

	@loadSpeeds:
		moveq	#32,d0						; max rings ever allotted
		cmpi.b	#difHard,(v_difficulty).w	; is this hard mode?
		bne.s	@notHard					; if no, branch
		lsr.b	#1,d0						; We will only spawn up to 16 rings in Hard
	@notHard:
		lea		SpillRingData,a3		; load the address of the array in a3
 		lea     (v_player).w,a2			; a2=character
		btst    #staWater,obStatus(a2)	; is Sonic underwater?
		beq.s   @abovewater				; if not, branch
		lea		SpillRingData_Water,a3	; load the address of the array in a3

	@abovewater:
		cmp.w	d0,d5		; do you have 32 or more?
		bcs.s	@belowmax	; if not, branch
		move.w	d0,d5		; if yes, set d5 to 32

	@belowmax:
		subq.w	#1,d5		; decrease the counter the first time, as we are creating the first ring now.
		; Calculate? Nope. We arent doing that anymore.
		; Loop through Object RAM? Screw that noise!

; Create the first instance, then loop create the others afterward.
		move.b	#id_RingLoss,obID(a1) ; load bouncing ring object
		addq.b	#2,obRoutine(a1)
		move.w	#808,obHeight(a1) ; Height and Width
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Ring,obMap(a1)
		move.w	#ArtNem_Ring,obGfx(a1)
		move.b	#4,obRender(a1)
		clr.b	obColType(a1)
		cmpi.b	#difHard,(v_difficulty).w
		beq.s	@nocollect
		move.b	#$47,obColType(a1)
	@nocollect:
		move.b	#8,obActWid(a1)
		move.l	(a3)+,obVelX(a1)	; move the data contained in the array to the speed data. Increment a3
		subq	#1,d5				; decrement for the first ring created
		bmi.s	@resetcounter		; if only one ring is needed, branch and skip EVERYTHING below altogether
		; Here we begin what's replacing SingleObjLoad, in order to avoid resetting its d0 every time an object is created.
		lea		(v_lvlobjspace).w,a1
		move.w	#$5F,d0

	@loop:
		;bsr.w	FindFreeObj - REMOVE THIS. It's the routine that causes such slowdown
		tst.b	(a1)
		beq.s	@makerings	; Let's correct the branches. Here we can also skip the bne that was originally after bsr.w FindFreeObj because we already know there's a free object slot in memory.
		lea		$40(a1),a1
		dbf		d0,@loop	; Branch correction again.
		bne.s	@resetcounter	; We're moving this line here.

	@makerings:
		move.b	#id_RingLoss,obID(a1) ; load bouncing ring object
		addq.b	#2,obRoutine(a1)
		move.w	#808,obHeight(a1) ; Height and Width
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Ring,obMap(a1)
		move.w	#ArtNem_Ring,obGfx(a1)
		move.b	#4,obRender(a1)
		clr.b	obColType(a1)
		cmpi.b	#difHard,(v_difficulty).w
		beq.s	@nocollect2
		move.b	#$47,obColType(a1)
	@nocollect2:
		move.b	#8,obActWid(a1)
		move.l	(a3)+,obVelX(a1)	; move the data contained in the array to the speed data. Increment a3
		dbf		d5,@loop			; repeat for number of rings (max 31)

	@resetcounter:
		cmpi.b	#difEasy,(v_difficulty).w	; is this easy mode?
		bne.s	@clearRings					; if no, branch and remove all rings
		sub.w	d4,(v_rings).w				; halve rings (rounded up)
		bra.s	@update

	@clearRings:
		clr.w	(v_rings).w				; reset number of rings to zero

	@update:
		move.b	#$80,(f_ringcount).w 	; update ring counter
		clr.b	(v_lifecount).w
		moveq   #-1,d0					; Move #-1 to d0
		move.b  d0,obDelayAni(a0)		; Move d0 to new timer
		move.b  d0,(v_ani3_time).w		; Move d0 to old timer (for animated purposes)
		sfx	sfx_RingLoss,0,0,0			; play ring loss sound

RLoss_Bounce:	; Routine 2
		move.b	(v_ani3_frame).w,obFrame(a0)
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)

		tst.b   (f_water).w             ; Does the level have water?
		beq.s   @skipbounceslow         ; If not, branch and skip underwater checks
		move.w  (v_waterpos1).w,d6      ; Move water level to d6
		cmp.w   obVelY(a0),d6           ; Is the ring object underneath the water level?
		bgt.s   @skipbounceslow         ; If not, branch and skip underwater commands
		subi.w  #$E,obVelY(a0)          ; Reduce gravity by $E ($18-$E=$A), giving the underwater effect

	@skipbounceslow:
		bmi.s	@chkdel						; Rings moving upward won't bounce off the floor
		cmpi.b	#difHard,(v_difficulty).w
		beq.s	@chkdel						; rings won't bounce in Hard Mode
		move.b	(v_vbla_byte).w,d0
		add.b	d7,d0
		andi.b	#3,d0
		bne.s	@chkdel
		jsr	(ObjFloorDist).l
		tst.w	d1
		bpl.s	@chkdel
		add.w	d1,obY(a0)
		move.w	obVelY(a0),d0
		asr.w	#2,d0
		sub.w	d0,obVelY(a0)
		neg.w	obVelY(a0)

	@chkdel:
		subq.b	#1,obDelayAni(a0)		; Decrement timer
		beq.w	DeleteObject			; if 0, delete
		cmpi.w	#$FF00,(v_limittop2).w	; is vertical wrapping enabled?
		beq.s	@chkflash				; if so, branch, to avoid deletion of Scattered Rings
;loc_121B8:
		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0				; has object moved below level boundary?
		bcs.s	RLoss_Delete			; if yes, branch

	@chkflash:
		move.b	obDelayAni(a0),d0
		btst	#0,d0
		beq.s	RLoss_DisplaySprite
		cmpi.b	#80,d0 					; within the last 80 frames of life, rings flash
		bhi.s	RLoss_DisplaySprite
		rts
; ===========================================================================

RLoss_DisplaySprite:
		lea	(v_spritequeue+$180).w,a1	; immediately jump to position in queue
		cmpi.w	#$7E,(a1)			; is this part of the queue full?
		bcc.s	@full				; if yes, branch
		addq.w	#2,(a1)				; increment sprite count
		adda.w	(a1),a1				; jump to empty position
		move.w	a0,(a1)				; insert RAM address for object

	@full:
		rts	
; ===========================================================================

RLoss_Collect:	; Routine 4
		addq.b	#2,obRoutine(a0)
		clr.b	obColType(a0)
		bsr.w	CollectRing

RLoss_Sparkle:	; Routine 6
		lea		(Ani_Ring).l,a1
		bsr.w	AnimateSprite

RLoss_DisplaySparkle:
		lea		(v_spritequeue+$80).w,a1	; immediately jump to position in queue
		cmpi.w	#$7E,(a1)			; is this part of the queue full?
		bcc.s	@full				; if yes, branch
		addq.w	#2,(a1)				; increment sprite count
		adda.w	(a1),a1				; jump to empty position
		move.w	a0,(a1)				; insert RAM address for object

	@full:
		rts	
; ===========================================================================

RLoss_Delete:	; Routine 8
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Ring Spawn Array
; ---------------------------------------------------------------------------

SpillRingData:  dc.w    $FF3C,$FC14, $00C4,$FC14, $FDC8,$FCB0, $0238,$FCB0 ; 4
                dc.w    $FCB0,$FDC8, $0350,$FDC8, $FC14,$FF3C, $03EC,$FF3C ; 8
                dc.w    $FC14,$00C4, $03EC,$00C4, $FCB0,$0238, $0350,$0238 ; 12
                dc.w    $FDC8,$0350, $0238,$0350, $FF3C,$03EC, $00C4,$03EC ; 16
                dc.w    $FF9E,$FE0A, $0062,$FE0A, $FEE4,$FE58, $011C,$FE58 ; 20
                dc.w    $FE58,$FEE4, $01A8,$FEE4, $FE0A,$FF9E, $01F6,$FF9E ; 24
                dc.w    $FE0A,$0062, $01F6,$0062, $FE58,$011C, $01A8,$011C ; 28
                dc.w    $FEE4,$01A8, $011C,$01A8, $FF9E,$0156, $0062,$0156 ; 32
                even
; ===========================================================================

; ===========================================================================
; ---------------------------------------------------------------------------
; Ring Spawn Array - Underwater
; ---------------------------------------------------------------------------

SpillRingData_Water:
				dc.w    $FF9C,$FE08, $0064,$FE08, $FEE4,$FE58, $011C,$FE58 ; 4
                dc.w    $FE58,$FEE4, $01A8,$FEE4, $FE08,$FF9C, $01F8,$FF9C ; 8
                dc.w    $FE08,$0060, $01F8,$0060, $FE58,$011C, $01A8,$011C ; 12
                dc.w    $FEE4,$01A8, $011C,$01A8, $FF9C,$01F4, $0064,$01F4 ; 16
                dc.w    $FFCE,$FF04, $0032,$FF04, $FF72,$FF2C, $008E,$FF2C ; 20
                dc.w    $FF2C,$FF72, $00D4,$FF72, $FF04,$FFCE, $00FC,$FFCE ; 24
                dc.w    $FF04,$0030, $00FC,$0030, $FF2C,$008E, $00D4,$008E ; 28
                dc.w    $FF72,$00D4, $008E,$00D4, $FFCE,$00FA, $0032,$00FA ; 32
                even
; ===========================================================================

RAttract_Init:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Ring,obMap(a0)
		move.w	#$2533,obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$100,obPriority(a0)
		move.b	#$47,obColType(a0)
		move.b	#8,obActWid(a0)
		move.b	#8,obHeight(a0)
		move.b	#8,obWidth(a0)

RAttract_Main:
		bsr.w	AttractedRing_Move
		btst	#7,(v_status_secondary).w
		bne.s	@hasshield
		move.b	#2,obRoutine(a0)
		moveq   #-1,d0					; Move #-1 to d0
		move.b  d0,obDelayAni(a0)		; Move d0 to new timer
		move.b  d0,(v_ani3_time).w		; Move d0 to old timer (for animation purposes)

	@hasshield:
		move.b	(v_ani2_frame).w,obFrame(a0)

		; Fix accidental deletion of scattered rings - REV C EDIT
		cmpi.w  #$FF00,(v_limittop2).w	; is vertical wrapping enabled?
		beq.s   @display       	; if so, branch
		; End of fix

		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0		; has object moved below level boundary?
		bcs.w	RLoss_Delete	; if yes, branch
	@display:	
		bra.w	DisplaySprite


; =============== S U B R O U T I N E =======================================


AttractedRing_Move:
		move.w	#$30,d1
		move.w	(v_player+obX).w,d0
		cmp.w	obX(a0),d0
		bcc.s	@branch1
		neg.w	d1
		tst.w	obVelX(a0)
		bmi.s	@branch2
		add.w	d1,d1
		add.w	d1,d1
		bra.s	@branch2
; ---------------------------------------------------------------------------

	@branch1: ;loc_1A954:
		tst.w	obVelX(a0)
		bpl.s	@branch2
		add.w	d1,d1
		add.w	d1,d1

	@branch2:				; AttractedRing_Move+1Aj ...
		add.w	d1,obVelX(a0)
		move.w	#$30,d1
		move.w	(v_player+obY).w,d0
		cmp.w	obY(a0),d0
		bcc.s	@branch3
		neg.w	d1
		tst.w	obVelY(a0)
		bmi.s	@branch4
		add.w	d1,d1
		add.w	d1,d1
		bra.s	@branch4
; ---------------------------------------------------------------------------

	@branch3: ;loc_1A97E:
		tst.w	obVelY(a0)
		bpl.s	@branch4
		add.w	d1,d1
		add.w	d1,d1

	@branch4:				; AttractedRing_Move+44j ...
		add.w	d1,obVelY(a0)
		jmp		SpeedToPos
; End of function AttractedRing_Move
