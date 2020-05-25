; ---------------------------------------------------------------------------
; Object 0F - "PRESS START BUTTON" and "TM" from title screen
; Also includes a Menu
; ---------------------------------------------------------------------------

PSBTM:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	PSB_Index(pc,d0.w),d1
		jsr		PSB_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
PSB_Index:
		dc.w PSB_Main-PSB_Index
		dc.w PSB_PrsStart-PSB_Index
		dc.w PSB_Menu-PSB_Index
		dc.w PSB_Exit-PSB_Index

obTitleOption:		equ $30
; ===========================================================================

PSB_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$D8,obX(a0)
		move.w	#$130,obScreenY(a0)
		move.l	#Map_PSB,obMap(a0)
		move.w	#$200,obGfx(a0)
		cmpi.b	#2,obFrame(a0)		; is object "PRESS START"?
		bcs.s	PSB_PrsStart		; if yes, branch

		addq.b	#4,obRoutine(a0)
		cmpi.b	#3,obFrame(a0)		; is the object	"TM"?
		bne.s	PSB_Exit			; if not, branch

		move.w	#$2510,obGfx(a0)	; "TM" specific code
		move.w	#$178,obX(a0)
		move.w	#$F8,obScreenY(a0)

PSB_Exit:	; Routine 6
		rts	
; ===========================================================================

PSB_PrsStart:	; Routine 2
		lea		(Ani_PSBTM).l,a1
		bra.w	AnimateSprite	; "PRESS START" is animated
; ===========================================================================

PSB_Menu:	; Routine 4
		moveq	#0,d2
		move.b	obTitleOption(a0),d2
		move.b	(v_jpadpress1).w,d0
		btst	#bitUp,d0
		beq.s	@chkdown
		subq.b	#1,d2
		bcc.s	@chkdown
		move.b	#2,d2	; WILL be 2 for LEVEL SELECT

	@chkdown:
		btst	#bitDn,d0
		beq.s	@setframe
		addq.b	#1,d2
		cmpi.b	#3,d2	; WILL be 3 for LEVEL SELECT
		blt.s	@setframe
		moveq	#0,d2

	@setframe:
		move.b	d2,obTitleOption(a0)
		addi.b	#4,d2
		move.b	d2,obFrame(a0)
		andi.b	#btnUp|btnDn,d0
		beq.s	@end
		moveq	#sfx_Switch,d0 ; selection blip sound
		jsr		PlaySound

	@end:
		rts