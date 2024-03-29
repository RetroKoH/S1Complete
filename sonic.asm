;  =========================================================================
; |           Sonic the Hedgehog Disassembly for Sega Mega Drive            |
;  =========================================================================
;
; Disassembly created by Hivebrain
; thanks to drx, Stealth and Esrael L.G. Neto

; ===========================================================================

		include "Debugger.asm"
		include	"Constants.asm"
		include	"Variables.asm"
		include	"Macros.asm"
SonicMappingsVer:	equ	1
		include	"SpritePiece.asm"

BackupSRAM:			equ 1
AddressSRAM:		equ 3	; 0 = odd+even; 2 = even only; 3 = odd only

ZoneCount:			equ 6	; discrete zones are: GHZ, MZ, SYZ, LZ, SLZ, and SBZ

OptimiseSound:		equ 0	; change to 1 to optimise sound queuing

DebugPathSwappers:	equ 1

; ===========================================================================

StartOfRom:
Vectors:
		dc.l v_systemstack&$FFFFFF	; Initial stack pointer value
		dc.l EntryPoint			; Start of program
		dc.l BusError			; Bus error
		dc.l AddressError		; Address error (4)
		dc.l IllegalInstr		; Illegal instruction
		dc.l ZeroDivide			; Division by zero
		dc.l ChkInstr			; CHK exception
		dc.l TrapvInstr			; TRAPV exception (8)
		dc.l PrivilegeViol		; Privilege violation
		dc.l Trace				; TRACE exception
		dc.l Line1010Emu		; Line-A emulator
		dc.l Line1111Emu		; Line-F emulator (12)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved) (16)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved) (20)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved)
		dc.l ErrorExcept		; Unused (reserved) (24)
		dc.l ErrorExcept		; Spurious exception
		dc.l ErrorTrap			; IRQ level 1
		dc.l ErrorTrap			; IRQ level 2
		dc.l ErrorTrap			; IRQ level 3 (28)
		dc.l HBlank				; IRQ level 4 (horizontal retrace interrupt)
		dc.l ErrorTrap			; IRQ level 5
		dc.l VBlank				; IRQ level 6 (vertical retrace interrupt)
		dc.l ErrorTrap			; IRQ level 7 (32)
		dc.l ErrorTrap			; TRAP #00 exception
		dc.l ErrorTrap			; TRAP #01 exception
		dc.l ErrorTrap			; TRAP #02 exception
		dc.l ErrorTrap			; TRAP #03 exception (36)
		dc.l ErrorTrap			; TRAP #04 exception
		dc.l ErrorTrap			; TRAP #05 exception
		dc.l ErrorTrap			; TRAP #06 exception
		dc.l ErrorTrap			; TRAP #07 exception (40)
		dc.l ErrorTrap			; TRAP #08 exception
		dc.l ErrorTrap			; TRAP #09 exception
		dc.l ErrorTrap			; TRAP #10 exception
		dc.l ErrorTrap			; TRAP #11 exception (44)
		dc.l ErrorTrap			; TRAP #12 exception
		dc.l ErrorTrap			; TRAP #13 exception
		dc.l ErrorTrap			; TRAP #14 exception
		dc.l ErrorTrap			; TRAP #15 exception (48)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)
		dc.l ErrorTrap			; Unused (reserved)

Hardware:		dc.b "SEGA MEGA DRIVE " ; Hardware system ID (Console name)
Date:			dc.b "(C)SEGA 1991.APR" ; Copyright holder and release date (generally year)
Title_Local:	dc.b "SONIC THE HEDGEHOG: 8x16                        " ; Domestic name
Title_Int:		dc.b "SONIC 1: 8x16                                   " ; International name
Serial:			dc.b "GM 00004049-01" ; Serial/version number (Rev non-0)
Checksum: 		dc.w $0
				dc.b "J               " ; I/O support
RomStartLoc:	dc.l StartOfRom		; Start address of ROM
RomEndLoc:		dc.l EndOfRom-1		; End address of ROM
RamStartLoc:	dc.l $FF0000		; Start address of RAM
RamEndLoc:		dc.l $FFFFFF		; End address of RAM
SRAMSupport:
				dc.b $52, $41, $A0+(BackupSRAM<<6)+(AddressSRAM<<3), $20
				dc.l $00200000		; SRAM start ($200001)
				dc.l $00200200		; SRAM end ($20xxxx)
Notes:			dc.b "                                                    " ; Notes (unused, anything can be put in this space, but it has to be 52 bytes.)
Region:			dc.b "JUE             " ; Region (Country code)
EndOfHeader:

; ===========================================================================
; Crash/Freeze the 68000. Unlike Sonic 2, Sonic 1 uses the 68000 for playing music, so it stops too

ErrorTrap:
		nop	
		nop	
		bra.s	ErrorTrap
; ===========================================================================

EntryPoint:
		tst.l	(z80_port_1_control).l ; test port A & B control registers
		bne.s	PortA_Ok
		tst.w	(z80_expansion_control).l ; test port C control register

PortA_Ok:
		bne.s	SkipSetup ; Skip the VDP and Z80 setup code if port A, B or C is ok...?
		lea		SetupValues(pc),a5	; Load setup values array address.
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		move.b	-$10FF(a1),d0	; get hardware version (from $A10001)
		andi.b	#$F,d0
		beq.s	SkipSecurity	; If the console has no TMSS, skip the security stuff.
		move.l	#'SEGA',$2F00(a1) ; move "SEGA" to TMSS register ($A14000)

SkipSecurity:
		move.w	(a4),d0	; clear write-pending flag in VDP to prevent issues if the 68k has been reset in the middle of writing a command long word to the VDP.
		moveq	#0,d0	; clear d0
		movea.l	d0,a6	; clear a6
		move.l	a6,usp	; set usp to $0

		moveq	#$17,d1
VDPInitLoop:
		move.b	(a5)+,d5	; add $8000 to value
		move.w	d5,(a4)		; move value to	VDP register
		add.w	d7,d5		; next register
		dbf	d1,VDPInitLoop
		
		move.l	(a5)+,(a4)
		move.w	d0,(a3)		; clear	the VRAM
		move.w	d7,(a1)		; stop the Z80
		move.w	d7,(a2)		; reset	the Z80

WaitForZ80:
		btst	d0,(a1)		; has the Z80 stopped?
		bne.s	WaitForZ80	; if not, branch

		moveq	#$25,d2
Z80InitLoop:
		move.b	(a5)+,(a0)+
		dbf	d2,Z80InitLoop
		
		move.w	d0,(a2)
		move.w	d0,(a1)		; start	the Z80
		move.w	d7,(a2)		; reset	the Z80

ClrRAMLoop:
		move.l	d0,-(a6)	; clear 4 bytes of RAM
		dbf	d6,ClrRAMLoop	; repeat until the entire RAM is clear
		move.l	(a5)+,(a4)	; set VDP display mode and increment mode
		move.l	(a5)+,(a4)	; set VDP to CRAM write

		moveq	#$1F,d3	; set repeat times
ClrCRAMLoop:
		move.l	d0,(a3)	; clear 2 palettes
		dbf	d3,ClrCRAMLoop	; repeat until the entire CRAM is clear
		move.l	(a5)+,(a4)	; set VDP to VSRAM write

		moveq	#$13,d4
ClrVSRAMLoop:
		move.l	d0,(a3)	; clear 4 bytes of VSRAM.
		dbf	d4,ClrVSRAMLoop	; repeat until the entire VSRAM is clear
		moveq	#3,d5

PSGInitLoop:
		move.b	(a5)+,$11(a3)	; reset	the PSG
		dbf	d5,PSGInitLoop	; repeat for other channels
		move.w	d0,(a2)
		movem.l	(a6),d0-a6	; clear all registers
		disable_ints

SkipSetup:
		bra.s	GameProgram	; begin game

; ===========================================================================
SetupValues:	dc.w $8000		; VDP register start number
		dc.w $3FFF		; size of RAM/4
		dc.w $100		; VDP register diff

		dc.l z80_ram		; start	of Z80 RAM
		dc.l z80_bus_request	; Z80 bus request
		dc.l z80_reset		; Z80 reset
		dc.l vdp_data_port	; VDP data
		dc.l vdp_control_port	; VDP control

		dc.b 4			; VDP $80 - 8-colour mode
		dc.b $14		; VDP $81 - Megadrive mode, DMA enable
		dc.b ($C000>>10)	; VDP $82 - foreground nametable address
		dc.b ($F000>>10)	; VDP $83 - window nametable address
		dc.b ($E000>>13)	; VDP $84 - background nametable address
		dc.b ($D800>>9)		; VDP $85 - sprite table address
		dc.b 0			; VDP $86 - unused
		dc.b 0			; VDP $87 - background colour
		dc.b 0			; VDP $88 - unused
		dc.b 0			; VDP $89 - unused
		dc.b 255		; VDP $8A - HBlank register
		dc.b 0			; VDP $8B - full screen scroll
		dc.b $81		; VDP $8C - 40 cell display
		dc.b ($DC00>>10)	; VDP $8D - hscroll table address
		dc.b 0			; VDP $8E - unused
		dc.b 1			; VDP $8F - VDP increment
		dc.b 1			; VDP $90 - 64 cell hscroll size
		dc.b 0			; VDP $91 - window h position
		dc.b 0			; VDP $92 - window v position
		dc.w $FFFF		; VDP $93/94 - DMA length
		dc.w 0			; VDP $95/96 - DMA source
		dc.b $80		; VDP $97 - DMA fill VRAM
		dc.l $40000080		; VRAM address 0

		dc.b $AF		; xor	a
		dc.b $01, $D9, $1F	; ld	bc,1fd9h
		dc.b $11, $27, $00	; ld	de,0027h
		dc.b $21, $26, $00	; ld	hl,0026h
		dc.b $F9		; ld	sp,hl
		dc.b $77		; ld	(hl),a
		dc.b $ED, $B0		; ldir
		dc.b $DD, $E1		; pop	ix
		dc.b $FD, $E1		; pop	iy
		dc.b $ED, $47		; ld	i,a
		dc.b $ED, $4F		; ld	r,a
		dc.b $D1		; pop	de
		dc.b $E1		; pop	hl
		dc.b $F1		; pop	af
		dc.b $08		; ex	af,af'
		dc.b $D9		; exx
		dc.b $C1		; pop	bc
		dc.b $D1		; pop	de
		dc.b $E1		; pop	hl
		dc.b $F1		; pop	af
		dc.b $F9		; ld	sp,hl
		dc.b $F3		; di
		dc.b $ED, $56		; im1
		dc.b $36, $E9		; ld	(hl),e9h
		dc.b $E9		; jp	(hl)

		dc.w $8104		; VDP display mode
		dc.w $8F02		; VDP increment
		dc.l $C0000000		; CRAM write mode
		dc.l $40000010		; VSRAM address 0

		dc.b $9F, $BF, $DF, $FF	; values for PSG channel volumes
; ===========================================================================

GameProgram:
		tst.w	(vdp_control_port).l
		btst	#6,($A1000D).l
		beq.s	CheckSumCheck
		cmpi.l	#'init',(v_init).w ; has checksum routine already run?
		beq.w	GameInit	; if yes, branch

CheckSumCheck: ; FASTER CHECKSUM CHECK BY MARKEYJESTER; Fixed by Ralakimus
		movea.w	#$0200,a0				; prepare start address
		move.l	(RomEndLoc).w,d7		; load size
		sub.l	a0,d7					; minus start address
		move.b	d7,d5					; copy end nybble
		andi.w	#$000F,d5				; get only the remaining nybble
		lsr.l	#$04,d7					; divide the size by 20
		move.w	d7,d6					; load lower word size
		subq.w	#1,d6					; fix lower word size for dbf
		swap	d7						; get upper word size
		moveq	#$00,d0					; clear d0

CS_MainBlock:
		add.w	(a0)+,d0				; modular checksum (8 words)
		add.w	(a0)+,d0				; ''
		add.w	(a0)+,d0				; ''
		add.w	(a0)+,d0				; ''
		add.w	(a0)+,d0				; ''
		add.w	(a0)+,d0				; ''
		add.w	(a0)+,d0				; ''
		add.w	(a0)+,d0				; ''
		dbf		d6,CS_MainBlock			; repeat until all main block sections are done
		dbf		d7,CS_MainBlock			; ''
		lsr.w	#$01,d5					; divide remaining nybble by 2
		bcs.s	CS_Remains				; if there are remaining nybble, branch
		beq.s	CS_Finish				; if there is no remaining nybble, branch

CS_Remains:
		add.w	(a0)+,d0				; add remaining words
		dbf		d5,CS_Remains			; repeat until the remaining words are done

CS_Finish:
		cmp.w	(Checksum).w,d0			; does the checksum match?
		bne.w	CheckSumError			; if not, branch

CheckSumOk:
		lea		($FFFFFE00).w,a6
		moveq	#0,d7
		move.w	#$7F,d6
	@clearRAM:
		move.l	d7,(a6)+
		dbf		d6,@clearRAM	; clear RAM ($FE00-$FFFF)

		move.b	(z80_version).l,d0
		andi.b	#$C0,d0
		move.b	d0,(v_megadrive).w ; get region setting
		move.l	#'init',(v_init).w ; set flag so checksum won't run again

GameInit:
		lea		($FF0000).l,a6
		moveq	#0,d7
		move.w	#$3F7F,d6
	@clearRAM:
		move.l	d7,(a6)+
		dbf		d6,@clearRAM			; clear RAM ($0000-$FDFF)

		jsr		(InitDMAQueue).l 		; Flamewing DMA Queue
		bsr.w	VDPSetupGame
		bsr.w	SoundDriverLoad
		bsr.w	JoypadInit
		move.b	#id_Sega,(v_gamemode).w ; set Game Mode to Sega Screen

InitSRAM:
		move.b  #1,(SRAM_access_flag).l	; Enable SRAM writing
		lea 	($200001).l,a0	; Load SRAM memory into a0 (Change the last digit to 0 if you're using even SRAM)
		movep.l 0(a0),d0		; Get the existing string at the start of SRAM
		move.l  #"SRAM",d1		; Write the string "SRAM" to d1
		cmp.l   d0,d1			; Was it already in SRAM?
		beq.s   @Continue		; If so, skip
		movep.l d1,0(a0)		; Write string "SRAM"
		; Here is where you initialize values like lives or level. If you're using 8 bit values, you can only use every other byte.
		; Example - 8(a0) => $A(a0)
 
	@Continue:
        clr.b    (SRAM_access_flag).l	; Disable SRAM writing

MainGameLoop:
		move.b	(v_gamemode).w,d0		; load Game Mode
		andi.w	#$7C,d0					; limit Game Mode value to $1C max (change to a maximum of 7C to add more game modes)
		movea.l	GameModeArray(pc,d0.w),a0
		jsr		(a0)					; jump to apt location in ROM
		bra.s	MainGameLoop			; loop indefinitely
; ===========================================================================
; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

GameModeArray:

ptr_GM_Sega:		dc.l	GM_Sega			; Sega Screen ($00)
ptr_GM_Title:		dc.l	GM_Title		; Title	Screen ($04)
ptr_GM_Demo:		dc.l	GM_Level		; Demo Mode ($08)
ptr_GM_Level:		dc.l	GM_Level		; Normal Level ($0C)
ptr_GM_Special:		dc.l	GM_Special		; Special Stage	($10)
ptr_GM_Cont:		dc.l	GM_Continue		; Continue Screen ($14)
ptr_GM_Ending:		dc.l	GM_Ending		; End of game sequence ($18)
ptr_GM_Credits:		dc.l	GM_Credits		; Credits ($1C)
ptr_GM_BonusStage:	dc.l	GM_Level		; Bonus Stage ($20)
ptr_GM_MenuScreen:	dc.l	GM_MenuScreen	; NEW Sonic 2 style Level Select or Time Attack ($24)
; ===========================================================================

CheckSumError:
		jsr		(InitDMAQueue).l 				; Flamewing DMA Queue
		bsr.w	VDPSetupGame
		move.l	#$C0000000,(vdp_control_port).l ; set VDP to CRAM write
		moveq	#$3F,d7

	@fillred:
		move.w	#cRed,(vdp_data_port).l ; fill palette with red
		dbf		d7,@fillred	; repeat $3F more times

	@endlessloop:
		bra.s	@endlessloop
; ===========================================================================

Art_Text:	incbin	"artunc\menutext.bin" ; text used in level select and debug mode
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Vertical interrupt
; ---------------------------------------------------------------------------

VBlank:
		movem.l	d0-a6,-(sp)
		tst.b	(v_vbla_routine).w
		beq.s	VBla_00
		move.w	(vdp_control_port).l,d0
		move.l	#$40000010,(vdp_control_port).l
		move.l	(v_scrposy_dup).w,(vdp_data_port).l ; send screen y-axis pos. to VSRAM
		btst	#6,(v_megadrive).w ; is Megadrive PAL?
		beq.s	@notPAL		; if not, branch

		move.w	#$700,d0
	@waitPAL:
		dbf	d0,@waitPAL ; wait here in a loop doing nothing for a while...

	@notPAL:
		move.b	(v_vbla_routine).w,d0
		move.b	#0,(v_vbla_routine).w
		move.w	#1,(f_hbla_pal).w
		andi.w	#$3E,d0
		move.w	VBla_Index(pc,d0.w),d0
		jsr	VBla_Index(pc,d0.w)

VBla_Music:
		jsr	(UpdateMusic).l

VBla_Exit:
		addq.l	#1,(v_vbla_count).w
		movem.l	(sp)+,d0-a6
		rte	
; ===========================================================================
VBla_Index:	dc.w VBla_00-VBla_Index, VBla_02-VBla_Index
		dc.w VBla_04-VBla_Index, VBla_06-VBla_Index
		dc.w VBla_08-VBla_Index, VBla_0A-VBla_Index
		dc.w VBla_0C-VBla_Index, VBla_0E-VBla_Index
		dc.w VBla_10-VBla_Index, VBla_12-VBla_Index
		dc.w VBla_14-VBla_Index, VBla_16-VBla_Index
		dc.w VBla_0C-VBla_Index
; ===========================================================================

VBla_00:
		cmpi.b	#$80+id_Level,(v_gamemode).w
		beq.s	@islevel
		cmpi.b	#id_Level,(v_gamemode).w ; is game on a level?
		bne.w	VBla_Music	; if not, branch

	@islevel:
		cmpi.b	#id_LZ,(v_zone).w ; is level LZ ?
		bne.w	VBla_Music	; if not, branch

		move.w	(vdp_control_port).l,d0
		btst	#6,(v_megadrive).w ; is Megadrive PAL?
		beq.s	@notPAL		; if not, branch

		move.w	#$700,d0
	@waitPAL:
		dbf	d0,@waitPAL

	@notPAL:
		move.w	#1,(f_hbla_pal).w ; set HBlank flag
		stopZ80
		waitZ80
		tst.b	(f_wtr_state).w	; is water above top of screen?
		bne.s	@waterabove 	; if yes, branch

		writeCRAM	v_pal_dry,$80,0
		bra.s	@waterbelow

@waterabove:
		writeCRAM	v_pal_water,$80,0

	@waterbelow:
		move.w	(v_hbla_hreg).w,(a5)
		startZ80
		bra.w	VBla_Music
; ===========================================================================

VBla_02:
		bsr.w	sub_106E

VBla_14:
		tst.w	(v_demolength).w
		beq.w	@end
		subq.w	#1,(v_demolength).w

	@end:
		rts	
; ===========================================================================

VBla_04:
		bsr.w	sub_106E
		bsr.w	LoadTilesAsYouMove_BGOnly
		bsr.w	sub_1642
		tst.w	(v_demolength).w
		beq.w	@end
		subq.w	#1,(v_demolength).w

	@end:
		rts	
; ===========================================================================

VBla_06:
		bsr.w	sub_106E
		rts	
; ===========================================================================

VBla_10:
		cmpi.b	#id_Special,(v_gamemode).w ; is game on special stage?
		beq.w	VBla_0A		; if yes, branch

VBla_08:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		tst.b	(f_wtr_state).w
		bne.s	@waterabove

		writeCRAM	v_pal_dry,$80,0
		bra.s	@waterbelow

@waterabove:
		writeCRAM	v_pal_water,$80,0

	@waterbelow:
		move.w	(v_hbla_hreg).w,(a5)

		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		jsr	(ProcessDMAQueue).l ; DMA Queue

	@nochg:
		startZ80
		movem.l	(v_screenposx).w,d0-d7
		movem.l	d0-d7,(v_screenposx_dup).w
		movem.l	(v_fg_scroll_flags).w,d0-d1
		movem.l	d0-d1,(v_fg_scroll_flags_dup).w
		cmpi.b	#96,(v_hbla_line).w
		bhs.s	Demo_Time
		move.b	#1,($FFFFF64F).w
		addq.l	#4,sp
		bra.w	VBla_Exit

; ---------------------------------------------------------------------------
; Subroutine to	run a demo for an amount of time
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Demo_Time:
		bsr.w	LoadTilesAsYouMove
		jsr		(AnimateLevelGfx).l
		jsr		(HUD_Update).l
		bsr.w	ProcessDPLC2
		tst.w	(v_demolength).w ; is there time left on the demo?
		beq.w	@end		; if not, branch
		subq.w	#1,(v_demolength).w ; subtract 1 from time left

	@end:
		rts	
; End of function Demo_Time

; ===========================================================================

VBla_0A:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		writeCRAM	v_pal_dry,$80,0
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		startZ80
		bsr.w	PalCycle_SS
		jsr	(ProcessDMAQueue).l ; DMA Queue

	@nochg:
		cmpi.b	#96,(v_hbla_line).w
		bcc.s	@update
		bra.w	@end

	@update:
		jsr	SS_LoadWalls
		jsr	HUD_Update_SS

		tst.w	(v_demolength).w	; is there time left on the demo?
		beq.w	@end	; if not, return
		subq.w	#1,(v_demolength).w	; subtract 1 from time left in demo

	@end:
		rts	
; ===========================================================================

VBla_0C:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		tst.b	(f_wtr_state).w
		bne.s	@waterabove

		writeCRAM	v_pal_dry,$80,0
		bra.s	@waterbelow

@waterabove:
		writeCRAM	v_pal_water,$80,0

	@waterbelow:
		move.w	(v_hbla_hreg).w,(a5)
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		jsr	(ProcessDMAQueue).l ; DMA_Queue

	@nochg:
		startZ80
		movem.l	(v_screenposx).w,d0-d7
		movem.l	d0-d7,(v_screenposx_dup).w
		movem.l	(v_fg_scroll_flags).w,d0-d1
		movem.l	d0-d1,(v_fg_scroll_flags_dup).w
		bsr.w	LoadTilesAsYouMove
		jsr		(AnimateLevelGfx).l
		jsr		(HUD_Update).l
		bsr.w	sub_1642
		rts	
; ===========================================================================

VBla_0E:
		bsr.w	sub_106E
		addq.b	#1,($FFFFF628).w
		move.b	#$E,(v_vbla_routine).w
		rts	
; ===========================================================================

VBla_12:
		bsr.w	sub_106E
		move.w	(v_hbla_hreg).w,(a5)
		bra.w	sub_1642
; ===========================================================================

VBla_16:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		writeCRAM	v_pal_dry,$80,0
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		startZ80
		jsr	(ProcessDMAQueue).l

	@nochg:
		cmpi.b	#96,(v_hbla_line).w
		bcc.s	@update
		bra.w	@end
		
	@update:
		jsr	SS_LoadWalls
		jsr	HUD_Update_SS

		tst.w	(v_demolength).w
		beq.w	@end
		subq.w	#1,(v_demolength).w

	@end:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_106E:
		stopZ80
		waitZ80
		bsr.w	ReadJoypads
		tst.b	(f_wtr_state).w ; is water above top of screen?
		bne.s	@waterabove	; if yes, branch
		writeCRAM	v_pal_dry,$80,0
		bra.s	@waterbelow

	@waterabove:
		writeCRAM	v_pal_water,$80,0

	@waterbelow:
		writeVRAM	v_spritetablebuffer,$280,vram_sprites
		writeVRAM	v_hscrolltablebuffer,$380,vram_hscroll
		startZ80
		rts	
; End of function sub_106E

; ---------------------------------------------------------------------------
; Horizontal interrupt
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HBlank:
		disable_ints
		tst.w	(f_hbla_pal).w	; is palette set to change?
		beq.s	@nochg		; if not, branch
		move.w	#0,(f_hbla_pal).w
		movem.l	a0-a1,-(sp)
		lea	(vdp_data_port).l,a1
		lea	(v_pal_water).w,a0 ; get palette from RAM
		move.l	#$C0000000,4(a1) ; set VDP to CRAM write
		move.l	(a0)+,(a1)	; move palette to CRAM
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.w	#$8A00+223,4(a1) ; reset HBlank register
		movem.l	(sp)+,a0-a1
		tst.b	($FFFFF64F).w
		bne.s	loc_119E

	@nochg:
		rte	
; ===========================================================================

loc_119E:
		clr.b	($FFFFF64F).w
		movem.l	d0-a6,-(sp)
		bsr.w	Demo_Time
		jsr	(UpdateMusic).l
		movem.l	(sp)+,d0-a6
		rte	
; End of function HBlank

; ---------------------------------------------------------------------------
; Subroutine to	initialise joypads
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


JoypadInit:
		stopZ80
		waitZ80
		moveq	#$40,d0
		move.b	d0,($A10009).l	; init port 1 (joypad 1)
		move.b	d0,($A1000B).l	; init port 2 (joypad 2)
		move.b	d0,($A1000D).l	; init port 3 (expansion/extra)
		startZ80
		rts	
; End of function JoypadInit

; ---------------------------------------------------------------------------
; Subroutine to	read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ReadJoypads:
		lea	(v_jpadhold1).w,a0	; address where joypad states are written
		lea	($A10003).l,a1		; first	joypad port
		bsr.s	Joypad_Read		; do the first joypad
		addq.w	#2,a1			; do the second	joypad

Joypad_Read:
		move.b	#0,(a1)
		nop	
		nop	
		move.b	(a1),d0
		lsl.b	#2,d0
		andi.b	#$C0,d0
		move.b	#$40,(a1)
		nop	
		nop	
		move.b	(a1),d1
		andi.b	#$3F,d1
		or.b	d1,d0
		not.b	d0
		move.b	(a0),d1
		eor.b	d0,d1
		move.b	d0,(a0)+
		and.b	d0,d1
		move.b	d1,(a0)+
		rts	
; End of function ReadJoypads


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


VDPSetupGame:
		lea	(vdp_control_port).l,a0
		lea	(vdp_data_port).l,a1
		lea	(VDPSetupArray).l,a2
		moveq	#$12,d7

	@setreg:
		move.w	(a2)+,(a0)
		dbf	d7,@setreg	; set the VDP registers

		move.w	(VDPSetupArray+2).l,d0
		move.w	d0,(v_vdp_buffer1).w
		move.w	#$8A00+223,(v_hbla_hreg).w	; H-INT every 224th scanline
		moveq	#0,d0
		move.l	#$C0000000,(vdp_control_port).l ; set VDP to CRAM write
		move.w	#$3F,d7

	@clrCRAM:
		move.w	d0,(a1)
		dbf	d7,@clrCRAM	; clear	the CRAM

		clr.l	(v_scrposy_dup).w
		clr.l	(v_scrposx_dup).w
		move.l	d1,-(sp)
		fillVRAM	0,$FFFF,0

	@waitforDMA:
		move.w	(a5),d1
		btst	#1,d1		; is DMA (fillVRAM) still running?
		bne.s	@waitforDMA	; if yes, branch

		move.w	#$8F02,(a5)	; set VDP increment size
		move.l	(sp)+,d1
		rts	
; End of function VDPSetupGame

; ===========================================================================
VDPSetupArray:	dc.w $8004		; 8-colour mode
		dc.w $8134		; enable V.interrupts, enable DMA
		dc.w $8200+(vram_fg>>10) ; set foreground nametable address
		dc.w $8300+($A000>>10)	; set window nametable address
		dc.w $8400+(vram_bg>>13) ; set background nametable address
		dc.w $8500+(vram_sprites>>9) ; set sprite table address
		dc.w $8600		; unused
		dc.w $8700		; set background colour (palette entry 0)
		dc.w $8800		; unused
		dc.w $8900		; unused
		dc.w $8A00		; default H.interrupt register
		dc.w $8B00		; full-screen vertical scrolling
		dc.w $8C81		; 40-cell display mode
		dc.w $8D00+(vram_hscroll>>10) ; set background hscroll address
		dc.w $8E00		; unused
		dc.w $8F02		; set VDP increment size
		dc.w $9001		; 64-cell hscroll size
		dc.w $9100		; window horizontal position
		dc.w $9200		; window vertical position

; ---------------------------------------------------------------------------
; Subroutine to	clear the screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ClearScreen:
		fillVRAM	0,$FFF,vram_fg ; clear foreground namespace

	@wait1:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	@wait1

		move.w	#$8F02,(a5)
		fillVRAM	0,$FFF,vram_bg ; clear background namespace

	@wait2:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	@wait2

		move.w	#$8F02,(a5)
		clr.l	(v_scrposy_dup).w
		clr.l	(v_scrposx_dup).w

		lea	(v_spritetablebuffer).w,a1
		moveq	#0,d0
		move.w	#$9F,d1 ; WAS $A0 - MJ fix

	@clearsprites:
		move.l	d0,(a1)+
		dbf	d1,@clearsprites ; clear sprite table (in RAM)

		lea	(v_hscrolltablebuffer).w,a1
		moveq	#0,d0
		move.w	#$DF,d1 ; WAS $100 - MJ Fix

	@clearhscroll:
		move.l	d0,(a1)+
		dbf	d1,@clearhscroll ; clear hscroll table (in RAM)
		rts	
; End of function ClearScreen

; ---------------------------------------------------------------------------
; Subroutine to	load the sound driver
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SoundDriverLoad:
		nop	
		stopZ80
		resetZ80
		lea	(Kos_Z80).l,a0	; load sound driver
		lea	(z80_ram).l,a1	; target Z80 RAM
		bsr.w	KosDec		; decompress
		resetZ80a
		nop	
		nop	
		nop	
		nop	
		resetZ80
		startZ80
		rts	
; End of function SoundDriverLoad

		include	"_incObj\sub PlaySound.asm"
		include	"_inc\PauseGame.asm"

; ---------------------------------------------------------------------------
; Subroutine to	copy a tile map from RAM to VRAM namespace

; input:
;	a1 = tile map address
;	d0 = VRAM address
;	d1 = width (cells)
;	d2 = height (cells)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


TilemapToVRAM:
		lea	(vdp_data_port).l,a6
		move.l	#$800000,d4

	Tilemap_Line:
		move.l	d0,4(a6)	; move d0 to VDP_control_port
		move.w	d1,d3

	Tilemap_Cell:
		move.w	(a1)+,(a6)	; write value to namespace
		dbf	d3,Tilemap_Cell	; next tile
		add.l	d4,d0		; goto next line
		dbf	d2,Tilemap_Line	; next line
		rts	
; End of function TilemapToVRAM


		include	"_inc\DMA Queue.asm"

		include	"_inc\Nemesis Decompression.asm"
		include "_inc\Uncompressed Art Loading.asm"
		include	"_inc\Comper Decompression.asm"

; ---------------------------------------------------------------------------
; Subroutine to load the art for the animals for the current zone
; I FORGOT WHO HELPED WITH THIS... MAY HAVE BEEN FROM THE ADD NEW ZONE GUIDE
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AddAnimalPLC:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		cmpi.w	#id_BZ,d0

		blt.s	@notnewzone
		subq	#1,d0          ; Add 1 to skip Ending
	@notnewzone:
		addi.w	#plcid_GHZAnimals,d0  ; index of GHZ Animals
;		bra.s	AddPLC
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
; Subroutine to load pattern load cues (aka to queue pattern load requests)
; ---------------------------------------------------------------------------

; ARGUMENTS
; d0 = index of PLC list
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; LoadPLC:
AddPLC:
		movem.l	a1-a2,-(sp)
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1		; jump to relevant PLC
		lea	(v_plc_buffer).w,a2 ; PLC buffer space

	@findspace:
		tst.l	(a2)		; is space available in RAM?
		beq.s	@copytoRAM	; if yes, branch
		addq.w	#6,a2		; if not, try next space
		bra.s	@findspace
; ===========================================================================

@copytoRAM:
		move.w	(a1)+,d0	; get length of PLC
		bmi.s	@skip

	@loop:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+	; copy PLC to RAM
		dbf	d0,@loop	; repeat for length of PLC

	@skip:
		movem.l	(sp)+,a1-a2 ; a1=object
		rts	
; End of function AddPLC


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; Queue pattern load requests, but clear the PLQ first

; ARGUMENTS
; d0 = index of PLC list (see ArtLoadCues)

; NOTICE: This subroutine does not check for buffer overruns. The programmer
;	  (or hacker) is responsible for making sure that no more than
;	  16 load requests are copied into the buffer.
;	  _________DO NOT PUT MORE THAN 16 LOAD REQUESTS IN A LIST!__________
;         (or if you change the size of Plc_Buffer, the limit becomes (Plc_Buffer_Only_End-Plc_Buffer)/6)

; LoadPLC2:
NewPLC:
		movem.l	a1-a2,-(sp)
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1	; jump to relevant PLC
		bsr.s	ClearPLC	; erase any data in PLC buffer space
		lea	(v_plc_buffer).w,a2
		move.w	(a1)+,d0	; get length of PLC
		bmi.s	@skip		; if it's negative, skip the next loop

	@loop:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+	; copy PLC to RAM
		dbf	d0,@loop		; repeat for length of PLC

	@skip:
		movem.l	(sp)+,a1-a2
		rts	
; End of function NewPLC

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; ---------------------------------------------------------------------------
; Subroutine to	clear the pattern load cues
; ---------------------------------------------------------------------------

; Clear the pattern load queue ($FFF680 - $FFF700)


ClearPLC:
		lea	(v_plc_buffer).w,a2 ; PLC buffer space in RAM
		moveq	#$1F,d0	; bytesToLcnt(v_plc_buffer_end-v_plc_buffer)

	@loop:
		clr.l	(a2)+
		dbf	d0,@loop
		rts	
; End of function ClearPLC

; ---------------------------------------------------------------------------
; Subroutine to	use graphics listed in a pattern load cue
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


RunPLC:
		tst.l	(v_plc_buffer).w
		beq.s	Rplc_Exit
		tst.w	(f_plc_execute).w
		bne.s	Rplc_Exit
		movea.l	(v_plc_buffer).w,a0
		lea	(NemPCD_WriteRowToVDP).l,a3
		lea	(v_ngfx_buffer).w,a1
		move.w	(a0)+,d2
		bpl.s	loc_160E
		adda.w	#$A,a3

loc_160E:
		andi.w	#$7FFF,d2
		bsr.w	NemDec_BuildCodeTable
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6
		moveq	#0,d0
		move.l	a0,(v_plc_buffer).w
		move.l	a3,(v_ptrnemcode).w
		move.l	d0,($FFFFF6E4).w
		move.l	d0,($FFFFF6E8).w
		move.l	d0,($FFFFF6EC).w
		move.l	d5,($FFFFF6F0).w
		move.l	d6,($FFFFF6F4).w
		move.w	d2,(f_plc_execute).w ; Fix Race Condition

Rplc_Exit:
		rts	
; End of function RunPLC


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_1642:
		tst.w	(f_plc_execute).w
		beq.w	locret_16DA
		move.w	#9,($FFFFF6FA).w
		moveq	#0,d0
		move.w	($FFFFF684).w,d0
		addi.w	#$120,($FFFFF684).w
		bra.s	loc_1676
; End of function sub_1642


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


; sub_165E:
ProcessDPLC2:
		tst.w	(f_plc_execute).w
		beq.s	locret_16DA
		move.w	#3,($FFFFF6FA).w
		moveq	#0,d0
		move.w	($FFFFF684).w,d0
		addi.w	#$60,($FFFFF684).w

loc_1676:
		lea	(vdp_control_port).l,a4
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,(a4)
		subq.w	#4,a4
		movea.l	(v_plc_buffer).w,a0
		movea.l	(v_ptrnemcode).w,a3
		move.l	($FFFFF6E4).w,d0
		move.l	($FFFFF6E8).w,d1
		move.l	($FFFFF6EC).w,d2
		move.l	($FFFFF6F0).w,d5
		move.l	($FFFFF6F4).w,d6
		lea	(v_ngfx_buffer).w,a1

loc_16AA:
		movea.w	#8,a5
		bsr.w	NemPCD_NewRow
		subq.w	#1,(f_plc_execute).w
		beq.s	loc_16DC
		subq.w	#1,($FFFFF6FA).w
		bne.s	loc_16AA
		move.l	a0,(v_plc_buffer).w
		move.l	a3,(v_ptrnemcode).w
		move.l	d0,($FFFFF6E4).w
		move.l	d1,($FFFFF6E8).w
		move.l	d2,($FFFFF6EC).w
		move.l	d5,($FFFFF6F0).w
		move.l	d6,($FFFFF6F4).w

locret_16DA:
		rts	
; ===========================================================================

loc_16DC: ; Fixed via Vladikcomper's plc fix. Thanks Ralakimus for pointing this out
        lea		(v_plc_buffer).w,a0
        lea		6(a0),a1
        moveq	#$E,d0        ; do $F cues

loc_16E2:
        move.l	(a1)+,(a0)+
        move.w	(a1)+,(a0)+
        dbf		d0,loc_16E2
        moveq	#0,d0
        move.l	d0,(a0)+    ; clear the last cue to avoid overcopying it
        move.w	d0,(a0)+    ;
        rts
; End of function ProcessDPLC2

; ---------------------------------------------------------------------------
; Subroutine to	execute	the pattern load cue
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


QuickPLC:
		lea	(ArtLoadCues).l,a1 ; load the PLC index
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		move.w	(a1)+,d1	; get length of PLC

	Qplc_Loop:
		movea.l	(a1)+,a0	; get art pointer
		moveq	#0,d0
		move.w	(a1)+,d0	; get VRAM address
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,(vdp_control_port).l ; converted VRAM address to VDP format
		bsr.w	NemDec		; decompress
		dbf	d1,Qplc_Loop	; repeat for length of PLC
		rts	
; End of function QuickPLC

		include	"_inc\Enigma Decompression.asm"
		include	"_inc\Kosinski Decompression.asm"

		include	"_inc\PaletteCycle.asm"

Pal_GHZCyc:		incbin	"palette\Cycle - GHZ.bin"
Pal_LZCyc1:		incbin	"palette\Cycle - LZ Waterfall.bin"
Pal_LZCyc2:		incbin	"palette\Cycle - LZ Conveyor Belt.bin"
Pal_LZCyc3:		incbin	"palette\Cycle - LZ Conveyor Belt Underwater.bin"
Pal_SBZ3Cyc1:	incbin	"palette\Cycle - SBZ3 Waterfall.bin"
Pal_SLZCyc:		incbin	"palette\Cycle - SLZ.bin"
Pal_SYZCyc1:	incbin	"palette\Cycle - SYZ1.bin"
Pal_SYZCyc2:	incbin	"palette\Cycle - SYZ2.bin"

		include	"_inc\SBZ Palette Scripts.asm"

Pal_SBZCyc1:	incbin	"palette\Cycle - SBZ 1.bin"
Pal_SBZCyc2:	incbin	"palette\Cycle - SBZ 2.bin"
Pal_SBZCyc3:	incbin	"palette\Cycle - SBZ 3.bin"
Pal_SBZCyc4:	incbin	"palette\Cycle - SBZ 4.bin"
Pal_SBZCyc5:	incbin	"palette\Cycle - SBZ 5.bin"
Pal_SBZCyc6:	incbin	"palette\Cycle - SBZ 6.bin"
Pal_SBZCyc7:	incbin	"palette\Cycle - SBZ 7.bin"
Pal_SBZCyc8:	incbin	"palette\Cycle - SBZ 8.bin"
Pal_SBZCyc9:	incbin	"palette\Cycle - SBZ 9.bin"
Pal_SBZCyc10:	incbin	"palette\Cycle - SBZ 10.bin"

; ---------------------------------------------------------------------------
; Subroutine to	fade in from black - Proper Fade
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeIn:
		move.w	#$003F,(v_pfade_start).w	; set start position = 0; size = $40

PalFadeIn_Alt:						; start position and size are already set
		moveq	#0,d0
		lea		(v_pal_dry).w,a0	; load the main palette to a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		moveq	#cBlack,d1			; cBlack=0
		move.b	(v_pfade_size).w,d0

	@fill:
		move.w	d1,(a0)+
		dbf		d0,@fill	; fill palette with black
		moveq	#$0E,d4		; MJ: prepare maximum color check
		moveq	#$00,d6		; MJ: clear d6

	@mainloop:
		bsr.w	RunPLC
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bchg	#$00,d6					; MJ: change delay counter
		beq		@mainloop				; MJ: if null, delay a frame
		bsr.s	FadeIn_FromBlack
		subq.b	#$02,d4					; MJ: decrease color check
		bne		@mainloop				; MJ: if it has not reached null, branch
		move.b	#$12,(v_vbla_routine).w	; MJ: wait for V-blank again (so colors transfer)
		bra		WaitForVBla				; MJ: ''
; End of function PaletteFadeIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeIn_FromBlack:
		moveq	#0,d0
		lea		(v_pal_dry).w,a0
		lea		(v_pal_dry_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

	@addcolour:
		bsr.s	FadeIn_AddColour ; increase colour
		dbf		d0,@addcolour	; repeat for size of palette

		cmpi.b	#id_LZ,(v_zone).w	; is level Labyrinth?
		bne.s	@exit		; if not, branch

		moveq	#0,d0
		lea		(v_pal_water).w,a0
		lea		(v_pal_water_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

	@addcolour2:
		bsr.s	FadeIn_AddColour ; increase colour again
		dbf		d0,@addcolour2 ; repeat

@exit:
		rts	
; End of function FadeIn_FromBlack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeIn_AddColour:
		move.b	(a1),d5				; MJ: load blue
		move.w	(a1)+,d1			; MJ: load green and red
		move.b	d1,d2				; MJ: load red
		lsr.b	#$04,d1				; MJ: get only green
		andi.b	#$0E,d2				; MJ: get only red
		move.w	(a0),d3				; MJ: load current colour in buffer
		cmp.b	d5,d4				; MJ: is it time for blue to fade?
		bhi		@noblue				; MJ: if not, branch
		addi.w	#$0200,d3			; MJ: increase blue

@noblue:
		cmp.b	d1,d4				; MJ: is it time for green to fade?
		bhi		@nogreen			; MJ: if not, branch
		addi.b	#$20,d3				; MJ: increase green

@nogreen:
		cmp.b	d2,d4				; MJ: is it time for red to fade?
		bhi		@nored				; MJ: if not, branch
		addq.b	#$02,d3				; MJ: increase red

@nored:
		move.w	d3,(a0)+			; MJ: save colour
		rts							; MJ: return
; End of function FadeIn_AddColour


; ---------------------------------------------------------------------------
; Subroutine to fade out to black - Proper Fade
; ---------------------------------------------------------------------------


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeOut:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
		moveq	#$07,d4					; MJ: set repeat times
		moveq	#$00,d6					; MJ: clear d6

	@mainloop:
		bsr.w	RunPLC
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bchg	#$00,d6					; MJ: change delay counter
		beq		@mainloop				; MJ: if null, delay a frame
		bsr.s	FadeOut_ToBlack
		dbf		d4,@mainloop
		rts
; End of function PaletteFadeOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeOut_ToBlack:
		moveq	#0,d0
		lea		(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

	@decolour:
		bsr.s	FadeOut_DecColour ; decrease colour
		dbf		d0,@decolour	; repeat for size of palette

		moveq	#0,d0
		lea		(v_pal_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

	@decolour2:
		bsr.s	FadeOut_DecColour
		dbf		d0,@decolour2
		rts	
; End of function FadeOut_ToBlack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeOut_DecColour:
		move.w	(a0),d5			; MJ: load colour
		move.w	d5,d1			; MJ: copy to d1
		move.b	d1,d2			; MJ: load green and red
		move.b	d1,d3			; MJ: load red
		andi.w	#$0E00,d1		; MJ: get only blue
		beq		@noblue			; MJ: if blue is finished, branch
		subi.w	#$0200,d5		; MJ: decrease blue

@noblue:
		andi.w	#$00E0,d2		; MJ: get only green (needs to be word)
		beq		@nogreen		; MJ: if green is finished, branch
		subi.b	#$20,d5			; MJ: decrease green

@nogreen:
		andi.b	#$0E,d3			; MJ: get only red
		beq		@nored			; MJ: if red is finished, branch
		subq.b	#$02,d5			; MJ: decrease red

@nored:
		move.w	d5,(a0)+		; MJ: save new colour
		rts						; MJ: return
; End of function FadeOut_DecColour

; ---------------------------------------------------------------------------
; Subroutine to	fade in from white (Special Stage) - Proper Fade
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteIn:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
		moveq	#0,d0
		lea		(v_pal_dry).w,a0		; load the main palette to a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.w	#cWhite,d1
		move.b	(v_pfade_size).w,d0

	@fill:
		move.w	d1,(a0)+
		dbf		d0,@fill 	; fill palette with white
		moveq	#$0E,d4		; KoH: set maximum color check
		moveq	#$00,d6		; KoH: clear d6

	@mainloop:
		bsr.w	RunPLC
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bchg	#$00,d6					; MJ: change delay counter
		beq		@mainloop				; MJ: if null, delay a frame
		bsr.s	WhiteIn_FromWhite
		subq.b	#$02,d4					; MJ: decrease color check
		bne		@mainloop				; MJ: if it has not reached null, branch
		move.b	#$12,(v_vbla_routine).w	; MJ: wait for V-blank again (so colors transfer)
		bra		WaitForVBla				; MJ: ''
; End of function PaletteWhiteIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteIn_FromWhite:
		moveq	#0,d0
		lea		(v_pal_dry).w,a0
		lea		(v_pal_dry_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

	@decolour:
		bsr.s	WhiteIn_DecColour	; decrease colour
		dbf		d0,@decolour		; repeat for size of palette

		cmpi.b	#id_LZ,(v_zone).w	; is level Labyrinth?
		bne.s	@exit				; if not, branch
		moveq	#0,d0
		lea		(v_pal_water).w,a0
		lea		(v_pal_water_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

	@decolour2:
		bsr.s	WhiteIn_DecColour
		dbf		d0,@decolour2

	@exit:
		rts	
; End of function WhiteIn_FromWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteIn_DecColour:
		move.b	(a1),d5		; MJ: load blue
		move.w	(a1)+,d1	; MJ: load green and red
		move.b	d1,d2		; MJ: load red
		lsr.b	#$04,d1		; MJ: get only green
		andi.b	#$0E,d2		; MJ: get only red
		move.w	(a0),d3		; MJ: load current colour in buffer
		cmp.b	d5,d4		; MJ: is it time for blue to fade?
		ble		@noblue		; MJ: if not, branch
		subi.w	#$0200,d3	; MJ: decrease blue

@noblue:
		cmp.b	d1,d4		; MJ: is it time for green to fade?
		ble		@nogreen	; MJ: if not, branch
		subi.b	#$20,d3		; MJ: decrease green

@nogreen:
		cmp.b	d2,d4		; MJ: is it time for red to fade?
		ble		@nored		; MJ: if not, branch
		subq.b	#$02,d3		; MJ: decrease red

@nored:
		move.w	d3,(a0)+	; MJ: save new colour
		rts					; MJ: return
; End of function WhiteIn_DecColour

; ---------------------------------------------------------------------------
; Subroutine to fade to white (Special Stage) - Proper fade
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteOut:
		move.w	#$003F,(v_pfade_start).w ; start position = 0; size = $40
		moveq	#$07,d4					; MJ: set repeat times
		moveq	#$00,d6					; MJ: clear d6

	@mainloop:
		bsr.w	RunPLC
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bchg	#$00,d6					; MJ: change delay counter
		beq		@mainloop				; MJ: if null, delay a frame
		bsr.s	WhiteOut_ToWhite
		dbf		d4,@mainloop
		rts
; End of function PaletteWhiteOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_ToWhite:
		moveq	#0,d0
		lea	(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

	@addcolour:
		bsr.s	WhiteOut_AddColour
		dbf	d0,@addcolour

		moveq	#0,d0
		lea	(v_pal_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

	@addcolour2:
		bsr.s	WhiteOut_AddColour
		dbf	d0,@addcolour2
		rts	
; End of function WhiteOut_ToWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_AddColour:
		move.w	(a0),d5		; MJ: load colour
		move.w	d5,d1		; MJ: copy to d1
		move.b	d1,d2		; MJ: load green and red
		move.b	d1,d3		; MJ: load red
		andi.w	#$0E00,d1	; MJ: get only blue
		eori.w  #$0E00,d1
		beq		@noblue		; MJ: if blue is finished, branch
		addi.w	#$0200,d5	; MJ: increase blue

@noblue:
		andi.w	#$00E0,d2	; MJ: get only green (needs to be word)
		eori.w  #$00E0,d2
		beq		@nogreen	; MJ: if green is finished, branch
		addi.b	#$20,d5		; MJ: increase green

@nogreen:
		andi.b	#$0E,d3		; MJ: get only red
		eori.b  #$0E,d3
		beq		@nored		; MJ: if red is finished, branch
		addq.b	#$02,d5		; MJ: increase red

@nored:
		move.w	d5,(a0)+	; MJ: save new colour
		rts					; MJ: return
; End of function WhiteOut_AddColour

; ---------------------------------------------------------------------------
; Palette cycling routine - Sega logo
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_Sega:
		tst.b	(v_pcyc_time+1).w
		bne.s	loc_206A
		lea	(v_pal_dry+$20).w,a1
		lea	(Pal_Sega1).l,a0
		moveq	#5,d1
		move.w	(v_pcyc_num).w,d0

loc_2020:
		bpl.s	loc_202A
		addq.w	#2,a0
		subq.w	#1,d1
		addq.w	#2,d0
		bra.s	loc_2020
; ===========================================================================

loc_202A:
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_2034
		addq.w	#2,d0

loc_2034:
		cmpi.w	#$60,d0
		bhs.s	loc_203E
		move.w	(a0)+,(a1,d0.w)

loc_203E:
		addq.w	#2,d0
		dbf	d1,loc_202A

		move.w	(v_pcyc_num).w,d0
		addq.w	#2,d0
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_2054
		addq.w	#2,d0

loc_2054:
		cmpi.w	#$64,d0
		blt.s	loc_2062
		move.w	#$401,(v_pcyc_time).w
		moveq	#-$C,d0

loc_2062:
		move.w	d0,(v_pcyc_num).w
		moveq	#1,d0
		rts	
; ===========================================================================

loc_206A:
		subq.b	#1,(v_pcyc_time).w
		bpl.s	loc_20BC
		move.b	#4,(v_pcyc_time).w
		move.w	(v_pcyc_num).w,d0
		addi.w	#$C,d0
		cmpi.w	#$30,d0
		blo.s	loc_2088
		moveq	#0,d0
		rts	
; ===========================================================================

loc_2088:
		move.w	d0,(v_pcyc_num).w
		lea	(Pal_Sega2).l,a0
		lea	(a0,d0.w),a0
		lea	(v_pal_dry+$04).w,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)
		lea	(v_pal_dry+$20).w,a1
		moveq	#0,d0
		moveq	#$2C,d1

loc_20A8:
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_20B2
		addq.w	#2,d0

loc_20B2:
		move.w	(a0),(a1,d0.w)
		addq.w	#2,d0
		dbf	d1,loc_20A8

loc_20BC:
		moveq	#1,d0
		rts	
; End of function PalCycle_Sega

; ===========================================================================

Pal_Sega1:	incbin	"palette\Sega1.bin"
Pal_Sega2:	incbin	"palette\Sega2.bin"

; ---------------------------------------------------------------------------
; Subroutines to load palettes

; input:
;	d0 = index number for palette
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad1:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2	; get palette data address
		movea.w	(a1)+,a3	; get target RAM address
		adda.w	#v_pal_dry_dup-v_pal_dry,a3		; skip to "main" RAM address
		move.w	(a1)+,d7	; get length of palette data

	@loop:
		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,@loop
		rts	
; End of function PalLoad1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad2:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2	; get palette data address
		movea.w	(a1)+,a3	; get target RAM address
		move.w	(a1)+,d7	; get length of palette

	@loop:
		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,@loop
		rts	
; End of function PalLoad2

; ---------------------------------------------------------------------------
; Underwater palette loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad3_Water:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2	; get palette data address
		movea.w	(a1)+,a3	; get target RAM address
		suba.w	#v_pal_dry-v_pal_water,a3		; skip to "main" RAM address
		move.w	(a1)+,d7	; get length of palette data

	@loop:
		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,@loop
		rts	
; End of function PalLoad3_Water


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad4_Water:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2	; get palette data address
		movea.w	(a1)+,a3	; get target RAM address
		suba.w	#v_pal_dry-v_pal_water_dup,a3
		move.w	(a1)+,d7	; get length of palette data

	@loop:
		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,@loop
		rts	
; End of function PalLoad4_Water
; ===========================================================================


; ---------------------------------------------------------------------------
; Subroutine to	wait for VBlank routines to complete
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WaitForVBla:
		enable_ints

	@wait:
		tst.b	(v_vbla_routine).w ; has VBlank routine finished?
		bne.s	@wait		; if not, branch
		rts	
; End of function WaitForVBla

		include	"_incObj\sub RandomNumber.asm"
		include	"_incObj\sub CalcSine.asm"
		include	"_incObj\sub CalcAngle.asm"

; ---------------------------------------------------------------------------
; Sega screen
; ---------------------------------------------------------------------------

GM_Sega:
		sfx	bgm_Stop,0,1,1 ; stop music
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		lea	(vdp_control_port).l,a6
		move.w	#$8004,(a6)	; use 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$8700,(a6)	; set background colour (palette entry 0)
		move.w	#$8B00,(a6)	; full-screen vertical scrolling
		clr.b	(f_wtr_state).w
		disable_ints
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen
		locVRAM	0
		lea	(Nem_SegaLogo).l,a0 ; load Sega	logo patterns
		bsr.w	NemDec
		lea	($FF0000).l,a1
		lea	(Eni_SegaLogo).l,a0 ; load Sega	logo mappings
		move.w	#0,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,$E510,$17,7
		copyTilemap	$FF0180,$C000,$27,$1B

		tst.b   (v_megadrive).w	; is console Japanese?
		bmi.s   @loadpal
		copyTilemap	$FF0A40,$C53A,2,1 ; hide "TM" with a white rectangle

	@loadpal: ; Fade in the SEGA background
		lea		(v_pal_dry_dup).l,a3
		moveq	#$3F,d7

	@loop:
		move.w	#cWhite,(a3)+	; move data to RAM
		dbf		d7,@loop

		bsr.w	PaletteFadeIn
		move.w	#-$A,(v_pcyc_num).w
		move.w	#0,(v_pcyc_time).w
		move.w	#0,(v_pal_buffer+$12).w
		move.w	#0,(v_pal_buffer+$10).w
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l

Sega_WaitPal:
		move.b	#2,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	PalCycle_Sega
		bne.s	Sega_WaitPal

		sfx	sfx_Sega,0,1,1	; play "SEGA" sound
		move.b	#$14,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move.w	#$1E,(v_demolength).w

Sega_WaitEnd:
		move.b	#2,(v_vbla_routine).w
		bsr.w	WaitForVBla
		tst.w	(v_demolength).w
		beq.s	Sega_GotoTitle
		andi.b	#btnStart,(v_jpadpress1).w ; is Start button pressed?
		beq.s	Sega_WaitEnd	; if not, branch

Sega_GotoTitle:
		move.b	#id_Title,(v_gamemode).w ; go to title screen
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Title	screen
; ---------------------------------------------------------------------------

GM_Title:
		sfx	bgm_Stop,0,1,1 ; stop music
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		disable_ints
		bsr.w	SoundDriverLoad
		lea		(vdp_control_port).l,a6
		move.w	#$8004,(a6)	; 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6)	; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)	; set background nametable address
		move.w	#$9001,(a6)					; 64-cell hscroll size
		move.w	#$9200,(a6)					; window vertical position
		move.w	#$8B03,(a6)
		move.w	#$8720,(a6)					; set background colour (palette line 2, entry 0)
		clr.b	(f_wtr_state).w
		bsr.w	ClearScreen

		lea		(v_ringpos).w,a1
		moveq	#0,d0
		move.w	#$1A1,d1

	Tit_ClrRing:
		move.l	d0,(a1)+
		dbf		d1,Tit_ClrRing		; clear ring RAM
		clr.w	(f_level_started).w	; Clear Level Start Flag, and HUD Scroll

		lea		(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

	Tit_ClrObj1:
		move.l	d0,(a1)+
		dbf		d1,Tit_ClrObj1	; fill object space ($D000-$EFFF) with 0

		locVRAM	0
		lea		(Nem_JapNames).l,a0 ; load Japanese credits
		bsr.w	NemDec
		locVRAM	$14C0
		lea		(Nem_CreditText).l,a0 ;	load alphabet
		bsr.w	NemDec
		lea		($FF0000).l,a1
		lea		(Eni_JapNames).l,a0 ; load mappings for	Japanese credits
		move.w	#0,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,$C000,$27,$1B

		lea		(v_pal_dry_dup).w,a1
		moveq	#cBlack,d0
		move.w	#$1F,d1

	Tit_ClrPal:
		move.l	d0,(a1)+
		dbf	d1,Tit_ClrPal	; fill palette with 0 (black)

		moveq	#palid_Sonic,d0	; load Sonic's palette
		bsr.w	PalLoad1
		move.b	#id_CreditsText,(v_objspace+$80).w ; load "SONIC TEAM PRESENTS" object
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		bsr.w	PaletteFadeIn
		disable_ints
		locVRAM	$4000
		lea	(Nem_TitleFg).l,a0 ; load title	screen patterns
		bsr.w	NemDec
		locVRAM	$6000
		lea	(Nem_TitleSonic).l,a0 ;	load Sonic title screen	patterns
		bsr.w	NemDec
		locVRAM	$A200
		lea	(Nem_TitleTM).l,a0 ; load "TM" patterns
		bsr.w	NemDec
		locVRAM	$A660
		lea	(Nem_TitleMenu).l,a0 ; load Title Menu patterns
		bsr.w	NemDec
		lea	(vdp_data_port).l,a6
		locVRAM	$D000,4(a6)
		lea	(Art_Text).l,a5	; load level select font
		move.w	#$28F,d1

	Tit_LoadText:
		move.w	(a5)+,(a6)
		dbf		d1,Tit_LoadText		; load level select font
		move.b	#0,(f_nobgscroll).w ; Fixes bug w/ Game OVer while drowning

		clr.b	(v_lastlamp).w		; clear lamppost counter
		clr.w	(v_debuguse).w		; disable debug item placement mode
		clr.w	(f_demo).w			; disable debug mode
		clr.w	(v_zone).w			; set level to GHZ (00)
		clr.w	(v_pcyc_time).w 	; disable palette cycling
		bsr.w	LevelSizeLoad
		bsr.w	DeformLayers

		move.l	#Blk16_GHZ,(v_16x16).l	; store the ROM address for the block mappings
		move.l	#Blk128_GHZ,(v_128x128).l	; store the ROM address for the chunk mappings

		bsr.w	LevelLayoutLoad
		bsr.w	PaletteFadeOut
		disable_ints
		bsr.w	ClearScreen
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(v_bgscreenposx).w,a3
		movea.l	(v_lvllayoutbg).w,a4	; MJ: Load address of layout BG
		move.w	#$6000,d2
		bsr.w	DrawChunks

		copyTilemap	Eni_Title,$C208,$21,$15 ; Load Title Chunks from ROM

		locVRAM	0
		lea		(Nem_Title).l,a0 ; load GHZ patterns
		bsr.w	NemDec
		moveq	#palid_GHZ,d0	; load GHZ palette
		bsr.w	PalLoad1
		moveq	#palid_Title,d0	; load title screen palette
		bsr.w	PalLoad1
		sfx		bgm_Title,0,1,1	; play title screen music
		clr.b	(f_debugmode).w ; disable debug mode
		move.w	#$178,(v_demolength).w ; run title screen for $178 frames

		lea		(v_objspace+$80).w,a0
		jsr		DeleteObject						; clear object RAM to make room for the "Press Start Button" object
		move.b	#id_TitleSonic,(v_objspace+$40).w	; load big Sonic object
		move.b	#id_PSBTM,(v_objspace+$80).w		; load "PRESS START BUTTON" object

		tst.b   (v_megadrive).w	; is console Japanese?
		bpl.s   @isjap		; if yes, branch

		move.b	#id_PSBTM,(v_objspace+$C0).w ; load "TM" object
		move.b	#3,(v_objspace+$C0+obFrame).w
	@isjap:
		move.b	#id_PSBTM,(v_objspace+$100).w ; load object which hides part of Sonic
		move.b	#2,(v_objspace+$100+obFrame).w
		jsr		(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr		(BuildSprites).l
		moveq	#plcid_Main,d0
		bsr.w	NewPLC
		clr.w	(v_title_dcount).w
		clr.w	(v_title_ccount).w
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	PaletteFadeIn

Tit_MainLoop:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr		(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr		(BuildSprites).l
		bsr.w	PCycle_Title
		bsr.w	RunPLC
		move.w	(v_objspace+obX).w,d0
		addq.w	#2,d0
		move.w	d0,(v_objspace+obX).w ; move Sonic to the right

		cmpi.b	#4,(v_objspace+$80+obRoutine).w
		beq.s	@nodemo

		tst.w	(v_demolength).w	; has the timer counted down to 0?
		beq.w	GotoDemo		; if yes, go to the demo

	@nodemo:
		andi.b	#btnStart,(v_jpadpress1).w ; check if Start is pressed
		beq.w	Tit_MainLoop	; if not, branch

Tit_ChkMenu:
		cmpi.b	#1,(v_objspace+$80+obFrame).w
		bgt.w	Tit_MenuChoice
		move.b	#4,(v_objspace+$80+obRoutine).w
		moveq	#sfx_Lamppost,d0
		jsr		PlaySound
		bra.s	Tit_MainLoop

Tit_MenuChoice:
		moveq	#0,d0
		move.b	(v_objspace+$80+obTitleOption).w,d0
		bne.s	Tit_ChkOptions
		bra.w	PlayLevel_Load	; if not, play level

Tit_ChkOptions:
		subq	#1,d0
		beq.s	Tit_GoToOptions
		move.b	#id_MenuScreen,(v_gamemode).w
		jmp		MainGameLoop

Tit_GoToOptions:
		moveq	#palid_Options,d0
		bsr.w	PalLoad2	; load options screen palette
		lea	(v_hscrolltablebuffer).w,a1
		moveq	#0,d0
		move.w	#$DF,d1

Tit_ClrScroll1:
		move.l	d0,(a1)+
		dbf	d1,Tit_ClrScroll1 ; clear scroll data (in RAM)

		move.l	d0,(v_scrposy_dup).w
		disable_ints
		lea	(vdp_data_port).l,a6
		locVRAM	$E000
		move.w	#$3FF,d1

Tit_ClrScroll2:
		move.l	d0,(a6)
		dbf	d1,Tit_ClrScroll2	; clear scroll data (in VRAM)
		move.b  #$81,d0			; Play music during the Level Select Screen
		jsr 	PlaySound
		bsr.w	OptionsTextLoad

; ---------------------------------------------------------------------------
; Options Menu - Replacing the previous Level Select Menu
; ---------------------------------------------------------------------------

OptionMenu:
		move.b	#2,(v_vbla_routine).w	; Fix Level Select/Option Screen
		bsr.w	WaitForVBla
		bsr.w	OptionControls
		bsr.w	RunPLC
		tst.l	(v_plc_buffer).w
		bne.s	OptionMenu
; New code starts
		move.w	(v_levselitem).w,d0
		cmpi.b	#$12,d0					; have you selected either item $12 or $14 (START or RESET)?
		bge.s	Option_CheckBack		; if yes, go to	check start button subroutine
		cmpi.b	#$10,d0					; Are you on the sound test menu?
		bne.s	OptionMenu				; if not, do nothing.
		cmpi.b	#btnB,(v_jpadpress1).w 	; is B pressed?
		beq.s	Option_BCPress			; if not, branch
		cmpi.b	#btnC,(v_jpadpress1).w	; is C pressed?
		beq.s	Option_BCPress			; if not, branch
		bra.s	OptionMenu
; ===========================================================================

Option_CheckBack:			; XREF: OptionMenu
		andi.b	#btnStart,(v_jpadpress1).w	; is Start pressed?
		beq.s	OptionMenu			; if not, branch and go back
		cmpi.b	#$12,d0
		bne.s	@reset
		bra.w	PlayLevel_New

	@reset:
		clr.b	(v_gamemode).w
		jmp		MainGameLoop			; go to sega screen

Option_BCPress:				; XREF: OptionMenu
		move.w	(v_levselsound).w,d0
		addi.w	#$80,d0
		; This is a workaround for a bug, see Sound_ChkValue for more.
		; Once you've fixed the bugs there, comment these four instructions out
		cmpi.w	#bgm__Last+1,d0	; is sound $80-$93 being played?
		blo.s	Option_PlaySnd	; if yes, branch
		cmpi.w	#sfx__First,d0	; is sound $94-$9F being played?
		blo.s	OptionMenu	; if yes, branch

Option_PlaySnd:
		bsr.w	PlaySound_Special
		bra.s	OptionMenu
; ===========================================================================

PlayLevel_Load:
		move.b	#1,(SRAM_access_flag).l			; enable SRAM (required)
		lea		($200009).l,a1			; base of SRAM + 9 (01-07 for init SRAM)
		move.b	0(a1),d0	
		clr.b	(SRAM_access_flag).l				; disable SRAM (required)

		cmpi.b	#$FF,d0
		beq.s	PlayLevel_New			; if no save game exists, make a new one

		move.b	#1,(SRAM_access_flag).l			; enable SRAM (required)
		lea		($200009).l,a1			; base of SRAM + 9 (01-07 for init SRAM)
		movep.l	2(a1),d0				; load to d0 (cannot do directly)
		move.l	d0,(v_optgamemode).w	; load correct game mode
										; load correct player mode
										; load correct difficulty
										; load correct monitor setting
		movep.w	$A(a1),d0
		move.w	d0,(v_zone).w			; load correct zone and act
		movep.l	$E(a1),d0
		move.l	d0,(v_startscore).w		; load last saved score
		movep.l	$16(a1),d0
		move.l	d0,(v_scorelife).w		; extra life is awarded at _____ points 
		move.b	$1E(a1),d0
		move.b	d0,(v_lives).w			; lives
		move.b	$20(a1),d0
		move.b	d0,(v_lastspecial).w
		movep.w	$22(a1),d0
		move.w	d0,(v_emeralds).w
		movep.w	$26(a1),d0
		move.w	d0,(v_redrings).w
		clr.b	(SRAM_access_flag).l		; disable SRAM (required)

		move.b	#id_Level,(v_gamemode).w ; set screen mode to $0C (level)
		clr.w	(v_rings).w	; clear rings
		clr.l	(v_time).w	; clear time
		clr.b	(v_centstep).w
		clr.b	(v_continues).w ; clear continues

		sfx		bgm_Fade,0,1,1 ; fade out music
		rts	
; ===========================================================================


PlayLevel_New:
		move.b	#id_Level,(v_gamemode).w ; set screen mode to $0C (level)
		move.b	#3,(v_lives).w	; set lives to 3
		cmpi.b	#difEasy,(v_difficulty).w
		bne.s	@notEasy
		move.b	#5,(v_lives).w	; set lives to 5

	@notEasy:
		move.b	#1,(SRAM_access_flag).l			; enable SRAM (required)
		lea		($200009).l,a1			; base of SRAM + 9 (01-07 for init SRAM)
		moveq	#0,d0
		move.b	d0,0(a1) 				; init new game
		move.l	(v_optgamemode).w,d0	; load correct game mode
										; load correct player mode
										; load correct difficulty
										; load correct monitor setting
		movep.l	d0,2(a1)				; load to d0 (cannot do directly)
		clr.b	(SRAM_access_flag).l				; disable SRAM (required)

		clr.w	(v_rings).w	; clear rings
		clr.l	(v_time).w	; clear time
		clr.b	(v_centstep).w
		clr.l	(v_score).w	; clear score
		clr.l	(v_startscore).w	; clear start score
		clr.b	(v_lastspecial).w ; clear special stage number
		clr.w	(v_emeralds).w ; clear emerald count and list
		clr.w	(v_redrings).w ; clear red rings count and list
		clr.b	(v_continues).w ; clear continues
		move.l	#5000,(v_scorelife).w ; extra life is awarded at 50000 points
		sfx		bgm_Fade,0,1,1 ; fade out music
		rts	
; ===========================================================================


; ---------------------------------------------------------------------------
; NEW Menu Screen for S2 Level Select
; ---------------------------------------------------------------------------
GM_MenuScreen:
		bsr.w	PaletteFadeOut
		move	#$2700,sr
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen
		lea		(vdp_control_port).l,a6
		move.w	#$8004,(a6)		; H-INT disabled
		move.w	#$8230,(a6)		; PNT A base: $C000
		move.w	#$8407,(a6)		; PNT B base: $E000
		move.w	#$8230,(a6)		; PNT A base: $C000
		move.w	#$8700,(a6)		; Background palette/color: 0/0
		move.w	#$8C81,(a6)		; H res 40 cells, no interlace, S/H disabled
		move.w	#$9001,(a6)		; Scroll table size: 64x32

; RAM CLEARING
		clr.w	(VDP_Command_Buffer).w
		move.w	#VDP_Command_Buffer,(VDP_Command_Buffer_Slot).w

		; Level Select Menu Font and other related art
		locVRAM	$200
		lea	(Nem_MenuStuff).l,a0
		bsr.w	NemDec

		; Sonic 2 Menu Boxes (MAYBE USE THIS FOR TIME ATTACK???
		;locVRAM	$E00
		;lea	(Nem_MenuBox).l,a0
		;bsr.w	NemDec

        ; Level Select Icons - Custom for Sonic 1 and SMS Levels
		locVRAM	$1200
		lea	(Nem_LevSelIcons).l,a0
		bsr.w	NemDec

		; Background - Load mappings first, tiles will be dynamically loaded
		lea	($FF0000).l,a1
		lea	(Eni_MenuBack).l,a0 ; load SONIC/MILES mappings
		move.w	#$6000,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,$E000,$27,$1B

		;cmpi.b	#id_TimeAttackMenu,(v_gamemode).w	; time attack menu?
		;beq.w	MenuScreen_TimeAttack	; if yes, branch

		lea	($FF0000).l,a1
		lea	(Eni_LevSel).l,a0	; Level Select mappings, 2 bytes per tile
		moveq	#0,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,$C000,$27,$1B

		moveq	#0,d3
		bsr.w	LevelSelect_DrawSoundNumber
		lea		($FF08C0).l,a1
		lea		(Eni_LevSelIcons).l,a0	; Level Select Icon Mappings
		move.w	#$90,d0			; Art Location of Level Select Icons
		bsr.w	EniDec
		bsr.w	LevelSelect_DrawIcon
		clr.b	(v_playermode).w
		clr.w	(v_menuanimtimer).w
		lea		(Anim_SonicMilesBG).l,a2
		jsr		Dynamic_Menu	; background
		moveq	#palid_Menu,d0
		bsr.w	PalLoad1
		lea		(v_pal_dry+$40).w,a1
		lea		(v_pal_dry_dup+$40).w,a2

		moveq	#7,d1
	@loop:
		move.l	(a1),(a2)+
		clr.l	(a1)+
		dbf		d1,@loop

		move.b	#bgm_MZ,d0
		bsr.w	PlaySound				; play Level Select Menu sound

		move.b	#$16,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	PaletteFadeIn

LevelSelect_MainLoop:
		move.b	#$16,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move	#$2700,sr
		moveq	#0,d3			; palette line << 13
		bsr.w	LevelSelect_MarkFields	; unmark fields
		bsr.w	LevSelControls		; Check to change between items
		move.w	#$6000,d3		; palette line << 13
		bsr.w	LevelSelect_MarkFields	; mark fields
		bsr.w	LevelSelect_DrawIcon
		move	#$2300,sr
		lea		(Anim_SonicMilesBG).l,a2
		jsr		Dynamic_Menu	; background
		move.b	(v_jpadpress1).w,d0
;		or.b	(Ctrl_2_Press).w,d0
		andi.b	#btnStart,d0	; start pressed?
		bne.s	LevelSelect_PressStart	; yes
		bra.w	LevelSelect_MainLoop	; no

LevelSelect_PressStart:
		move.w	(v_levselzone).w,d0
		add.w	d0,d0
		move.w	LevelSelect_Order(pc,d0.w),d0
		bmi.w	LevelSelect_Return	; sound test
		cmpi.w	#$4000,d0
		bne.w	LevelSelect_StartZone

		move.b	#id_Special,(v_gamemode).w ; => SpecialStage
		bset	#0,(f_timeattack).w
		clr.w	(v_zone).w
		move.b	#3,(v_lives).w	; set lives to 3
		cmpi.b	#difEasy,(v_difficulty).w
		bne.s	@clear
		move.b	#5,(v_lives).w	; set lives to 5

	@clear:
		clr.w	(v_rings).w	; clear rings
		clr.l	(v_time).w	; clear time
		clr.b	(v_centstep).w
		clr.l	(v_score).w	; clear score
		clr.l	(v_startscore).w ; clear starting score
		clr.b	(v_lastspecial).w ; clear special stage number
		clr.b	(v_emeralds).w ; clear emerald count
		clr.b	(v_emeraldlist).w ; clear emeralds
		clr.b	(v_continues).w ; clear continues
		move.l	#5000,(v_scorelife).w ; extra life is awarded at 50000 points
		;move.w	(Player_option).w,(Player_mode).w
		rts
; ===========================================================================

LevelSelect_Return:
		move.b	#id_Sega,(v_gamemode).w ; => SegaScreen
		clr.b	(f_timeattack).w
		rts
; ===========================================================================

; -----------------------------------------------------------------------------
; Level Select Level Order
; -----------------------------------------------------------------------------
;Misc_9454:
LevelSelect_Order:
		dc.w	$0000	; GHZ 1
		dc.w	$0001	; GHZ 2
		dc.w	$0002	; GHZ 3
		dc.w	$0700	; BZ 1
		dc.w	$0701	; BZ 2
		dc.w	$0702	; BZ 3
		dc.w	$0200	; MZ 1
		dc.w	$0201	; MZ 2
		dc.w	$0202	; MZ 3
		dc.w	$0800	; JZ 1
		dc.w	$0801	; JZ 2
		dc.w	$0802	; JZ 3
		dc.w	$0400	; SYZ 1
		dc.w	$0401	; SYZ 2
		dc.w	$0402	; SYZ 3
		dc.w	$0100	; LZ 1
		dc.w	$0101	; LZ 2
		dc.w	$0102	; LZ 3
		dc.w	$0300	; SLZ 1
		dc.w	$0301	; SLZ 2
		dc.w	$0302	; SLZ 3
		dc.w	$0500	; SBZ 1
		dc.w	$0501	; SBZ 2
		dc.w	$0103	; SBZ 3
		dc.w	$0502	; Final Zone
		dc.w	$0900	; SKBZ 1
		dc.w	$0901	; SKBZ 2
		dc.w	$0902	; SKBZ 3
		dc.w	$0000	; GHZ 1 (WILL BE River Cavern Zone)
		dc.w	$4000	; 20 - special stage - WILL BE BONUS STAGE
		dc.w	$4000	; 20 - special stage
		dc.w	$FFFF	; CHAR SELECT
		dc.w	$FFFF	; 21 - sound test
; ===========================================================================

LevelSelect_StartZone:
		andi.w	#$3FFF,d0
		move.w	d0,(v_zone).w
		move.b	#id_Level,(v_gamemode).w ; set screen mode to $0C (level)
		bset	#0,(f_timeattack).w
		move.b	#3,(v_lives).w	; set lives to 3
		cmpi.b	#difEasy,(v_difficulty).w
		bne.s	@clear
		move.b	#5,(v_lives).w	; set lives to 5

	@clear:
		clr.w	(v_rings).w		; clear rings
		clr.l	(v_time).w		; clear time
		clr.b	(v_centstep).w
		clr.l	(v_score).w		; clear score
		clr.l	(v_startscore).w	; clear start score <- KingofHarts Level Select Mod (REV C EDIT)
		clr.b	(v_lastspecial).w	; clear special stage number
		clr.b	(v_emeralds).w		; clear emerald count
		clr.b	(v_emeraldlist).w	; clear emeralds list
		clr.b	(v_continues).w		; clear continues
		move.l	#5000,(v_scorelife).w	; extra life is awarded at 50000 points
		move.b	#$E0,d0
		bsr.w	PlaySound_Special	; fade out music
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Change what you're selecting in the level select
; ---------------------------------------------------------------------------
; loc_94DC:
LevSelControls:
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnUp|btnDn,d1
		bne.s	@ChkUpDown	; up/down pressed
		subq.w	#1,(v_levseldelay).w
		bpl.s	LevSelControls_CheckLR
	@ChkUpDown:
		move.w	#$B,(v_levseldelay).w
		move.b	(v_jpadhold1).w,d1
		andi.b	#btnUp|btnDn,d1
		beq.s	LevSelControls_CheckLR	; up/down not pressed, check for left & right
		move.w	(v_levselzone).w,d0
		btst	#bitUp,d1
		beq.s	@ChkDown
		subq.w	#1,d0	; decrease by 1
		bcc.s	@ChkDown; >= 0?
		moveq	#$20,d0 ; set to sound test
	@ChkDown:
		btst	#bitDn,d1
		beq.s	@ChkUp
		addq.w	#1,d0	; yes, add 1
		cmpi.w	#$21,d0
		blo.s	@ChkUp	; smaller than $20?
		moveq	#0,d0	; if not, set to 0

	@ChkUp:
		move.w	d0,(v_levselzone).w
		rts
; ===========================================================================

LevSelControls_CheckLR:
		cmpi.w	#$20,(v_levselzone).w	; are we in the sound test?
		bne.s	LevSelControls_SwitchSide	; no
		move.w	(v_levselsound).w,d0
		move.b	(v_jpadpress1).w,d1
		btst	#bitL,d1
		beq.s	@chkright
		subq.b	#1,d0
		bcc.s	@chkright
		moveq	#$7F,d0

	@chkright:
		btst	#bitR,d1
		beq.s	@chkA
		addq.b	#1,d0
		cmpi.w	#$80,d0
		blo.s	@chkA
		moveq	#0,d0

	@chkA:
		btst	#bitA,d1
		beq.s	@changesound
		addi.b	#$10,d0
		andi.b	#$7F,d0

	@changesound:
		move.w	d0,(v_levselsound).w
		andi.w	#btnBC,d1
		beq.s	@rts	; rts
		move.w	(v_levselsound).w,d0
		addi.w	#$80,d0
		bra.w	PlaySound
		;lea	(debug_cheat).l,a0
		;lea	(super_sonic_cheat).l,a2
		;lea	(Night_mode_flag).w,a1
		;moveq	#1,d2	; flag to tell the routine to enable the Super Sonic cheat
		;bsr.w	CheckCheats
	@rts:
		rts
; ===========================================================================

LevSelControls_SwitchSide:	; not in soundtest, not up/down pressed
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnL|btnR,d1
		beq.s	@rts				; no direction key pressed
		move.w	(v_levselzone).w,d0	; left or right pressed
		move.b	LevelSelect_SwitchTable(pc,d0.w),d0 ; set selected zone according to table
		move.w	d0,(v_levselzone).w
	@rts:
		rts
; ===========================================================================

LevelSelect_SwitchTable:
	dc.b $15	; 0
	dc.b $16	; 1
	dc.b $17	; 2
	dc.b $18	; 3
	dc.b $19	; 4
	dc.b $1A	; 5
	dc.b $1B	; 6
	dc.b $1C	; 7
	dc.b $1C	; 8
	dc.b $1D	; 9
	dc.b $1D	; $A
	dc.b $1E	; $B
	dc.b $1E	; $C
	dc.b $1F	; $D
	dc.b $1F	; $E
	dc.b $20	; $F
	dc.b $20	; $10
	dc.b $20	; $11
	dc.b $20	; $12
	dc.b $20	; $13
	dc.b $20	; $14
	dc.b 0		; $15
	dc.b 1		; $16
	dc.b 2		; $17
	dc.b 3		; $18
	dc.b 4		; $19
	dc.b 5		; $1A
	dc.b 6		; $1B
	dc.b 7		; $1C
	dc.b 9		; $1D
	dc.b $B		; $1E - SPECIAL STAGE
	dc.b $D		; $1F - Character
	dc.b $D		; $20 - CURRENT END (SOUND TEST)
	even
; ===========================================================================

;loc_95B8:
LevelSelect_MarkFields:
		lea	($FF0000).l,a4
		lea	(LevSel_MarkTable).l,a5
		lea	($C00000).l,a6		; VDP_data_port
		moveq	#0,d0
		move.w	(v_levselzone).w,d0
		lsl.w	#2,d0
		lea	(a5,d0.w),a3
		moveq	#0,d0
		move.b	(a3),d0
		mulu.w	#$50,d0
		moveq	#0,d1
		move.b	1(a3),d1
		add.w	d1,d0
		lea	(a4,d0.w),a1
		moveq	#0,d1
		move.b	(a3),d1
		lsl.w	#7,d1
		add.b	1(a3),d1
		addi.w	#-$4000,d1
		lsl.l	#2,d1
		lsr.w	#2,d1
		ori.w	#$4000,d1
		swap	d1
		move.l	d1,4(a6)

		moveq	#$D,d2
	@loop:
		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,(a6)
		dbf	d2,@loop

		addq.w	#2,a3
		moveq	#0,d0
		move.b	(a3),d0
		beq.s	@chkitem
		mulu.w	#$50,d0
		moveq	#0,d1
		move.b	1(a3),d1
		add.w	d1,d0
		lea	(a4,d0.w),a1
		moveq	#0,d1
		move.b	(a3),d1
		lsl.w	#7,d1
		add.b	1(a3),d1
		addi.w	#-$4000,d1
		lsl.l	#2,d1
		lsr.w	#2,d1
		ori.w	#$4000,d1
		swap	d1
		move.l	d1,4(a6)
		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,(a6)

	@chkitem:
		cmpi.w	#$20,(v_levselzone).w
		bne.s	@rts	; rts
		bsr.w	LevelSelect_DrawSoundNumber
	@rts:
		rts
; ===========================================================================

LevelSelect_DrawSoundNumber:
	move.l	#$49440003,(vdp_control_port).l
	move.w	(v_levselsound).w,d0
	move.b	d0,d2
	lsr.b	#4,d0
	bsr.s	@bra1
	move.b	d2,d0

@bra1:
	andi.w	#$F,d0
	cmpi.b	#$A,d0
	blo.s	@bra2
	addi.b	#4,d0

@bra2:
	addi.b	#$10,d0
	add.w	d3,d0
	move.w	d0,(a6)
	rts
; ===========================================================================

LevelSelect_DrawIcon:
		move.w	(v_levselzone).w,d0		; Get selected zone/menu option
		lea	(LevSel_IconTable).l,a3
		lea	(a3,d0.w),a3			; Get respective icon frame
		lea	($FF08C0).l,a1			; Chunk_Table + $C80
		moveq	#0,d0
		move.b	(a3),d0				; load icon frame # to d0
		lsl.w	#3,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0				; d0=(d0<<3)*3;

;		copyTilemap (a1,d0.w), $4B360003, 3, 2

		lea	(a1,d0.w),a1			; Go to respective area in Chunk table
		move.l	#$4B360003,d0
		moveq	#3,d1
		moveq	#2,d2
		bsr.w	TilemapToVRAM			; Apply tilemap to VRAM

		lea	(Pal_LevSelIcons).l,a1
		moveq	#0,d0
		move.b	(a3),d0				; Get respective icon frame
		lsl.w	#5,d0
		lea	(a1,d0.w),a1
		lea	(v_pal_dry+$40).w,a2

		moveq	#7,d1
	@loop:
		move.l	(a1)+,(a2)+
		dbf	d1,@loop

		rts
; ===========================================================================

LevSel_IconTable:
	dc.b   0,0,0	;0	GHZ
	dc.b   0,0,0	;3	BZ
	dc.b   1,1,1	;6	MZ
	dc.b   1,1,1	;9	JZ
	dc.b   2,2,2	;$C	SYZ
	dc.b   3,3,3	;$F	LZ
	dc.b   4,4,4	;$12	SLZ
	dc.b   5,5,5	;$15	SBZ
	dc.b   5	;$18	FZ
	dc.b  6,6,6	;$19	SKBZ
	dc.b  7		;$1C	CCZ (HIDDEN LEVEL)
	dc.b  8		;$1D	Bonus Stage
	dc.b  8		;$1E	Special Stage
; ADD OPTIONS ICONS
;	dc.b  $E	;$16	BLUE SHIELD
;	dc.b  $E	;$16	ELEMENTAL SHIELD
;	dc.b  $E	;$16	6 EMERALDS
;	dc.b  $E	;$16	7 EMERALDS
	dc.b  $E	;$1F	Sound Test (SONIC)
	dc.b  $E	;$20	Sound Test (TAILS)
	dc.b  $E	;$21	Sound Test (KNUCKLES)
;	dc.b  $E	;$16	Sound Test (MIGHTY)
;	dc.b  $E	;$16	Sound Test (AMY)
;	dc.b  $E	;$16	Sound Test (RAY)
;	dc.b  $E	;$16	Sound Test (METAL)
; ===========================================================================

; DATA STRUCTURE NOTING WHICH LINES TO HIGHLIGHT FOR EACH SELECTION

LevSel_MarkTable:	; 4 bytes per level select entry
; COMPLETE - NORMAL/HARD
; line primary, 2*column ($E fields), line secondary, 2*column secondary (1 field)
	dc.b   3,  6,  3,$24	; 0 GHZ1
	dc.b   3,  6,  4,$24	; 1 GHZ2
	dc.b   3,  6,  5,$24	; 2 GHZ3
	dc.b   6,  6,  6,$24	; 3 BZ1
	dc.b   6,  6,  7,$24	; 4 BZ2
	dc.b   6,  6,  8,$24	; 5 BZ3
	dc.b   9,  6,  9,$24	; 6 MZ1
	dc.b   9,  6, $A,$24	; 7 MZ2
	dc.b   9,  6, $B,$24	; 8 MZ3
	dc.b  $C,  6, $C,$24	; 9 JZ1
	dc.b  $C,  6, $D,$24	; $A JZ2
	dc.b  $C,  6, $E,$24	; $B JZ3
	dc.b  $F,  6, $F,$24	; $C SYZ1
	dc.b  $F,  6,$10,$24	; $D SYZ2
	dc.b  $F,  6,$11,$24	; $E SYZ3
	dc.b $12,  6,$12,$24	; $F LZ1
	dc.b $12,  6,$13,$24	; $10 LZ2
	dc.b $12,  6,$14,$24	; $11 LZ3
	dc.b $15,  6,$15,$24	; $12 SLZ1
	dc.b $15,  6,$16,$24	; $13 SLZ2
	dc.b $15,  6,$17,$24	; $14 SLZ3
; --- second column ---
	dc.b   3,$2C,  3,$48	; $15 SBZ1
	dc.b   3,$2C,  4,$48	; $16 SBZ2
	dc.b   3,$2C,  5,$48	; $17 SBZ3
	dc.b   3,$2C,  6,$48	; $18 SBZ4/FINAL
	dc.b   7,$2C,  7,$48	; $19 SKBZ1
	dc.b   7,$2C,  8,$48	; $1A SKBZ2
	dc.b   7,$2C,  9,$48	; $1B SKBZ3
	dc.b  $A,$2C,  $A, $48	; $1C CCZ
	dc.b  $C,$2C,  $C, $48	; $1D BONUS
	dc.b  $E,$2C,  $E, $48	; $1E SPECIAL
	dc.b $10,$2C,  $10,$48	; $1F CHARACTER
	dc.b $12,$2C,$12,$48	; $20 SOUND TEST
; ===========================================================================

Dynamic_Menu:
	lea	(v_menuanimtimer).w,a3

loc_3FF30:
	move.w	(a2)+,d6	; loop counter. We start off with 00 the first time.

loc_3FF32:
	subq.b	#1,(a3)		; decrement timer
	bcc.s	loc_3FF78	; if time remains, branch ahead
	moveq	#0,d0
	move.b	1(a3),d0	; load animation counter from animation data table
	cmp.b	6(a2),d0
	blo.s	loc_3FF48
	moveq	#0,d0
	move.b	d0,1(a3)	; set animation counter

loc_3FF48:
	addq.b	#1,1(a3)	; increment animation counter
	move.b	(a2),(a3)	; set timer
	bpl.s	loc_3FF56
	add.w	d0,d0
	move.b	9(a2,d0.w),(a3)

loc_3FF56:
	move.b	8(a2,d0.w),d0
	lsl.w	#5,d0
	move.w	4(a2),d2
	move.l	(a2),d1
	andi.l	#$FFFFFF,d1		; Filter out the first byte, which contains the first PLC ID, leaving the address of the zone's art in d0
	add.l	d0,d1
	moveq	#0,d3
	move.b	7(a2),d3
	lsl.w	#4,d3
	jsr	(QueueDMATransfer).l	; Use d1, d2, and d3 to locate the decompressed art and ready for transfer to VRAM

loc_3FF78:
	move.b	6(a2),d0
	tst.b	(a2)
	bpl.s	loc_3FF82
	add.b	d0,d0

loc_3FF82:
	addq.b	#1,d0
	andi.w	#$FE,d0
	lea	8(a2,d0.w),a2
	addq.w	#2,a3
	dbf	d6,loc_3FF32
	rts
; ===========================================================================

; ------------------------------------------------------------------------
; MENU ANIMATION SCRIPT
; ------------------------------------------------------------------------
;word_87C6:
Anim_SonicMilesBG:
	dc.w   0
; Sonic/Miles animated background
	dc.l $FF<<24|Art_MenuBack
	dc.w $20
	dc.b 6
	dc.b $A
	dc.b   0,$C7    ; "SONIC"
	dc.b  $A,  5	; 2
	dc.b $14,  5	; 4
	dc.b $1E,$C7	; "TAILS"
	dc.b $14,  5	; 8
	dc.b  $A,  5	; 10
; ===========================================================================

; ---------------------------------------------------------------------------
; Demo mode
; ---------------------------------------------------------------------------

GotoDemo:
		move.w	#$1E,(v_demolength).w

loc_33B6:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	DeformLayers
		bsr.w	PaletteCycle
		bsr.w	RunPLC
		move.w	(v_objspace+obX).w,d0
		addq.w	#2,d0
		move.w	d0,(v_objspace+obX).w
		cmpi.w	#$1C00,d0
		blo.s	loc_33E4
		move.b	#id_Sega,(v_gamemode).w
		rts	
; ===========================================================================

loc_33E4:
		andi.b	#btnStart,(v_jpadpress1).w ; is Start button pressed?
		bne.w	Tit_ChkMenu	; if yes, branch
		tst.w	(v_demolength).w
		bne.w	loc_33B6
		sfx		bgm_Fade,0,1,1 ; fade out music
		move.w	(v_demonum).w,d0 ; load	demo number
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Demo_Levels(pc,d0.w),d0	; load level number for	demo
		move.w	d0,(v_zone).w
		addq.w	#1,(v_demonum).w ; add 1 to demo number
		cmpi.w	#4,(v_demonum).w ; is demo number less than 4?
		blo.s	loc_3422	; if yes, branch
		clr.w	(v_demonum).w ; reset demo number to	0

loc_3422:
		move.w	#1,(f_demo).w	; turn demo mode on
		move.b	#id_Demo,(v_gamemode).w ; set screen mode to 08 (demo)
		cmpi.w	#$600,d0	; is level number 0600 (special	stage)?
		bne.s	Demo_Level	; if not, branch
		move.b	#id_Special,(v_gamemode).w ; set screen mode to $10 (Special Stage)
		clr.w	(v_zone).w	; clear	level number
		clr.b	(v_lastspecial).w ; clear special stage number

Demo_Level:
		move.b	#3,(v_lives).w	; set lives to 3
		cmpi.b	#difEasy,(v_difficulty).w
		bne.s	@clear
		move.b	#5,(v_lives).w	; set lives to 5

	@clear:
		moveq	#0,d0
		move.w	d0,(v_rings).w	; clear rings
		move.l	d0,(v_time).w	; clear time
		move.b	d0,(v_centstep).w
		move.l	d0,(v_score).w	; clear score
		move.l  d0,(v_startscore).w ; clear start score
		move.b	d0,(v_continues).w ; clear continues
		move.l	#5000,(v_scorelife).w ; extra life is awarded at 50000 points
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Levels used in demos
; ---------------------------------------------------------------------------
Demo_Levels:	incbin	"misc\Demo Level Order - Intro.bin"
		even

; ---------------------------------------------------------------------------
; Subroutine to	change what you're selecting in the options menu
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


OptionControls:
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnUp+btnDn,d1			; is up/down pressed and held?
		bne.s	@upDown					; if yes, branch
		subq.w	#1,(v_levseldelay).w	; subtract 1 from time to next move
		bpl.s	Option_GameMode			; if time remains, branch

	@upDown:
		move.w	#$B,(v_levseldelay).w ; reset time delay
		move.b	(v_jpadhold1).w,d1
		andi.b	#btnUp+btnDn,d1		; is up/down pressed?
		beq.s	Option_GameMode		; if not, branch
		move.w	(v_levselitem).w,d0
		btst	#bitUp,d1			; is up	pressed?
		beq.s	@down				; if not, branch
		subq.w	#2,d0				; move up 1 selection
		bhs.s	@down
		moveq	#$14,d0				; if selection moves below 0, jump to selection	$14

	@down:
		btst	#bitDn,d1			; is down pressed?
		beq.s	@refresh			; if not, branch
		addq.w	#2,d0				; move down 1 selection
		cmpi.w	#$15,d0
		blo.s	@refresh
		moveq	#0,d0				; if selection moves above $14,	jump to	selection 0

	@refresh:
		move.w	d0,(v_levselitem).w ; set new selection
		bra.w	OptionsTextLoad		; refresh text	
; ===========================================================================

Option_GameMode:
		tst.w	(v_levselitem).w	; is item 0 selected? (Game Mode)
		bne.s	Option_Difficulty	; if not, branch
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnR+btnL,d1		; is left/right pressed?
		beq.s	@ret

		move.b	(v_optgamemode).w,d0
		btst	#bitL,d1			; is left pressed?
		beq.s	@right				; if not, branch
		subq.b	#1,d0				; subtract 1
		bcc.s	@right				; if act is above, or equal to 0, branch and skip.
		moveq	#3,d0				; if selection moves below 0, set to 3 (COMPLETE)

	@right:
		btst	#bitR,d1			; is right pressed?
		beq.s	@refresh			; if not, branch
		addq.b	#1,d0				; add 1	to sound test
		cmpi.b	#4,d0
		bcs.s	@refresh
		moveq	#0,d0				; if value moves above 3, set to 0

	@refresh:
		move.b	d0,(v_optgamemode).w	; set value
		bsr.w	OptionsTextLoad			; refresh text

	@ret:
		rts
; ===========================================================================

Option_Difficulty:
		cmpi.w	#6,(v_levselitem).w	; is Difficulty Options selected?
		bne.s	Option_Monitors		; if not, branch
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnR+btnL,d1		; is left/right pressed?
		beq.s	@ret				; if not, branch

		move.b	(v_difficulty).w,d0
		btst	#bitL,d1			; is left pressed?
		beq.s	@right				; if not, branch
		subq.b	#1,d0				; subtract 1 from difficulty setting
		bcc.s	@right				; if act is above, or equal to 0, branch and skip.
		moveq	#2,d0				; if selection moves below 0, set to 2 (HARD)

	@right:
		btst	#bitR,d1			; is right pressed?
		beq.s	@refresh			; if not, branch
		addq.b	#1,d0				; add 1	to difficulty setting
		cmpi.b	#3,d0
		bcs.s	@refresh
		moveq	#0,d0				; if value moves above 2, set to 0 (NORMAL)

	@refresh:
		move.b	d0,(v_difficulty).w	; set value
		bra.w	OptionsTextLoad		; refresh text

	@ret:
		rts
; ===========================================================================

Option_Monitors:
		cmpi.w	#8,(v_levselitem).w	; is Monitor Options selected?
		bne.s	Option_SndTest		; if not, branch
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnR+btnL,d1		; is left/right pressed?
		beq.s	@ret				; if not, branch
		move.b  (f_optmonitor).w,d0	; load monitor variable
		eori.b	#1,d0				; toggle monitor flag
		move.b  d0,(f_optmonitor).w	; set variable
		bra.w	OptionsTextLoad		; refresh text

	@ret:
		rts
; ===========================================================================

Option_SndTest:
		cmpi.w	#$10,(v_levselitem).w	; is item $14 selected?
		bne.s	@ret					; if not, branch
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnR+btnL,d1			; is left/right	pressed?
		beq.s	@ret					; if not, branch
		move.w	(v_levselsound).w,d0
		btst	#bitL,d1				; is left pressed?
		beq.s	@right					; if not, branch
		subq.w	#1,d0					; subtract 1 from sound	test
		bhs.s	@right
		moveq	#$4F,d0					; if sound test	moves below 0, set to $4F

	@right:
		btst	#bitR,d1		; is right pressed?
		beq.s	@refresh		; if not, branch
		addq.w	#1,d0			; add 1	to sound test
		cmpi.w	#$50,d0
		blo.s	@refresh
		moveq	#0,d0			; if sound test	moves above $4F, set to	0

	@refresh:
		move.w	d0,(v_levselsound).w	; set sound test number
		bsr.w	OptionsTextLoad			; refresh text

	@ret:
		rts	
; End of function OptionControls

; ---------------------------------------------------------------------------
; Subroutine to load Option Menu Text
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


OptionsTextLoad:

		textpos:	= ($40000000+(($E210&$3FFF)<<16)+(($E210&$C000)>>14))
					; $E210 is a VRAM address

		lea		(OptionMenuText).l,a1
		lea		(vdp_data_port).l,a6
		move.l	#textpos,d4	; text position on screen
		move.w	#$E680,d3	; VRAM setting (4th palette, $680th tile)
		moveq	#$14,d1		; number of lines of text

; DRAW STATIC TEXT LOADED FROM ROM. NEED TO ADD DYNAMIC TEXT HERE, AND HIGHLIGHT LATER BELOW
Options_DrawAll:
		move.l	d4,4(a6)
		bsr.w	Options_ChgLine	; draw line of text
		addi.l	#$800000,d4	; jump to next line
		dbf		d1,Options_DrawAll

; AFTER MAIN LINES ARE DRAWN, CONTINUE HIGHLIGHTING THE SELECTED LINE YELLOW
		moveq	#0,d0
		move.w	(v_levselitem).w,d0
		move.w	d0,d1
		move.l	#textpos,d4
		lsl.w	#7,d0
		swap	d0
		add.l	d0,d4
		lea		(OptionMenuText).l,a1
		lsl.w	#3,d1
		move.w	d1,d0
		add.w	d1,d1
		add.w	d0,d1
		adda.w	d1,a1
		move.w	#$C680,d3	; VRAM setting (3rd palette, $680th tile)
		move.l	d4,4(a6)
		bsr.w	Options_ChgLine	; recolour selected line

; Add options text dynamically

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Options_DrawMode:
		locVRAM	$E230			; Game Mode Text position
		moveq	#0,d0
		move.b	(v_optgamemode).w,d0
		lsl.w	#2,d0
		lea 	(ModeText).l,a2
		adda.l	d0,a2
		movea.l (a2),a1
		moveq 	#7,d2
		bsr.w	Options_LineLoop	; draw letters

Options_DrawPlayer:
		locVRAM	$E330			; Player Mode Text position
		moveq	#0,d0
		move.b	(v_playermode).w,d0
		lsl.w	#2,d0
		lea 	(CharText).l,a2
		adda.l	d0,a2
		movea.l (a2),a1
		moveq 	#6,d2
		bsr.w	Options_LineLoop	; draw letters

Options_DrawDifficulty:
		locVRAM	$E530			; Difficulty Text position
		moveq	#0,d0
		move.b	(v_difficulty).w,d0
		lsl.w	#2,d0
		lea 	(DifficultyText).l,a2
		adda.l	d0,a2
		movea.l (a2),a1
		moveq 	#5,d2
		bsr.w	Options_LineLoop	; draw letters

Options_DrawMonitors:
		locVRAM	$E630			; Monitor Text position
		moveq	#0,d0
		move.b	(f_optmonitor).w,d0
		lsl.w	#2,d0
		lea 	(MonitorText).l,a2
		adda.l	d0,a2
		movea.l (a2),a1
		moveq 	#7,d2
		bsr.w	Options_LineLoop	; draw letters

Options_DrawSnd: ; Dynamically draw the sound ID
		locVRAM	$EA30		; sound test position on screen
		move.w	(v_levselsound).w,d0
		move.b	d0,d2
		lsr.b	#4,d0
		bsr.s	Options_ChgSnd	; draw 1st digit
		move.b	d2,d0
		;bsr.s	Options_ChgSnd	; draw 2nd digit
		;rts
; End of function OptionsTextLoad


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Options_ChgSnd:
		andi.w	#$F,d0
		cmpi.b	#$A,d0		; is digit $A-$F?
		blo.s	@number		; if not, branch
		addi.b	#4,d0		; use alpha characters

	@number:
		add.w	d3,d0
		move.w	d0,(a6)
		rts	
; End of function Options_ChgSnd


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Options_ChgLine:
		moveq	#$17,d2		; number of characters per line

Options_LineLoop: ; THIS IS MERELY CHANGED TO ACCOMODATE FOR THE NEW ASCII SETUP BY SOULLESSSENTINEL
		moveq	#0,d0
		move.b	(a1)+,d0	; get character
		bpl.s	Options_CharOk	; branch if valid
		move.w	#0,(a6)		; use blank character
		dbf	d2,Options_LineLoop
		rts

Options_CharOk:
		cmp.w	#$40,d0		; Check for $40 (End of ASCII number area)
		blt.s	@notText	; If this is not an ASCII text character, branch
		sub.w	#$3,d0		; Subtract an extra 3 (Compensate for missing characters in the font)

	@notText:
		sub.w	#$30,d0		; Subtract #$33 (Convert to S2 font from ASCII)
		add.w	d3,d0		; combine char with VRAM setting
		move.w	d0,(a6)		; send to VRAM
		dbf		d2,Options_LineLoop
		rts
; End of function Options_ChgLine

; ===========================================================================

ModeText:
		dc.l	ModeText_Classic
		dc.l	ModeText_Original
		dc.l	ModeText_Handheld
		dc.l	ModeText_Complete
CharText:
		dc.l	CharText_Sonic
		dc.l	CharText_Tails
DifficultyText:
		dc.l	DifficultyText_Norm
		dc.l	DifficultyText_Easy
		dc.l	DifficultyText_Hard
MonitorText:
		dc.l	MonitorText_S1
		dc.l	MonitorText_S3K

; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

GM_Level:
		bset	#7,(v_gamemode).w ; add $80 to screen mode (for pre level sequence)
		tst.w	(f_demo).w
		bmi.s	Level_NoMusicFade
		sfx		bgm_Fade,0,1,1 ; fade out music

	Level_NoMusicFade:
		cmpi.b	#$8C,(v_gamemode).w	; is game mode = $0C (standard level)?
		bne.s	@NoSRAM				; if yes, branch
		tst.b	(f_timeattack).w
		bne.s	@NoSRAM
		move.b	#1,(SRAM_access_flag).l	; enable SRAM (required)
		lea		($200009).l,a1	; base of usable SRAM + 1
		move.w	(v_zone).w,d0	; move zone and act number to d0 (we can't do it directly)
		movep.w	d0,$A(a1)		; save zone and act to SRAM

		tst.b 	(v_lastlamp).w
		bne.s	@skipscore
		move.l	(v_startscore).w,d0
		movep.l	d0,$E(a1)

	@skipscore:		
		move.b	(v_lives).w,d0
		move.b	d0,$1E(a1)
		move.b	(v_lastspecial).w,d0
		move.b	d0,$20(a1)
		move.w	(v_emeralds).w,d0
		movep.w	d0,$22(a1)
		move.w	(v_redrings).w,d0
		movep.w	d0,$26(a1)
		clr.b	(SRAM_access_flag).l		; disable SRAM (required)

	@NoSRAM:
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		tst.w	(f_demo).w	; is an ending sequence demo running?
		bmi.s	Level_ClrRam	; if yes, branch
		disable_ints
		locVRAM	$B000
		lea 	Art_TitleCard,a0        ; load title card patterns
		move.l  #((Art_TitleCard_End-Art_TitleCard)/32)-1,d0; the title card art lenght, in tiles
		jsr 	LoadUncArt          ; load uncompressed art
		enable_ints
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#4,d0
		lea		(LevelHeaders).l,a2
		lea		(a2,d0.w),a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	loc_37FC
		bsr.w	AddPLC		; load level patterns

loc_37FC:
		moveq	#plcid_Main2,d0
		bsr.w	AddPLC		; load standard	patterns

Level_ClrRam:
		lea		(v_ringpos).w,a1
		moveq	#0,d0
		move.w	#$1A1,d1

	Level_ClrRingRam:
		move.l	d0,(a1)+
		dbf		d1,Level_ClrRingRam ; clear ring RAM
		clr.w	(f_level_started).w	; clear HUD and ring drawing flag, and HUD scrolling.

		lea		(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1

	Level_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,Level_ClrObjRam ; clear object RAM

		lea	($FFFFF628).w,a1
		moveq	#0,d0
		move.w	#$15,d1

	Level_ClrVars1:
		move.l	d0,(a1)+
		dbf	d1,Level_ClrVars1 ; clear misc variables

		lea	(v_screenposx).w,a1
		moveq	#0,d0
		move.w	#$3F,d1

	Level_ClrVars2:
		move.l	d0,(a1)+
		dbf	d1,Level_ClrVars2 ; clear misc variables

		lea	(v_oscillate+2).w,a1
		moveq	#0,d0
		move.w	#$47,d1

	Level_ClrVars3:
		move.l	d0,(a1)+
		dbf	d1,Level_ClrVars3 ; clear object variables

		disable_ints
		bsr.w	ClearScreen
		lea		(vdp_control_port).l,a6
		move.w	#$8B03,(a6)	; line scroll mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$8500+(vram_sprites>>9),(a6) ; set sprite table address
		move.w	#$9001,(a6)		; 64-cell hscroll size
		move.w	#$8004,(a6)		; 8-colour mode
		move.w	#$8720,(a6)		; set background colour (line 3; colour 0)
		move.w	#$8A00+223,(v_hbla_hreg).w ; set palette change position (for water)
		move.w	(v_hbla_hreg).w,(a6)

		; DMA QUEUE + flamewing optimization
		clr.w	(VDP_Command_Buffer).w
		move.w	#VDP_Command_Buffer,(VDP_Command_Buffer_Slot).w

		clr.b	(f_boss_active).w	; clear boss act flag

		cmpi.b	#id_LZ,(v_zone).w ; is level LZ?
		bne.s	Level_LoadPal	; if not, branch

		move.w	#$8014,(a6)	; enable H-interrupts
		moveq	#0,d0
		move.b	(v_act).w,d0
		add.w	d0,d0
		lea		(WaterHeight).l,a1 ; load water	height array
		move.w	(a1,d0.w),d0
		move.w	d0,(v_waterpos1).w ; set water heights
		move.w	d0,(v_waterpos2).w
		move.w	d0,(v_waterpos3).w
		clr.b	(v_wtr_routine).w ; clear water routine counter
		clr.b	(f_wtr_state).w	; clear	water state
		move.b	#1,(f_water).w	; enable water

Level_LoadPal:
		move.w	#30,(v_air).w
		enable_ints
		moveq	#palid_Sonic,d0
		bsr.w	PalLoad2	; load Sonic's palette
		cmpi.b	#id_LZ,(v_zone).w ; is level LZ?
		bne.s	Level_GetBgm	; if not, branch

		moveq	#palid_LZSonWater,d0 ; palette number $F (LZ)
		cmpi.b	#3,(v_act).w	; is act number 3?
		bne.s	Level_WaterPal	; if not, branch
		moveq	#palid_SBZ3SonWat,d0 ; palette number $10 (SBZ3)

	Level_WaterPal:
		bsr.w	PalLoad3_Water	; load underwater palette
		tst.b	(v_lastlamp).w
		beq.s	Level_GetBgm
		move.b	($FFFFFE53).w,(f_wtr_state).w

Level_GetBgm:
		tst.w	(f_demo).w
		bmi.s	Level_SkipTtlCard
		moveq	#0,d0
		move.b	(v_zone).w,d0
		cmpi.w	#(id_LZ<<8)+3,(v_zone).w ; is level SBZ3?
		bne.s	Level_BgmNotLZ4	; if not, branch
		moveq	#5,d0		; use 5th music (SBZ)

	Level_BgmNotLZ4:
		cmpi.w	#(id_SBZ<<8)+2,(v_zone).w ; is level FZ?
		bne.s	Level_PlayBgm	; if not, branch
		moveq	#6,d0		; use 6th music (FZ)

	Level_PlayBgm:
		lea		(MusicList).l,a1 ; load	music playlist
		move.b	(a1,d0.w),d0
		bsr.w	PlaySound	; play music
		move.b	#id_TitleCard,(v_titlespace).w ; load title card object

Level_TtlCardLoop:
		move.b	#$C,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		bsr.w	RunPLC
		move.w	(v_titlespace3+$08).w,d0
		cmp.w	(v_titlespace3+$30).w,d0 ; has title card sequence finished?
		bne.s	Level_TtlCardLoop ; if not, branch
		tst.l	(v_plc_buffer).w ; are there any items in the pattern load cue?
		bne.s	Level_TtlCardLoop ; if yes, branch
		tst.b	(f_timeattack).w
		beq.s 	@notTimeAttack
		jsr		(Hud_Base_TA).l	; load Time Attack HUD gfx
		bra.s	Level_SkipTtlCard
	@notTimeAttack:
		jsr		(Hud_Base).l	; load basic HUD gfx

	Level_SkipTtlCard:
		moveq	#palid_Sonic,d0
		bsr.w	PalLoad1	; load Sonic's palette
		bsr.w	LevelSizeLoad
		bsr.w	DeformLayers
		move.b	#$C,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bset	#2,(v_fg_scroll_flags).w
		bsr.w	LevelDataLoad ; load block mappings and palettes
		bsr.w	LoadTilesFromStart
		bsr.w	ColIndexLoad
		bsr.w	LZWaterFeatures
		move.b	#id_SonicPlayer,(v_player).w ; load Sonic object
		move.b	#id_ShieldItem,(v_shieldspace).w		; Create the instashield object
		move.b	#$D,(v_shieldspace+obAnim).w

Level_ChkDebug:
		tst.b	(f_debugcheat).w ; has debug cheat been entered?
		beq.s	Level_ChkWater	; if not, branch
		btst	#bitA,(v_jpadhold1).w ; is A button held?
		beq.s	Level_ChkWater	; if not, branch
		move.b	#1,(f_debugmode).w ; enable debug mode

Level_ChkWater:
		clr.w	(v_jpadhold2).w
		clr.w	(v_jpadhold1).w
		cmpi.b	#id_LZ,(v_zone).w ; is level LZ?
		bne.s	Level_LoadObj	; if not, branch
		move.b	#id_WaterSurface,(v_objspace+$780).w ; load water surface object
		move.w	#$60,(v_objspace+$780+obX).w
		move.b	#id_WaterSurface,(v_objspace+$7C0).w
		move.w	#$120,(v_objspace+$7C0+obX).w

Level_LoadObj:
		jsr		(ObjPosLoad).l
		jsr		(RingsManager).l	
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		moveq	#0,d0
		tst.b	(v_lastlamp).w		; are you starting from	a lamppost?
		bne.s	Level_SkipClr		; if yes, branch
		move.w	d0,(v_rings).w		; clear rings
		move.l	d0,(v_time).w		; clear time
		move.b	d0,(v_centstep).w	; clear centisecond incrementer (for Time Attack HUD)
		move.b	d0,(v_lifecount).w ; clear lives counter

	Level_SkipClr:
		; Endri Time Over mod
		tst.b   (f_timeover).w    ; test the time over flag
		bmi.s   @skiptimeclear    ; if negative, branch
		move.b  d0,(f_timeover).w ; clear time over flag
	@skiptimeclear: ; end of mod
		move.l  (v_startscore).w,(v_score).w
		move.b	d0,(v_status_secondary).w
		move.w	d0,(v_debuguse).w
		move.w	d0,(f_restart).w
		move.w	d0,(v_framecount).w
		bsr.w	OscillateNumInit
		move.b	#1,(f_scorecount).w ; update score counter
		move.b	#1,(f_ringcount).w ; update rings counter
;		move.b	#1,(f_timecount).w ; update time counter
		clr.w	(v_btnpushtime1).w
		lea		(DemoDataPtr).l,a1 ; load demo data
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		tst.w	(f_demo).w	; is demo mode on?
		bpl.s	Level_Demo	; if yes, branch
		lea	(DemoEndDataPtr).l,a1 ; load ending demo data
		move.w	(v_creditsnum).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1

Level_Demo:
		move.b	1(a1),(v_btnpushtime2).w ; load key press duration
		subq.b	#1,(v_btnpushtime2).w ; subtract 1 from duration
		move.w	#1800,(v_demolength).w
		tst.w	(f_demo).w
		bpl.s	Level_ChkWaterPal
		move.w	#540,(v_demolength).w
		cmpi.w	#4,(v_creditsnum).w
		bne.s	Level_ChkWaterPal
		move.w	#510,(v_demolength).w

Level_ChkWaterPal:
		cmpi.b	#id_LZ,(v_zone).w ; is level LZ/SBZ3?
		bne.s	Level_Delay	; if not, branch
		moveq	#palid_LZWater,d0 ; palette $B (LZ underwater)
		cmpi.b	#3,(v_act).w	; is level SBZ3?
		bne.s	Level_WtrNotSbz	; if not, branch
		moveq	#palid_SBZ3Water,d0 ; palette $D (SBZ3 underwater)

	Level_WtrNotSbz:
		add.b	(v_difficulty),d0
		bsr.w	PalLoad4_Water

Level_Delay:
		move.w	#3,d1

	Level_DelayLoop:
		move.b	#8,(v_vbla_routine).w
		bsr.w	WaitForVBla
		dbf	d1,Level_DelayLoop

		move.w	#$202F,(v_pfade_start).w ; fade in 2nd, 3rd & 4th palette lines
		bsr.w	PalFadeIn_Alt
		tst.w	(f_demo).w	; is an ending sequence demo running?
		bmi.s	Level_ClrCardArt ; if yes, branch
		addq.b	#2,(v_objspace+$80+obRoutine).w ; make title card move
		addq.b	#4,(v_objspace+$C0+obRoutine).w
		addq.b	#4,(v_objspace+$100+obRoutine).w
		addq.b	#4,(v_objspace+$140+obRoutine).w
		bra.s	Level_StartGame
; ===========================================================================

Level_ClrCardArt:
		moveq	#plcid_Explode,d0
		jsr		(AddPLC).l	; load explosion gfx
		jsr		(AddAnimalPLC).l	; load animal gfx (FraGag)

Level_StartGame:
		tst.w	(f_demo).w
		bmi.s	@demo
		move.b	#1,(f_level_started).w ; LEVEL START FLAG
	@demo:
		move.b	#1,(f_timecount).w ; update time counter
		bclr	#7,(v_gamemode).w ; subtract $80 from mode to end pre-level stuff
;		move.b	#1,(f_debugmode).w ; enable debug mode

; ---------------------------------------------------------------------------
; Main level loop (when	all title card and loading sequences are finished)
; ---------------------------------------------------------------------------

Level_MainLoop:
		bsr.w	PauseGame
		move.b	#8,(v_vbla_routine).w
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w ; add 1 to level timer
		bsr.w	MoveSonicInDemo
		bsr.w	LZWaterFeatures
		jsr		(ExecuteObjects).l
		tst.w   (f_restart).w
		bne     GM_Level
		jsr		(RingsManager).l
		tst.w	(v_debuguse).w	; is debug mode being used?
		bne.s	Level_DoScroll	; if yes, branch
		cmpi.b	#6,(v_player+obRoutine).w ; has Sonic just died?
		bhs.s	Level_SkipScroll ; if yes, branch

Level_DoScroll:
		bsr.w	DeformLayers

Level_SkipScroll:
		cmpi.b	#$90,(v_hudscrollpos).w
		beq.s	Level_SkipHUDScroll
		add.b	#4,(v_hudscrollpos).w

Level_SkipHUDScroll:
		jsr	(BuildSprites).l
		jsr	(ObjPosLoad).l
		bsr.w	PaletteCycle
		bsr.w	RunPLC
		bsr.w	OscillateNumDo
		bsr.w	SynchroAnimate
		bsr.w	EndofActLoad

		cmpi.b	#id_Demo,(v_gamemode).w
		beq.s	Level_ChkDemo	; if mode is 8 (demo), branch
		cmpi.b	#id_Level,(v_gamemode).w
		beq.w	Level_MainLoop	; if mode is $C (level), branch
		rts	
; ===========================================================================

Level_ChkDemo:
		tst.w	(f_restart).w	; is level set to restart?
		bne.s	Level_EndDemo	; if yes, branch
		tst.w	(v_demolength).w ; is there time left on the demo?
		beq.s	Level_EndDemo	; if not, branch
		cmpi.b	#id_Demo,(v_gamemode).w
		beq.w	Level_MainLoop	; if mode is 8 (demo), branch
		move.b	#id_Sega,(v_gamemode).w ; go to Sega screen
		rts	
; ===========================================================================

Level_EndDemo:
		cmpi.b	#id_Demo,(v_gamemode).w
		bne.s	Level_FadeDemo	; if mode is 8 (demo), branch
		move.b	#id_Sega,(v_gamemode).w ; go to Sega screen
		tst.w	(f_demo).w	; is demo mode on & not ending sequence?
		bpl.s	Level_FadeDemo	; if yes, branch
		move.b	#id_Credits,(v_gamemode).w ; go to credits

Level_FadeDemo:
		move.w	#$3C,(v_demolength).w
		move.w	#$3F,(v_pfade_start).w
		clr.w	(v_palchgspeed).w

	Level_FDLoop:
		move.b	#8,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	MoveSonicInDemo
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		jsr	(ObjPosLoad).l
		subq.w	#1,(v_palchgspeed).w
		bpl.s	loc_3BC8
		move.w	#2,(v_palchgspeed).w
		bsr.w	FadeOut_ToBlack

loc_3BC8:
		tst.w	(v_demolength).w
		bne.s	Level_FDLoop
		rts	
; ===========================================================================

		include	"_inc\LZWaterFeatures.asm"
		include	"_inc\MoveSonicInDemo.asm"

; ---------------------------------------------------------------------------
; Collision index pointer loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ColIndexLoad:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#3,d0					; MJ: multiply by 8 not 4
		move.l	ColPointers(pc,d0.w),(v_colladdr1).w	; MJ: get first collision set
		addq.w	#4,d0					; MJ: increase to next location
		move.l	ColPointers(pc,d0.w),(v_colladdr2).w	; MJ: get second collision set
		rts	
; End of function ColIndexLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Collision index pointers
; ---------------------------------------------------------------------------
ColPointers:
		dc.l Col_GHZ_1	; MJ: each zone now has two entries
		dc.l Col_GHZ_2
		dc.l Col_LZ_1
		dc.l Col_LZ_2
		dc.l Col_MZ_1
		dc.l Col_MZ_2
		dc.l Col_SLZ_1
		dc.l Col_SLZ_2
		dc.l Col_SYZ_1
		dc.l Col_SYZ_2
		dc.l Col_SBZ_1
		dc.l Col_SBZ_2
		dc.l Col_GHZ_1 ; Pointers for Ending are missing by default.
		dc.l Col_GHZ_2
		dc.l Col_BZ_1
		dc.l Col_BZ_2
		dc.l Col_JZ_1
		dc.l Col_JZ_2
		dc.l Col_SKBZ_1
		dc.l Col_SKBZ_2

		include	"_inc\Oscillatory Routines.asm"

; ---------------------------------------------------------------------------
; Subroutine to	change synchronised animation variables (rings, giant rings)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SynchroAnimate:

Sync1: ; Used for GHZ spiked log
		subq.b	#1,(v_ani0_time).w ; has timer reached 0?
		bpl.s	Sync2		; if not, branch
		move.b	#$B,(v_ani0_time).w ; reset timer
		subq.b	#1,(v_ani0_frame).w ; next frame
		andi.b	#7,(v_ani0_frame).w ; max frame is 7

Sync2: ; Unused unless I can find another purpose for it. (Currently for rings)
		subq.b	#1,(v_ani1_time).w  ; decrement timer
		bpl.s	Sync3               ; if timer !=0, branch
		move.b	#7,(v_ani1_time).w  ; reset timer
		addq.b	#1,(v_ani1_frame).w ; next frame
		andi.b	#3,(v_ani1_frame).w ; max frame is 3

; Used for 8 frame Rings and Giant Rings
Sync3:
		subq.b	#1,(v_ani2_time).w  ; decrement timer
		bpl.s	Sync4               ; if timer !=0, branch
		move.b	#3,(v_ani2_time).w  ; reset timer
		addq.b	#1,(v_ani2_frame).w ; next frame
		andi.b	#7,(v_ani2_frame).w ; max frame is 7

; Used for bouncing rings
Sync4:
		tst.b	(v_ani3_time).w
		beq.s	SyncEnd
		moveq	#0,d0
		move.b	(v_ani3_time).w,d0
		add.w	(v_ani3_buf).w,d0
		move.w	d0,(v_ani3_buf).w
		rol.w	#7,d0
		andi.w	#7,d0
		move.b	d0,(v_ani3_frame).w
		subq.b	#1,(v_ani3_time).w

SyncEnd:
		rts	
; End of function SynchroAnimate

; ---------------------------------------------------------------------------
; End-of-act loading subroutine
; This cannot load on acts with bosses (Act 3 normally. Act 2 on easy)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


EndofActLoad:			; XREF: GM_Level
		tst.b	(f_boss_active).w	; is this a boss act?
		bne.s	@exit
		tst.w	(v_debuguse).w		; is debug mode	being used?
		bne.s	@exit				; if yes, branch
		move.w	(v_screenposx).w,d0
		move.w	(v_limitright2).w,d1
		subi.w	#$100,d1
		cmp.w	d1,d0		; has Sonic reached the	edge of	the level?
		blt.s	@exit		; if not, branch
		tst.b	(f_timecount).w
		beq.s	@exit
		cmp.w	(v_limitleft2).w,d1
		beq.s	@exit
		move.w	d1,(v_limitleft2).w ; move left boundary to current screen position
		moveq	#plcid_EndofAct,d0
		bra.w	NewPLC		 ; load hidden points patterns

	@exit:
		rts	
; End of function EndofActLoad

; ===========================================================================
Demo_GHZ:	incbin	"demodata\Intro - GHZ.bin"
Demo_MZ:	incbin	"demodata\Intro - MZ.bin"
Demo_SYZ:	incbin	"demodata\Intro - SYZ.bin"
Demo_SS:	incbin	"demodata\Intro - Special Stage.bin"
; ===========================================================================

; ---------------------------------------------------------------------------
; Special Stage
; ---------------------------------------------------------------------------

GM_Special:
		sfx	sfx_EnterSS,0,1,0 ; play special stage entry sound
		bsr.w	PaletteWhiteOut
		disable_ints
		lea	(vdp_control_port).l,a6
		move.w	#$8B03,(a6)	; line scroll mode
		move.w	#$8004,(a6)	; 8-colour mode
		move.w	#$8A00+175,(v_hbla_hreg).w
		move.w	#$9011,(a6)	; 128-cell hscroll size
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen
		enable_ints
		fillVRAM	0,$6FFF,$5000

	SS_WaitForDMA:
		move.w	(a5),d1		; read control port ($C00004)
		btst	#1,d1		; is DMA running?
		bne.s	SS_WaitForDMA	; if yes, branch
		move.w	#$8F02,(a5)	; set VDP increment to 2 bytes
		bsr.w	SS_BGLoad
		moveq	#plcid_SpecialStage,d0
		bsr.w	QuickPLC	; load special stage patterns

		lea	(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
	SS_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,SS_ClrObjRam	; clear	the object RAM

		lea	(v_screenposx).w,a1
		moveq	#0,d0
		move.w	#$3F,d1
	SS_ClrRam1:
		move.l	d0,(a1)+
		dbf	d1,SS_ClrRam1	; clear	variables

		lea	(v_oscillate+2).w,a1
		moveq	#0,d0
		move.w	#$27,d1
	SS_ClrRam2:
		move.l	d0,(a1)+
		dbf	d1,SS_ClrRam2	; clear	variables

		lea	(v_ngfx_buffer).w,a1
		moveq	#0,d0
		move.w	#$7F,d1
	SS_ClrNemRam:
		move.l	d0,(a1)+
		dbf	d1,SS_ClrNemRam	; clear	Nemesis	buffer

		clr.b	(f_wtr_state).w
		clr.w	(f_restart).w
		moveq	#palid_Special,d0
		bsr.w	PalLoad1	; load special stage palette
		jsr		(SS_Load).l		; load SS layout data
		clr.w	(f_level_started).w	; clear the flag for drawing HUD and rings.
		clr.l	(v_screenposx).w
		clr.l	(v_screenposy).w
		move.b	#id_SonicSpecial,(v_player).w ; load special stage Sonic object
		move.b	#$FF,(v_ssangleprev).w	; fill previous angle with obviously false value to force an update
		move.b	#1,(f_timecount).w ; update time counter
		jsr		Hud_Base_SS	; load basic HUD gfx
		bsr.w	PalCycle_SS
		clr.w	(v_ssangle).w	; set stage angle to "upright"
		move.w	#$40,(v_ssrotate).w ; set stage rotation speed
		music	bgm_SS,0,1,0	; play special stage BG	music
		clr.w	(v_btnpushtime1).w
		lea		(DemoDataPtr).l,a1
		moveq	#6,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		move.b	1(a1),(v_btnpushtime2).w
		subq.b	#1,(v_btnpushtime2).w
		clr.w	(v_rings).w
		clr.b	(v_lifecount).w
		clr.w	(v_debuguse).w
		move.w	#1800,(v_demolength).w
		tst.b	(f_debugcheat).w ; has debug cheat been entered?
		beq.s	SS_NoDebug	; if not, branch
		btst	#bitA,(v_jpadhold1).w ; is A button pressed?
		beq.s	SS_NoDebug	; if not, branch
		move.b	#1,(f_debugmode).w ; enable debug mode

	SS_NoDebug:
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	PaletteWhiteIn
		move.b	#1,(f_level_started).w ; LEVEL START FLAG

; ---------------------------------------------------------------------------
; Main Special Stage loop
; ---------------------------------------------------------------------------

SS_MainLoop:
		bsr.w	PauseGame
		move.b	#$A,(v_vbla_routine).w
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w ; Added for blinking HUD and timing in SS Time Attack mode
		bsr.w	MoveSonicInDemo
		move.w	(v_jpadhold1).w,(v_jpadhold2).w
		jsr		(ExecuteObjects).l

		tst.b	(f_timecount).w
		beq.s	@remove
		cmpi.b	#$90,(v_hudscrollpos).w
		beq.s	SS_SkipHUDScroll
		add.b	#4,(v_hudscrollpos).w
		bra.s	SS_SkipHUDScroll

	@remove:
		tst.b	(v_hudscrollpos).w
		beq.s	SS_SkipHUDScroll
		subq.b	#2,(v_hudscrollpos).w

SS_SkipHUDScroll:
		jsr		(BuildSprites).l
		jsr		(SS_ShowLayout).l
		bsr.w	SS_BGAnimate
		tst.w	(f_demo).w	; is demo mode on?
		beq.s	SS_ChkEnd	; if not, branch
		tst.w	(v_demolength).w ; is there time left on the demo?
		beq.w	SS_ToSegaScreen	; if not, branch

	SS_ChkEnd:
		cmpi.b	#id_Special,(v_gamemode).w ; is game mode $10 (special stage)?
		beq.w	SS_MainLoop	; if yes, branch

		tst.w	(f_demo).w	; is demo mode on?
		bne.w	SS_ToLevel
		move.b	#id_Level,(v_gamemode).w ; set screen mode to $0C (level)
		cmpi.w	#(id_SBZ<<8)+3,(v_zone).w ; is level number higher than FZ?
		blo.s	SS_Finish	; if not, branch
		clr.w	(v_zone).w	; set to GHZ1

SS_Finish:
		move.w	#60,(v_demolength).w ; set delay time to 1 second
		move.w	#$3F,(v_pfade_start).w
		clr.w	(v_palchgspeed).w

	SS_FinLoop:
		move.b	#$16,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	MoveSonicInDemo
		move.w	(v_jpadhold1).w,(v_jpadhold2).w
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		jsr		(SS_ShowLayout).l
		bsr.w	SS_BGAnimate
		subq.w	#1,(v_palchgspeed).w
		bpl.s	loc_47D4
		move.w	#2,(v_palchgspeed).w
		bsr.w	WhiteOut_ToWhite

loc_47D4:
		tst.w	(v_demolength).w
		bne.s	SS_FinLoop

		disable_ints
		lea		(vdp_control_port).l,a6
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$9001,(a6)		; 64-cell hscroll size
		bsr.w	ClearScreen
		locVRAM	$B000
		lea 	Art_TitleCard,a0        ; load title card patterns
		move.l  #((Art_TitleCard_End-Art_TitleCard)/32)-1,d0; the title card art lenght, in tiles
		jsr 	LoadUncArt          ; load uncompressed art
		jsr		(Hud_Base).l

		; DMA QUEUE + flamewing optimization
		clr.w	(VDP_Command_Buffer).w
		move.w	#VDP_Command_Buffer,(VDP_Command_Buffer_Slot).w

		enable_ints
		moveq	#palid_SSResult,d0
		bsr.w	PalLoad2	; load results screen palette
		moveq	#plcid_Main,d0
		bsr.w	NewPLC
		moveq	#plcid_SSResult,d0
		bsr.w	AddPLC		; load results screen patterns
		move.b	#1,(f_scorecount).w ; update score counter
		move.b	#1,(f_endactbonus).w ; update ring bonus counter
		move.w	(v_rings).w,d0
		mulu.w	#10,d0		; multiply rings by 10
		move.w	d0,(v_ringbonus).w ; set rings bonus
		sfx		bgm_GotThrough,0,0,0	 ; play end-of-level music

		lea	(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
	SS_EndClrObjRam:
		move.l	d0,(a1)+
		dbf		d1,SS_EndClrObjRam ; clear object RAM

		move.b	#id_SSResult,(v_resultspace).w ; load results screen object

SS_NormalExit:
		bsr.w	PauseGame
		move.b	#$C,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		bsr.w	RunPLC
		tst.w	(f_restart).w
		beq.s	SS_NormalExit
		tst.l	(v_plc_buffer).w
		bne.s	SS_NormalExit
		sfx		sfx_EnterSS,0,1,0 ; play special stage exit sound
		bsr.w	PaletteWhiteOut
		rts	
; ===========================================================================

SS_ToSegaScreen:
		move.b	#id_Sega,(v_gamemode).w ; goto Sega screen
		rts

SS_ToLevel:	cmpi.b	#id_Level,(v_gamemode).w
		beq.s	SS_ToSegaScreen
		rts

; ---------------------------------------------------------------------------
; Special stage	background loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_BGLoad:
		lea	($FF0000).l,a1
		lea	(Eni_SSBg1).l,a0 ; load	mappings for the birds and fish
		move.w	#$4051,d0
		bsr.w	EniDec
		move.l	#$50000001,d3
		lea	($FF0080).l,a2
		moveq	#6,d7

loc_48BE:
		move.l	d3,d0
		moveq	#3,d6
		moveq	#0,d4
		cmpi.w	#3,d7
		bhs.s	loc_48CC
		moveq	#1,d4

loc_48CC:
		moveq	#7,d5

loc_48CE:
		movea.l	a2,a1
		eori.b	#1,d4
		bne.s	loc_48E2
		cmpi.w	#6,d7
		bne.s	loc_48F2
		lea	($FF0000).l,a1

loc_48E2:
		movem.l	d0-d4,-(sp)
		moveq	#7,d1
		moveq	#7,d2
		bsr.w	TilemapToVRAM
		movem.l	(sp)+,d0-d4

loc_48F2:
		addi.l	#$100000,d0
		dbf	d5,loc_48CE
		addi.l	#$3800000,d0
		eori.b	#1,d4
		dbf	d6,loc_48CC
		addi.l	#$10000000,d3
		bpl.s	loc_491C
		swap	d3
		addi.l	#$C000,d3
		swap	d3

loc_491C:
		adda.w	#$80,a2
		dbf	d7,loc_48BE
		lea	($FF0000).l,a1
		lea	(Eni_SSBg2).l,a0 ; load	mappings for the clouds
		move.w	#$4000,d0
		bsr.w	EniDec
		lea	($FF0000).l,a1
		move.l	#$40000003,d0
		moveq	#$3F,d1
		moveq	#$1F,d2
		bsr.w	TilemapToVRAM
		lea	($FF0000).l,a1
		move.l	#$50000003,d0
		moveq	#$3F,d1
		moveq	#$3F,d2
		bsr.w	TilemapToVRAM
		rts	
; End of function SS_BGLoad

; ---------------------------------------------------------------------------
; Palette cycling routine - special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_SS:
		tst.w	(f_pause).w
		bne.s	locret_49E6
		subq.w	#1,(v_palss_time).w
		bpl.s	locret_49E6
		lea	(vdp_control_port).l,a6
		move.w	(v_palss_num).w,d0
		addq.w	#1,(v_palss_num).w
		andi.w	#$1F,d0
		lsl.w	#2,d0
		lea	(byte_4A3C).l,a0
		adda.w	d0,a0
		move.b	(a0)+,d0
		bpl.s	loc_4992
		move.w	#$1FF,d0

loc_4992:
		move.w	d0,(v_palss_time).w
		moveq	#0,d0
		move.b	(a0)+,d0
		move.w	d0,($FFFFF7A0).w
		lea	(byte_4ABC).l,a1
		lea	(a1,d0.w),a1
		move.w	#-$7E00,d0
		move.b	(a1)+,d0
		move.w	d0,(a6)
		move.b	(a1),(v_scrposy_dup).w
		move.w	#-$7C00,d0
		move.b	(a0)+,d0
		move.w	d0,(a6)
		move.l	#$40000010,(vdp_control_port).l
		move.l	(v_scrposy_dup).w,(vdp_data_port).l
		moveq	#0,d0
		move.b	(a0)+,d0
		bmi.s	loc_49E8
		lea	(Pal_SSCyc1).l,a1
		adda.w	d0,a1
		lea	(v_pal_dry+$4E).w,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+

locret_49E6:
		rts	
; ===========================================================================

loc_49E8:
		move.w	($FFFFF79E).w,d1
		cmpi.w	#$8A,d0
		blo.s	loc_49F4
		addq.w	#1,d1

loc_49F4:
		mulu.w	#$2A,d1
		lea	(Pal_SSCyc2).l,a1
		adda.w	d1,a1
		andi.w	#$7F,d0
		bclr	#0,d0
		beq.s	loc_4A18
		lea	(v_pal_dry+$6E).w,a2
		move.l	(a1),(a2)+
		move.l	4(a1),(a2)+
		move.l	8(a1),(a2)+

loc_4A18:
		adda.w	#$C,a1
		lea	(v_pal_dry+$5A).w,a2
		cmpi.w	#$A,d0
		blo.s	loc_4A2E
		subi.w	#$A,d0
		lea	(v_pal_dry+$7A).w,a2

loc_4A2E:
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		adda.w	d0,a1
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		rts	
; End of function PalCycle_SS

; ===========================================================================
byte_4A3C:	dc.b 3,	0, 7, $92, 3, 0, 7, $90, 3, 0, 7, $8E, 3, 0, 7,	$8C

		dc.b 3,	0, 7, $8B, 3, 0, 7, $80, 3, 0, 7, $82, 3, 0, 7,	$84
		dc.b 3,	0, 7, $86, 3, 0, 7, $88, 7, 8, 7, 0, 7,	$A, 7, $C
		dc.b $FF, $C, 7, $18, $FF, $C, 7, $18, 7, $A, 7, $C, 7,	8, 7, 0
		dc.b 3,	0, 6, $88, 3, 0, 6, $86, 3, 0, 6, $84, 3, 0, 6,	$82
		dc.b 3,	0, 6, $81, 3, 0, 6, $8A, 3, 0, 6, $8C, 3, 0, 6,	$8E
		dc.b 3,	0, 6, $90, 3, 0, 6, $92, 7, 2, 6, $24, 7, 4, 6,	$30
		dc.b $FF, 6, 6,	$3C, $FF, 6, 6,	$3C, 7,	4, 6, $30, 7, 2, 6, $24
		even
byte_4ABC:	dc.b $10, 1, $18, 0, $18, 1, $20, 0, $20, 1, $28, 0, $28, 1
		even

Pal_SSCyc1:	incbin	"palette\Cycle - Special Stage 1.bin"
		even
Pal_SSCyc2:	incbin	"palette\Cycle - Special Stage 2.bin"
		even

; ---------------------------------------------------------------------------
; Subroutine to	make the special stage background animated
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_BGAnimate:
		move.w	($FFFFF7A0).w,d0
		bne.s	loc_4BF6
		move.w	#0,(v_bgscreenposy).w
		move.w	(v_bgscreenposy).w,(v_bgscrposy_dup).w

loc_4BF6:
		cmpi.w	#8,d0
		bhs.s	loc_4C4E
		cmpi.w	#6,d0
		bne.s	loc_4C10
		addq.w	#1,(v_bg3screenposx).w
		addq.w	#1,(v_bgscreenposy).w
		move.w	(v_bgscreenposy).w,(v_bgscrposy_dup).w

loc_4C10:
		moveq	#0,d0
		move.w	(v_bgscreenposx).w,d0
		neg.w	d0
		swap	d0
		lea	(byte_4CCC).l,a1
		lea	(v_ngfx_buffer).w,a3
		moveq	#9,d3

loc_4C26:
		move.w	2(a3),d0
		bsr.w	CalcSine
		moveq	#0,d2
		move.b	(a1)+,d2
		muls.w	d2,d0
		asr.l	#8,d0
		move.w	d0,(a3)+
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d2,(a3)+
		dbf	d3,loc_4C26
		lea	(v_ngfx_buffer).w,a3
		lea	(byte_4CB8).l,a2
		bra.s	loc_4C7E
; ===========================================================================

loc_4C4E:
		cmpi.w	#$C,d0
		bne.s	loc_4C74
		subq.w	#1,(v_bg3screenposx).w
		lea	($FFFFAB00).w,a3
		move.l	#$18000,d2
		moveq	#6,d1

loc_4C64:
		move.l	(a3),d0
		sub.l	d2,d0
		move.l	d0,(a3)+
		subi.l	#$2000,d2
		dbf	d1,loc_4C64

loc_4C74:
		lea	($FFFFAB00).w,a3
		lea	(byte_4CC4).l,a2

loc_4C7E:
		lea	(v_hscrolltablebuffer).w,a1
		move.w	(v_bg3screenposx).w,d0
		neg.w	d0
		swap	d0
		moveq	#0,d3
		move.b	(a2)+,d3
		move.w	(v_bgscreenposy).w,d2
		neg.w	d2
		andi.w	#$FF,d2
		lsl.w	#2,d2

loc_4C9A:
		move.w	(a3)+,d0
		addq.w	#2,a3
		moveq	#0,d1
		move.b	(a2)+,d1
		subq.w	#1,d1

loc_4CA4:
		move.l	d0,(a1,d2.w)
		addq.w	#4,d2
		andi.w	#$3FC,d2
		dbf	d1,loc_4CA4
		dbf	d3,loc_4C9A
		rts	
; End of function SS_BGAnimate

; ===========================================================================
byte_4CB8:	dc.b 9,	$28, $18, $10, $28, $18, $10, $30, $18,	8, $10,	0
		even
byte_4CC4:	dc.b 6,	$30, $30, $30, $28, $18, $18, $18
		even
byte_4CCC:	dc.b 8,	2, 4, $FF, 2, 3, 8, $FF, 4, 2, 2, 3, 8,	$FD, 4,	2, 2, 3, 2, $FF
		even

; ===========================================================================

; ---------------------------------------------------------------------------
; Continue screen
; ---------------------------------------------------------------------------

GM_Continue:
		bsr.w	PaletteFadeOut
		disable_ints
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		lea	(vdp_control_port).l,a6
		move.w	#$8004,(a6)	; 8 colour mode
		move.w	#$8700,(a6)	; background colour
		bsr.w	ClearScreen
		clr.w	(f_level_started).w	; LEVEL START FLAG and HUD SCROLL

		lea	(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
	Cont_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,Cont_ClrObjRam ; clear object RAM

		locVRAM	$B000
		lea 	Art_TitleCard,a0        ; load title card patterns
		move.l  #((Art_TitleCard_End-Art_TitleCard)/32)-1,d0; the title card art lenght, in tiles
		jsr 	LoadUncArt          ; load uncompressed art
		locVRAM	$A000
		lea	(Nem_ContSonic).l,a0 ; load Sonic patterns
		bsr.w	NemDec
		locVRAM	$AA20
		lea	(Nem_MiniSonic).l,a0 ; load continue screen patterns
		bsr.w	NemDec
		moveq	#10,d1
		jsr	(ContScrCounter).l	; run countdown	(start from 10)
		moveq	#palid_Continue,d0
		bsr.w	PalLoad1	; load continue	screen palette
		music	bgm_Continue,0,1,1	; play continue	music
		move.w	#659,(v_demolength).w ; set time delay to 11 seconds
		clr.l	(v_screenposx).w
		move.l	#$1000000,(v_screenposy).w
		move.b	#id_ContSonic,(v_player).w ; load Sonic object
		move.b	#id_ContScrItem,(v_objspace+$40).w ; load continue screen objects
		move.b	#id_ContScrItem,(v_objspace+$80).w
		move.w	#$180,(v_objspace+$80+obPriority).w
		move.b	#4,(v_objspace+$80+obFrame).w
		move.b	#id_ContScrItem,(v_objspace+$C0).w
		move.b	#4,(v_objspace+$C0+obRoutine).w
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	PaletteFadeIn

; ---------------------------------------------------------------------------
; Continue screen main loop
; ---------------------------------------------------------------------------

Cont_MainLoop:
		move.b	#$16,(v_vbla_routine).w
		bsr.w	WaitForVBla
		cmpi.b	#6,(v_player+obRoutine).w
		bhs.s	loc_4DF2
		disable_ints
		move.w	(v_demolength).w,d1
		divu.w	#$3C,d1
		andi.l	#$F,d1
		jsr	(ContScrCounter).l
		enable_ints

loc_4DF2:
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		cmpi.w	#$180,(v_player+obX).w ; has Sonic run off screen?
		bhs.s	Cont_GotoLevel	; if yes, branch
		cmpi.b	#6,(v_player+obRoutine).w
		bhs.s	Cont_MainLoop
		tst.w	(v_demolength).w
		bne.w	Cont_MainLoop
		move.b	#id_Sega,(v_gamemode).w ; go to Sega screen
		rts	
; ===========================================================================

Cont_GotoLevel:
		move.b	#id_Level,(v_gamemode).w ; set screen mode to $0C (level)
		move.b	#3,(v_lives).w	; set lives to 3
		cmpi.b	#difEasy,(v_difficulty).w
		bne.s	@clear
		move.b	#5,(v_lives).w	; set lives to 5
	@clear:
		moveq	#0,d0
		move.w	d0,(v_rings).w	; clear rings
		move.l	d0,(v_time).w	; clear time
		move.b	d0,(v_centstep).w
		move.l  d0,(v_startscore).w ; clear start score
		move.l	d0,(v_score).w	; clear score
		move.b	d0,(v_lastlamp).w ; clear lamppost count
		move.l	#5000,(v_scorelife).w ; extra life is awarded at 50000 points
		subq.b	#1,(v_continues).w ; subtract 1 from continues
		rts	
; ===========================================================================

		include	"_incObj\80 Continue Screen Elements.asm"
		include	"_incObj\81 Continue Screen Sonic.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Ending sequence in Green Hill	Zone
; ---------------------------------------------------------------------------

GM_Ending:
		sfx	bgm_Stop,0,1,1 ; stop music
		bsr.w	PaletteFadeOut

		lea	(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
	End_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,End_ClrObjRam ; clear object	RAM

		lea	($FFFFF628).w,a1
		moveq	#0,d0
		move.w	#$15,d1
	End_ClrRam1:
		move.l	d0,(a1)+
		dbf	d1,End_ClrRam1	; clear	variables

		lea	(v_screenposx).w,a1
		moveq	#0,d0
		move.w	#$3F,d1
	End_ClrRam2:
		move.l	d0,(a1)+
		dbf	d1,End_ClrRam2	; clear	variables

		lea	(v_oscillate+2).w,a1
		moveq	#0,d0
		move.w	#$47,d1
	End_ClrRam3:
		move.l	d0,(a1)+
		dbf	d1,End_ClrRam3	; clear	variables

		disable_ints
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen
		lea	(vdp_control_port).l,a6
		move.w	#$8B03,(a6)	; line scroll mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$8500+(vram_sprites>>9),(a6) ; set sprite table address
		move.w	#$9001,(a6)		; 64-cell hscroll size
		move.w	#$8004,(a6)		; 8-colour mode
		move.w	#$8720,(a6)		; set background colour (line 3; colour 0)
		move.w	#$8A00+223,(v_hbla_hreg).w ; set palette change position (for water)
		move.w	(v_hbla_hreg).w,(a6)
		move.w	#30,(v_air).w
		move.w	#id_EndZ<<8,(v_zone).w ; set level number to 0600 (extra flowers)
		cmpi.b	#6,(v_emeralds).w ; do you have all 6 emeralds?
		beq.s	End_LoadData	; if yes, branch
		move.w	#(id_EndZ<<8)+1,(v_zone).w ; set level number to 0601 (no flowers)

End_LoadData:
		moveq	#plcid_Ending,d0
		bsr.w	QuickPLC	; load ending sequence patterns
		jsr	(Hud_Base).l
		bsr.w	LevelSizeLoad
		bsr.w	DeformLayers
		bset	#2,(v_fg_scroll_flags).w
		bsr.w	LevelDataLoad
		move.b  #$C,(v_vbla_routine).w 	; the two lines above LoadTilesFromStart to fix a bug. - VLADIKOMPER
		bsr.w   WaitForVBla
		bsr.w	LoadTilesFromStart
		move.l	#Col_GHZ_1,(v_colladdr1).w ; MJ: Set first collision for ending
		move.l	#Col_GHZ_2,(v_colladdr2).w ; MJ: Set second collision for ending
		enable_ints
		lea		(Kos_EndFlowers).l,a0 ;	load extra flower patterns
		lea		($FFFF9400).w,a1 ; RAM address to buffer the patterns
		bsr.w	KosDec
		moveq	#palid_Sonic,d0
		bsr.w	PalLoad1	; load Sonic's palette
		music	bgm_Ending,0,1,0	; play ending sequence music

		move.b	#id_SonicPlayer,(v_player).w ; load Sonic object
		bset	#staFacing,(v_player+obStatus).w ; make Sonic face left
		move.b	#1,(f_lockctrl).w ; lock controls
		move.w	#(btnL<<8),(v_jpadhold2).w ; move Sonic to the left
		move.w	#$F800,(v_player+obInertia).w ; set Sonic's speed
		move.w	#$190,(f_level_started).w ; Allow the HUD and hardset HUD's position
		jsr		(ObjPosLoad).l
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		moveq	#0,d0
		move.w	d0,(v_rings).w
		move.l	d0,(v_time).w
		move.b	d0,(v_lifecount).w
		move.b	d0,(v_status_secondary).w 
		move.w	d0,(v_debuguse).w
		move.w	d0,(f_restart).w
		move.w	d0,(v_framecount).w
		bsr.w	OscillateNumInit
		move.b	#1,(f_scorecount).w
		move.b	#1,(f_ringcount).w
		move.b	#0,(f_timecount).w
		move.w	#1800,(v_demolength).w
		move.b	#$18,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		move.w	#$3F,(v_pfade_start).w
		bsr.w	PaletteFadeIn

; ---------------------------------------------------------------------------
; Main ending sequence loop
; ---------------------------------------------------------------------------

End_MainLoop:
		bsr.w	PauseGame
		move.b	#$18,(v_vbla_routine).w
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w
		bsr.w	End_MoveSonic
		jsr	(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr	(BuildSprites).l
		jsr	(ObjPosLoad).l
		bsr.w	PaletteCycle
		bsr.w	OscillateNumDo
		bsr.w	SynchroAnimate
		cmpi.b	#id_Ending,(v_gamemode).w ; is game mode $18 (ending)?
		beq.s	End_ChkEmerald	; if yes, branch

		move.b	#id_Credits,(v_gamemode).w ; goto credits
		sfx	bgm_Credits,0,1,1 ; play credits music
		move.w	#0,(v_creditsnum).w ; set credits index number to 0
		rts	
; ===========================================================================

End_ChkEmerald:
		tst.w	(f_restart).w	; has Sonic released the emeralds?
		beq.w	End_MainLoop	; if not, branch

		clr.w	(f_restart).w
		move.w	#$3F,(v_pfade_start).w
		clr.w	(v_palchgspeed).w

	End_AllEmlds:
		bsr.w	PauseGame
		move.b	#$18,(v_vbla_routine).w
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w
		bsr.w	End_MoveSonic
		jsr	(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr	(BuildSprites).l
		jsr	(ObjPosLoad).l
		bsr.w	OscillateNumDo
		bsr.w	SynchroAnimate
		subq.w	#1,(v_palchgspeed).w
		bpl.s	End_SlowFade
		move.w	#2,(v_palchgspeed).w
		bsr.w	WhiteOut_ToWhite

	End_SlowFade:
		tst.w	(f_restart).w
		beq.w	End_AllEmlds
		clr.w	(f_restart).w
		move.l	#Level_EndGood,(v_lvllayoutfg).w ; MJ: set extra flowers version of ending's layout to be read
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(v_screenposx).w,a3
		movea.l	(v_lvllayoutfg).w,a4	; MJ: Load address of layout
		move.w	#$4000,d2
		bsr.w	DrawChunks
		moveq	#palid_Ending,d0
		bsr.w	PalLoad1	; load ending palette
		bsr.w	PaletteWhiteIn
		bra.w	End_MainLoop

; ---------------------------------------------------------------------------
; Subroutine controlling Sonic on the ending sequence
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


End_MoveSonic:
		move.b	(v_sonicend).w,d0
		bne.s	End_MoveSon2
		cmpi.w	#$90,(v_player+obX).w ; has Sonic passed $90 on x-axis?
		bhs.s	End_MoveSonExit	; if not, branch

		addq.b	#2,(v_sonicend).w
		move.b	#1,(f_lockctrl).w ; lock player's controls
		move.w	#(btnR<<8),(v_jpadhold2).w ; move Sonic to the right
		rts	
; ===========================================================================

End_MoveSon2:
		subq.b	#2,d0
		bne.s	End_MoveSon3
		cmpi.w	#$A0,(v_player+obX).w ; has Sonic passed $A0 on x-axis?
		blo.s	End_MoveSonExit	; if not, branch

		addq.b	#2,(v_sonicend).w
		moveq	#0,d0
		move.b	d0,(f_lockctrl).w
		move.w	d0,(v_jpadhold2).w ; stop Sonic moving
		move.w	d0,(v_player+obInertia).w
		move.b	#$81,(f_lockmulti).w ; lock controls & position
		move.b	#3,(v_player+obFrame).w
		move.w	#(aniID_Wait<<8)+aniID_Wait,(v_player+obAnim).w ; use "standing" animation
		move.b	#3,(v_player+obTimeFrame).w
		rts	
; ===========================================================================

End_MoveSon3:
		subq.b	#2,d0
		bne.s	End_MoveSonExit
		addq.b	#2,(v_sonicend).w
		move.w	#$A0,(v_player+obX).w
		move.b	#id_EndSonic,(v_player).w ; load Sonic ending sequence object
		clr.w	(v_player+obRoutine).w

End_MoveSonExit:
		rts	
; End of function End_MoveSonic

; ===========================================================================

		include	"_incObj\87 Ending Sequence Sonic.asm"
		include	"_incObj\88 Ending Sequence Emeralds.asm"
		include	"_incObj\89 Ending Sequence STH.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Credits ending sequence
; ---------------------------------------------------------------------------

GM_Credits:
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		lea		(vdp_control_port).l,a6
		move.w	#$8004,(a6)		; 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$9001,(a6)		; 64-cell hscroll size
		move.w	#$9200,(a6)		; window vertical position
		move.w	#$8B03,(a6)		; line scroll mode
		move.w	#$8720,(a6)		; set background colour (line 3; colour 0)
		clr.b	(f_wtr_state).w
		bsr.w	ClearScreen
		clr.w	(f_level_started).w ; HUD Drawing and Scrolling

		lea		(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
	Cred_ClrObjRam:
		move.l	d0,(a1)+
		dbf		d1,Cred_ClrObjRam ; clear object RAM

		locVRAM	$B400
		lea		(Nem_CreditText).l,a0 ;	load credits alphabet patterns
		bsr.w	NemDec

		lea		(v_pal_dry_dup).w,a1
		moveq	#0,d0
		move.w	#$1F,d1
	Cred_ClrPal:
		move.l	d0,(a1)+
		dbf		d1,Cred_ClrPal ; fill palette with black

		moveq	#palid_Sonic,d0
		bsr.w	PalLoad1	; load Sonic's palette
		move.b	#id_CreditsText,(v_objspace+$80).w ; load credits object
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		bsr.w	EndingDemoLoad
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#4,d0
		lea		(LevelHeaders).l,a2
		lea		(a2,d0.w),a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	Cred_SkipObjGfx
		bsr.w	AddPLC		; load object graphics

	Cred_SkipObjGfx:
		moveq	#plcid_Main2,d0
		bsr.w	AddPLC		; load standard	level graphics
		move.w	#120,(v_demolength).w ; display a credit for 2 seconds
		bsr.w	PaletteFadeIn

Cred_WaitLoop:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	RunPLC
		tst.w	(v_demolength).w ; have 2 seconds elapsed?
		bne.s	Cred_WaitLoop	; if not, branch
		tst.l	(v_plc_buffer).w ; have level gfx finished decompressing?
		bne.s	Cred_WaitLoop	; if not, branch
		cmpi.w	#9,(v_creditsnum).w ; have the credits finished?
		beq.w	TryAgainEnd	; if yes, branch
		rts	

; ---------------------------------------------------------------------------
; Ending sequence demo loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


EndingDemoLoad:
		move.w	(v_creditsnum).w,d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	EndDemo_Levels(pc,d0.w),d0 ; load level	array
		move.w	d0,(v_zone).w	; set level from level array
		addq.w	#1,(v_creditsnum).w
		cmpi.w	#9,(v_creditsnum).w ; have credits finished?
		bhs.s	EndDemo_Exit	; if yes, branch
		move.w	#$8001,(f_demo).w ; set demo+ending mode
		move.b	#id_Demo,(v_gamemode).w ; set game mode to 8 (demo)
		move.b	#3,(v_lives).w	; set lives to 3
		cmpi.b	#difEasy,(v_difficulty).w
		bne.s	@clear
		move.b	#5,(v_lives).w	; set lives to 5
	@clear:
		moveq	#0,d0
		move.w	d0,(v_rings).w	; clear rings
		move.l	d0,(v_time).w	; clear time
		move.b	d0,(v_centstep).w
		move.l	d0,(v_score).w	; clear score
		move.l  d0,(v_startscore).w ; clear start score
		move.b	d0,(v_lastlamp).w ; clear lamppost counter
		cmpi.w	#4,(v_creditsnum).w ; is SLZ demo running?
		bne.s	EndDemo_Exit	; if not, branch
		lea	(EndDemo_LampVar).l,a1 ; load lamppost variables
		lea	(v_lastlamp).w,a2
		move.w	#8,d0

	EndDemo_LampLoad:
		move.l	(a1)+,(a2)+
		dbf	d0,EndDemo_LampLoad

EndDemo_Exit:
		rts	
; End of function EndingDemoLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Levels used in the end sequence demos
; ---------------------------------------------------------------------------
EndDemo_Levels:	incbin	"misc\Demo Level Order - Ending.bin"

; ---------------------------------------------------------------------------
; Lamppost variables in the end sequence demo (Star Light Zone)
; ---------------------------------------------------------------------------
EndDemo_LampVar:
		dc.b 1,	1		; number of the last lamppost
		dc.w $A00, $62C		; x/y-axis position
		dc.w 13			; rings
		dc.l 0			; time
		dc.b 0,	0		; dynamic level event routine counter
		dc.w $800		; level bottom boundary
		dc.w $957, $5CC		; x/y axis screen position
		dc.w $4AB, $3A6, 0, $28C, 0, 0 ; scroll info
		dc.w $308		; water height
		dc.b 1,	1		; water routine and state
; ===========================================================================
; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screens
; ---------------------------------------------------------------------------

TryAgainEnd:
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		lea	(vdp_control_port).l,a6
		move.w	#$8004,(a6)	; use 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$9001,(a6)	; 64-cell hscroll size
		move.w	#$9200,(a6)	; window vertical position
		move.w	#$8B03,(a6)	; line scroll mode
		move.w	#$8720,(a6)	; set background colour (line 3; colour 0)
		clr.b	(f_wtr_state).w
		bsr.w	ClearScreen

		lea	(v_objspace).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
	TryAg_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,TryAg_ClrObjRam ; clear object RAM

		moveq	#plcid_TryAgain,d0
		bsr.w	QuickPLC	; load "TRY AGAIN" or "END" patterns

		lea	(v_pal_dry_dup).w,a1
		moveq	#0,d0
		move.w	#$1F,d1
	TryAg_ClrPal:
		move.l	d0,(a1)+
		dbf	d1,TryAg_ClrPal ; fill palette with black

		moveq	#palid_Ending,d0
		bsr.w	PalLoad1	; load ending palette
		clr.w	(v_pal_dry_dup+$40).w
		move.b	#id_EndEggman,(v_objspace+$80).w ; load Eggman object
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		move.w	#1800,(v_demolength).w ; show screen for 30 seconds
		bsr.w	PaletteFadeIn

; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screen main loop
; ---------------------------------------------------------------------------
TryAg_MainLoop:
		bsr.w	PauseGame
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		andi.b	#btnStart,(v_jpadpress1).w ; is Start button pressed?
		bne.s	TryAg_Exit	; if yes, branch
		tst.w	(v_demolength).w ; has 30 seconds elapsed?
		beq.s	TryAg_Exit	; if yes, branch
		cmpi.b	#id_Credits,(v_gamemode).w
		beq.s	TryAg_MainLoop

TryAg_Exit:
		move.b	#id_Sega,(v_gamemode).w ; goto Sega screen
		rts	

; ===========================================================================

		include	"_incObj\8B Try Again & End Eggman.asm"
		include	"_incObj\8C Try Again Emeralds.asm"



; ---------------------------------------------------------------------------
; Ending sequence demos
; ---------------------------------------------------------------------------
Demo_EndGHZ1:	incbin	"demodata\Ending - GHZ1.bin"
		even
Demo_EndMZ:	incbin	"demodata\Ending - MZ.bin"
		even
Demo_EndSYZ:	incbin	"demodata\Ending - SYZ.bin"
		even
Demo_EndLZ:	incbin	"demodata\Ending - LZ.bin"
		even
Demo_EndSLZ:	incbin	"demodata\Ending - SLZ.bin"
		even
Demo_EndSBZ1:	incbin	"demodata\Ending - SBZ1.bin"
		even
Demo_EndSBZ2:	incbin	"demodata\Ending - SBZ2.bin"
		even
Demo_EndGHZ2:	incbin	"demodata\Ending - GHZ2.bin"
		even

	include	"_inc\LevelSizeLoad & BgScrollSpeed.asm"
	include	"_inc\DeformLayers.asm"


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_6886:
LoadTilesAsYouMove_BGOnly:
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(v_bg1_scroll_flags).w,a2
		lea	(v_bgscreenposx).w,a3
		movea.l	(v_lvllayoutbg).w,a4	; MJ: Load address of layout BG
		move.w	#$6000,d2
		bsr.w	DrawBGScrollBlock1
		lea	(v_bg2_scroll_flags).w,a2
		lea	(v_bg2screenposx).w,a3
		bra.w	DrawBGScrollBlock2
; End of function sub_6886

; ---------------------------------------------------------------------------
; Subroutine to	display	correct	tiles as you move
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesAsYouMove:
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		; First, update the background
		lea	(v_bg1_scroll_flags_dup).w,a2	; Scroll block 1 scroll flags
		lea	(v_bgscreenposx_dup).w,a3	; Scroll block 1 X coordinate
		movea.l	(v_lvllayoutbg).w,a4		; MJ: Load address of layout BG
		move.w	#$6000,d2			; VRAM thing for selecting Plane B
		bsr.w	DrawBGScrollBlock1
		lea	(v_bg2_scroll_flags_dup).w,a2	; Scroll block 2 scroll flags
		lea	(v_bg2screenposx_dup).w,a3	; Scroll block 2 X coordinate
		bsr.w	DrawBGScrollBlock2

		; REV01 added a third scroll block, though, technically,
		; the RAM for it was already there in REV00
		lea	(v_bg3_scroll_flags_dup).w,a2	; Scroll block 3 scroll flags
		lea	(v_bg3screenposx_dup).w,a3	; Scroll block 3 X coordinate
		bsr.w	DrawBGScrollBlock3

		; Then, update the foreground
		lea	(v_fg_scroll_flags_dup).w,a2	; Foreground scroll flags
		lea	(v_screenposx_dup).w,a3		; Foreground X coordinate
		movea.l	(v_lvllayoutfg).w,a4		; MJ: Load address of layout
		move.w	#$4000,d2			; VRAM thing for selecting Plane A
		; The FG's update function is inlined here
		tst.b	(a2)
		beq.s	locret_6952	; If there are no flags set, nothing needs updating
		bclr	#0,(a2)
		beq.s	loc_6908
		; Draw new tiles at the top
		moveq	#-16,d4	; Y coordinate. Note that 16 is the size of a block in pixels
		moveq	#-16,d5 ; X coordinate
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4 ; Y coordinate
		moveq	#-16,d5 ; X coordinate
		bsr.w	DrawBlocks_LR

loc_6908:
		bclr	#1,(a2)
		beq.s	loc_6922
		; Draw new tiles at the bottom
		move.w	#224,d4	; Start at bottom of the screen. Since this draws from top to bottom, we don't need 224+16
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#224,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_LR

loc_6922:
		bclr	#2,(a2)
		beq.s	loc_6938
		; Draw new tiles on the left
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_TB

loc_6938:
		bclr	#3,(a2)
		beq.s	locret_6952
		; Draw new tiles on the right
		moveq	#-16,d4
		move.w	#320,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		move.w	#320,d5
		bsr.w	DrawBlocks_TB

locret_6952:
		rts	
; End of function LoadTilesAsYouMove


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_6954:
DrawBGScrollBlock1:
		tst.b	(a2)
		beq.w	locret_69F2
		bclr	#0,(a2)
		beq.s	loc_6972
		; Draw new tiles at the top
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		moveq	#-16,d5

		bsr.w	DrawBlocks_LR


loc_6972:
		bclr	#1,(a2)
		beq.s	loc_698E
		; Draw new tiles at the top
		move.w	#224,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#224,d4
		moveq	#-16,d5

		bsr.w	DrawBlocks_LR


loc_698E:
		bclr	#2,(a2)

		beq.s	loc_6D56
		; Draw new tiles on the left
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		moveq	#-16,d5
		bsr.w	DrawBlocks_TB
loc_6D56:

		bclr	#3,(a2)
		beq.s	loc_6D70
		; Draw new tiles on the right
		moveq	#-16,d4
		move.w	#320,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-16,d4
		move.w	#320,d5
		bsr.w	DrawBlocks_TB
loc_6D70:

		bclr	#4,(a2)
		beq.s	loc_6D88
		; Draw entire row at the top
		moveq	#-16,d4
		moveq	#0,d5
		bsr.w	Calc_VRAM_Pos_2
		moveq	#-16,d4
		moveq	#0,d5
		moveq	#(512/16)-1,d6
		bsr.w	DrawBlocks_LR_3
loc_6D88:

		bclr	#5,(a2)
		beq.s	locret_69F2
		; Draw entire row at the bottom
		move.w	#224,d4
		moveq	#0,d5
		bsr.w	Calc_VRAM_Pos_2
		move.w	#224,d4
		moveq	#0,d5
		moveq	#(512/16)-1,d6
		bsr.w	DrawBlocks_LR_3

locret_69F2:
		rts	
; End of function DrawBGScrollBlock1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Essentially, this draws everything that isn't scroll block 1
; sub_69F4:
DrawBGScrollBlock2:
			tst.b	(a2)
			beq.w	locj_6DF2
			cmpi.b	#id_SBZ,(v_zone).w
			beq.w	Draw_SBz
			bclr	#0,(a2)
			beq.s	locj_6DD2
			; Draw new tiles on the left
			move.w	#224/2,d4	; Draw the bottom half of the screen
			moveq	#-16,d5
			bsr.w	Calc_VRAM_Pos
			move.w	#224/2,d4
			moveq	#-16,d5
			moveq	#3-1,d6		; Draw three rows... could this be a repurposed version of the above unused code?
			bsr.w	DrawBlocks_TB_2
	locj_6DD2:
			bclr	#1,(a2)
			beq.s	locj_6DF2
			; Draw new tiles on the right
			move.w	#224/2,d4
			move.w	#320,d5
			bsr.w	Calc_VRAM_Pos
			move.w	#224/2,d4
			move.w	#320,d5
			moveq	#3-1,d6
			bsr.w	DrawBlocks_TB_2
	locj_6DF2:
			rts
;===============================================================================
	locj_6DF4:
			dc.b $00,$00,$00,$00,$00,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$04
			dc.b $04,$04,$04,$04,$04,$04,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$00						
;===============================================================================
	Draw_SBz:
			moveq	#-16,d4
			bclr	#0,(a2)
			bne.s	locj_6E28
			bclr	#1,(a2)
			beq.s	locj_6E72
			move.w	#224,d4
	locj_6E28:
			lea	(locj_6DF4+1).l,a0
			move.w	(v_bgscreenposy).w,d0
			add.w	d4,d0
			andi.w	#$1F0,d0
			lsr.w	#4,d0
			move.b	(a0,d0.w),d0
			lea	(locj_6FE4).l,a3
			movea.w	(a3,d0.w),a3
			beq.s	locj_6E5E
			moveq	#-16,d5
			movem.l	d4/d5,-(sp)
			bsr.w	Calc_VRAM_Pos
			movem.l	(sp)+,d4/d5
			bsr.w	DrawBlocks_LR
			bra.s	locj_6E72
;===============================================================================
	locj_6E5E:
			moveq	#0,d5
			movem.l	d4/d5,-(sp)
			bsr.w	Calc_VRAM_Pos_2
			movem.l	(sp)+,d4/d5
			moveq	#(512/16)-1,d6
			bsr.w	DrawBlocks_LR_3
	locj_6E72:
			tst.b	(a2)
			bne.s	locj_6E78
			rts
;===============================================================================			
	locj_6E78:
			moveq	#-16,d4
			moveq	#-16,d5
			move.b	(a2),d0
			andi.b	#$A8,d0
			beq.s	locj_6E8C
			lsr.b	#1,d0
			move.b	d0,(a2)
			move.w	#320,d5
	locj_6E8C:
			lea	(locj_6DF4).l,a0
			move.w	(v_bgscreenposy).w,d0
			andi.w	#$1F0,d0
			lsr.w	#4,d0
			lea	(a0,d0.w),a0
			bra.w	locj_6FEC						
;===============================================================================


	; locj_6EA4:
	DrawBGScrollBlock3:
			tst.b	(a2)
			beq.w	locj_6EF0
			cmpi.b	#id_MZ,(v_zone).w
			beq.w	Draw_Mz
			bclr	#0,(a2)
			beq.s	locj_6ED0
			; Draw new tiles on the left
			move.w	#$40,d4
			moveq	#-16,d5
			bsr.w	Calc_VRAM_Pos
			move.w	#$40,d4
			moveq	#-16,d5
			moveq	#3-1,d6
			bsr.w	DrawBlocks_TB_2
	locj_6ED0:
			bclr	#1,(a2)
			beq.s	locj_6EF0
			; Draw new tiles on the right
			move.w	#$40,d4
			move.w	#320,d5
			bsr.w	Calc_VRAM_Pos
			move.w	#$40,d4
			move.w	#320,d5
			moveq	#3-1,d6
			bsr.w	DrawBlocks_TB_2
	locj_6EF0:
			rts
	locj_6EF2:
			dc.b $00,$00,$00,$00,$00,$00,$06,$06,$04,$04,$04,$04,$04,$04,$04,$04
			dc.b $04,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
			dc.b $02,$00
;===============================================================================
	Draw_Mz:
			moveq	#-16,d4
			bclr	#0,(a2)
			bne.s	locj_6F66
			bclr	#1,(a2)
			beq.s	locj_6FAE
			move.w	#224,d4
	locj_6F66:
			lea	(locj_6EF2+1).l,a0
			move.w	(v_bgscreenposy).w,d0
			subi.w	#$200,d0
			add.w	d4,d0
			andi.w	#$7F0,d0
			lsr.w	#4,d0
			move.b	(a0,d0.w),d0
			movea.w	locj_6FE4(pc,d0.w),a3
			beq.s	locj_6F9A
			moveq	#-16,d5
			movem.l	d4/d5,-(sp)
			bsr.w	Calc_VRAM_Pos
			movem.l	(sp)+,d4/d5
			bsr.w	DrawBlocks_LR
			bra.s	locj_6FAE
;===============================================================================
	locj_6F9A:
			moveq	#0,d5
			movem.l	d4/d5,-(sp)
			bsr.w	Calc_VRAM_Pos_2
			movem.l	(sp)+,d4/d5
			moveq	#(512/16)-1,d6
			bsr.w	DrawBlocks_LR_3
	locj_6FAE:
			tst.b	(a2)
			bne.s	locj_6FB4
			rts
;===============================================================================			
	locj_6FB4:
			moveq	#-16,d4
			moveq	#-16,d5
			move.b	(a2),d0
			andi.b	#$A8,d0
			beq.s	locj_6FC8
			lsr.b	#1,d0
			move.b	d0,(a2)
			move.w	#320,d5
	locj_6FC8:
			lea	(locj_6EF2).l,a0
			move.w	(v_bgscreenposy).w,d0
			subi.w	#$200,d0
			andi.w	#$7F0,d0
			lsr.w	#4,d0
			lea	(a0,d0.w),a0
			bra.w	locj_6FEC
;===============================================================================			
	locj_6FE4:
			dc.w v_bgscreenposx_dup, v_bgscreenposx_dup, v_bg2screenposx_dup, v_bg3screenposx_dup
	locj_6FEC:
			moveq	#((224+16+16)/16)-1,d6
			move.l	#$800000,d7
	locj_6FF4:			
			moveq	#0,d0
			move.b	(a0)+,d0
			btst	d0,(a2)
			beq.s	locj_701C
			move.w	locj_6FE4(pc,d0.w),a3
			movem.l	d4/d5/a0,-(sp)
			movem.l	d4/d5,-(sp)
			bsr.w	GetBlockData
			movem.l	(sp)+,d4/d5
			bsr.w	Calc_VRAM_Pos
			bsr.w	DrawBlock
			movem.l	(sp)+,d4/d5/a0
	locj_701C:
			addi.w	#16,d4
			dbf	d6,locj_6FF4
			clr.b	(a2)
			rts			


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Don't be fooled by the name: this function's for drawing from left to right
; when the camera's moving up or down
; DrawTiles_LR:
DrawBlocks_LR:
		moveq	#((320+16+16)/16)-1,d6	; Draw the entire width of the screen + two extra columns
; DrawTiles_LR_2:
DrawBlocks_LR_2:
		move.l	#$800000,d7	; Delta between rows of tiles
		move.l	d0,d1

	@loop:
		movem.l	d4-d5,-(sp)
		bsr.w	GetBlockData
		move.l	d1,d0
		bsr.w	DrawBlock
		addq.b	#4,d1		; Two tiles ahead
		andi.b	#$7F,d1		; Wrap around row
		movem.l	(sp)+,d4-d5
		addi.w	#16,d5		; Move X coordinate one block ahead
		dbf	d6,@loop
		rts
; End of function DrawBlocks_LR

; DrawTiles_LR_3:
DrawBlocks_LR_3:
		move.l	#$800000,d7
		move.l	d0,d1

	@loop:
		movem.l	d4-d5,-(sp)
		bsr.w	GetBlockData_2
		move.l	d1,d0
		bsr.w	DrawBlock
		addq.b	#4,d1
		andi.b	#$7F,d1
		movem.l	(sp)+,d4-d5
		addi.w	#16,d5
		dbf	d6,@loop
		rts	
; End of function DrawBlocks_LR_3


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Don't be fooled by the name: this function's for drawing from top to bottom
; when the camera's moving left or right
; DrawTiles_TB:
DrawBlocks_TB:
		moveq	#((224+16+16)/16)-1,d6	; Draw the entire height of the screen + two extra rows
; DrawTiles_TB_2:
DrawBlocks_TB_2:
		move.l	#$800000,d7	; Delta between rows of tiles
		move.l	d0,d1

	@loop:
		movem.l	d4-d5,-(sp)
		bsr.w	GetBlockData
		move.l	d1,d0
		bsr.w	DrawBlock
		addi.w	#$100,d1	; Two rows ahead
		andi.w	#$FFF,d1	; Wrap around plane
		movem.l	(sp)+,d4-d5
		addi.w	#16,d4		; Move X coordinate one block ahead
		dbf	d6,@loop
		rts	
; End of function DrawBlocks_TB_2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Draws a block's worth of tiles
; Parameters:
; a0 = Pointer to block metadata (block index and X/Y flip)
; a1 = Pointer to block
; a5 = Pointer to VDP command port
; a6 = Pointer to VDP data port
; d0 = VRAM command to access plane
; d2 = VRAM plane A/B specifier
; d7 = Plane row delta
; DrawTiles:
DrawBlock:
		or.w	d2,d0	; OR in that plane A/B specifier to the VRAM command
		swap	d0
		btst	#3,(a0)	; Check Y-flip bit	; MJ: checking bit 3 not 4 (Flip)
		bne.s	DrawFlipY
		btst	#2,(a0)	; Check X-flip bit	; MJ: checking bit 2 not 3 (Flip)
		bne.s	DrawFlipX
		move.l	d0,(a5)
		move.l	(a1)+,(a6)	; Write top two tiles
		add.l	d7,d0		; Next row
		move.l	d0,(a5)
		move.l	(a1)+,(a6)	; Write bottom two tiles
		rts	
; ===========================================================================

DrawFlipX:
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4	; Invert X-flip bits of each tile
		swap	d4		; Swap the tiles around
		move.l	d4,(a6)		; Write top two tiles
		add.l	d7,d0		; Next row
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4
		swap	d4
		move.l	d4,(a6)		; Write bottom two tiles
		rts	
; ===========================================================================

DrawFlipY:
		btst	#2,(a0)		; MJ: checking bit 2 not 3 (Flip)
		bne.s	DrawFlipXY
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$10001000,d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$10001000,d5
		move.l	d5,(a6)
		rts	
; ===========================================================================

DrawFlipXY:
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$18001800,d4
		swap	d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$18001800,d5
		swap	d5
		move.l	d5,(a6)
		rts	
; End of function DrawBlocks

; ===========================================================================


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Gets address of block at a certain coordinate
; Parameters:
; a4 = Pointer to level layout
; d4 = Relative Y coordinate
; d5 = Relative X coordinate
; Returns:
; a0 = Address of block metadata
; a1 = Address of block
; DrawBlocks:
GetBlockData:
		add.w	(a3),d5		; MJ: load X position to d5
GetBlockData_2:
		add.w	4(a3),d4	; MJ: load Y position to d4
		movea.l	(v_16x16).l,a1	; MJ: load Block's location
		; Turn Y coordinate into index into level layout
		move.w	d4,d3		; MJ: copy Y position to d3
		andi.w	#$780,d3	; MJ: get within 780 (Not 380) (E00 pixels (not 700)) in multiples of 80
		; Turn X coordinate into index into level layout
		lsr.w	#3,d5		; MJ: divide X position by 8
		move.w	d5,d0		; MJ: copy to d0
		lsr.w	#4,d0		; MJ: divide by 10 (Not 20)
		andi.w	#$7F,d0		; MJ: get within 7F
		; Get chunk from level layout
		lsl.w	#1,d3		; MJ: multiply by 2 (So it skips the BG)
		add.w	d3,d0		; MJ: add calc'd Y pos
		moveq	#0,d3		; MJ: prepare FFFF in d3 (Prepare 0 for Unc Chunks)
		move.b	(a4,d0.w),d3	; MJ: collect correct chunk ID from layout
		; Turn chunk ID into index into chunk table
		andi.w	#$FF,d3		; MJ: keep within FF
		lsl.w	#7,d3		; MJ: multiply by 80
		; Turn Y coordinate into index into chunk
		andi.w	#$70,d4		; MJ: keep Y pos within 80 pixels
		; Turn X coordinate into index into chunk
		andi.w	#$E,d5		; MJ: keep X pos within 10
		; Get block metadata from chunk
		add.w	d4,d3		; MJ: add calc'd Y pos to ror'd d3
		add.w	d5,d3		; MJ: add calc'd X pos to ror'd d3

		add.l	(v_128x128).l,d3 ; Unc Chunks

		movea.l	d3,a0		; MJ: set address (Chunk to read)
		move.w	(a0),d3
		; Turn block ID into address
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		adda.w	d3,a1

locret_6C1E:
		rts	
; End of function GetBlockData


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Produces a VRAM plane access command from coordinates
; Parameters:
; d4 = Relative Y coordinate
; d5 = Relative X coordinate
; Returns VDP command in d0
Calc_VRAM_Pos:
		add.w	(a3),d5
Calc_VRAM_Pos_2:
		add.w	4(a3),d4
		; Floor the coordinates to the nearest pair of tiles (the size of a block).
		; Also note that this wraps the value to the size of the plane:
		; The plane is 64*8 wide, so wrap at $100, and it's 32*8 tall, so wrap at $200
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
		; Transform the adjusted coordinates into a VDP command
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#3,d0	; Highest bits of plane VRAM address
		swap	d0
		move.w	d4,d0
		rts	
; End of function Calc_VRAM_Pos


; ---------------------------------------------------------------------------
; Subroutine to	load tiles as soon as the level	appears
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesFromStart:
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(v_screenposx).w,a3
		movea.l	(v_lvllayoutfg).w,a4	; MJ: Load address of layout
		move.w	#$4000,d2
		bsr.s	DrawChunks
		lea	(v_bgscreenposx).w,a3
		movea.l	(v_lvllayoutbg).w,a4	; MJ: Load address of layout BG
		move.w	#$6000,d2
		tst.b	(v_zone).w
		beq.w	Draw_GHz_Bg
		cmpi.b	#id_MZ,(v_zone).w
		beq.w	Draw_Mz_Bg
		cmpi.w	#(id_SBZ<<8)+0,(v_zone).w
		beq.w	Draw_SBz_Bg
		cmpi.b	#id_EndZ,(v_zone).w
		beq.w	Draw_GHz_Bg
; End of function LoadTilesFromStart


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawChunks:
		moveq	#-16,d4
		moveq	#((224+16+16)/16)-1,d6

	@loop:
		movem.l	d4-d6,-(sp)
		moveq	#0,d5
		move.w	d4,d1
		bsr.w	Calc_VRAM_Pos
		move.w	d1,d4
		moveq	#0,d5
		moveq	#(512/16)-1,d6
		bsr.w	DrawBlocks_LR_2
		movem.l	(sp)+,d4-d6
		addi.w	#16,d4
		dbf	d6,@loop
		rts	
; End of function DrawChunks

	Draw_GHz_Bg:
			moveq	#0,d4
			moveq	#((224+16+16)/16)-1,d6
	locj_7224:			
			movem.l	d4-d6,-(sp)
			lea	(locj_724a),a0
			move.w	(v_bgscreenposy).w,d0
			add.w	d4,d0
			andi.w	#$F0,d0
			bsr.w	locj_72Ba
			movem.l	(sp)+,d4-d6
			addi.w	#16,d4
			dbf	d6,locj_7224
			rts
	locj_724a:
			dc.b $00,$00,$00,$00,$06,$06,$06,$04,$04,$04,$00,$00,$00,$00,$00,$00
;-------------------------------------------------------------------------------
	Draw_Mz_Bg:;locj_725a:
			moveq	#-16,d4
			moveq	#((224+16+16)/16)-1,d6
	locj_725E:			
			movem.l	d4-d6,-(sp)
			lea	(locj_6EF2+1),a0
			move.w	(v_bgscreenposy).w,d0
			subi.w	#$200,d0
			add.w	d4,d0
			andi.w	#$7F0,d0
			bsr.w	locj_72Ba
			movem.l	(sp)+,d4-d6
			addi.w	#16,d4
			dbf	d6,locj_725E
			rts
;-------------------------------------------------------------------------------
	Draw_SBz_Bg:;locj_7288:
			moveq	#-16,d4
			moveq	#((224+16+16)/16)-1,d6
	locj_728C:			
			movem.l	d4-d6,-(sp)
			lea	(locj_6DF4+1),a0
			move.w	(v_bgscreenposy).w,d0
			add.w	d4,d0
			andi.w	#$1F0,d0
			bsr.w	locj_72Ba
			movem.l	(sp)+,d4-d6
			addi.w	#16,d4
			dbf	d6,locj_728C
			rts
;-------------------------------------------------------------------------------
	locj_72B2:
			dc.w v_bgscreenposx, v_bgscreenposx, v_bg2screenposx, v_bg3screenposx
	locj_72Ba:
			lsr.w	#4,d0
			move.b	(a0,d0.w),d0
			movea.w	locj_72B2(pc,d0.w),a3
			beq.s	locj_72da
			moveq	#-16,d5
			movem.l	d4/d5,-(sp)
			bsr.w	Calc_VRAM_Pos
			movem.l	(sp)+,d4/d5
			bsr.w	DrawBlocks_LR
			bra.s	locj_72EE
	locj_72da:
			moveq	#0,d5
			movem.l	d4/d5,-(sp)
			bsr.w	Calc_VRAM_Pos_2
			movem.l	(sp)+,d4/d5
			moveq	#(512/16)-1,d6
			bsr.w	DrawBlocks_LR_3
	locj_72EE:
			rts

; ---------------------------------------------------------------------------
; Subroutine to load level art patterns
; ---------------------------------------------------------------------------
 
; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
LoadLevelArt:
        move.w  d0,-(sp)        			; store level ID to stack
        lsl.w   #2,d0           			; shift 2 bits left
        move.l  LLA_ArtList(pc,d0.w),a0 	; get correct entry from art file list
 
        move.l  #$40000000,d4       		; set "VRAM Write to $0000"
        bsr.w   LoadCompArt     			; load comper compressed art
        move.w  (sp)+,d0        			; get old level ID from stack again
        rts          		    			; return to subroutine
 
        ; list of art patterns used in levels
LLA_ArtList:    dc.l LvlArt_GHZ, LvlArt_LZ, LvlArt_MZ, LvlArt_SLZ, LvlArt_SYZ, LvlArt_SBZ, LvlArt_GHZ, LvlArt_BZ, LvlArt_JZ, LvlArt_SKBZ, LvlArt_SBZ3

; ---------------------------------------------------------------------------
; Subroutine to load basic level data
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevelDataLoad:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		cmpi.w	#(id_LZ<<8)+3,(v_zone).w	; is level SBZ3 (LZ4) ?
		bne.s	@notSB3Art					; if not, branch
		moveq	#SBZ3_Art,d0				; use SBZ3 art

	@notSB3Art:
		bsr.s   LoadLevelArt		; load level tiles
		lsl.w	#4,d0
		lea		(LevelHeaders).l,a2
		lea		(a2,d0.w),a2
		move.l	a2,-(sp)
		addq.l	#4,a2

		move.l	(a2)+,(v_16x16).l	; store the ROM address for the block mappings
		andi.l	#$FFFFFF,(v_16x16).l

		move.l	(a2)+,(v_128x128).l	; store the ROM address for the chunk mappings
		bsr.w	LevelLayoutLoad

; LOAD LEVEL PALETTE ; SETS PALETTE BASED ON DIFFICULTY
		moveq	#0,d0
		move.b	(a2),d0				; load palette ID byte
		cmpi.w	#(id_LZ<<8)+3,(v_zone).w ; is level SBZ3 (LZ4) ?
		bne.s	@notSBZ3	; if not, branch
		moveq	#palid_SBZ3,d0	; use SB3 palette

	@notSBZ3:
		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w ; is level SBZ2?
		beq.s	@isSBZorFZ	; if yes, branch
		cmpi.w	#(id_SBZ<<8)+2,(v_zone).w ; is level FZ?
		bne.s	@normalpal	; if not, branch

	@isSBZorFZ:
		moveq	#palid_SBZ2,d0	; use SBZ2/FZ palette

	@normalpal:
		add.b	(v_difficulty).w,d0	; set palette based on difficulty (SHOULD BE +1 for easy mode, +2 for hard mode)
		bsr.w	PalLoad1	; load palette (based on d0)

		movea.l	(sp)+,a2
		addq.w	#4,a2		; read number for 2nd PLC
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	@skipPLC	; if 2nd PLC is 0 (i.e. the ending sequence), branch
		bsr.w	AddPLC		; load pattern load cues

	@skipPLC:
		rts	
; End of function LevelDataLoad
; ===========================================================================

; ---------------------------------------------------------------------------
; Level	layout loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; This method now releases free ram space from A408 - A7FF

LevelLayoutLoad:
		move.b	(v_zone).w,d0
		lsl.l	#6,d0					; zones are separated in multiples of $80
		move.b	(v_act).w,d1
		lsl.b	#4,d1					; acts are separated in multiples of $20
		add.b	d1,d0
		move.b	(v_difficulty).w,d1
		lsl.b	#2,d1					; difficulties are separated in multiples of 8
		add.b	d1,d0
		lea	(Level_Index).l,a1
		movea.l	(a1,d0.w),a1		; MJ: moving the address strait to a1 rather than adding a word to an address
		move.l	a1,(v_lvllayoutfg).w	; MJ: save location of layout to $FFFFA400
		lea	$80(a1),a1		; MJ: add 80 (As the BG line is always after the FG line)
		move.l	a1,(v_lvllayoutbg).w	; MJ: save location of layout to $FFFFA404
		rts				; MJ: Return
; End of function LevelLayoutLoad

		include	"_inc\DynamicLevelEvents.asm"

		include	"_incObj\11 Bridge (part 1).asm"

; ---------------------------------------------------------------------------
; Platform subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

PlatformObject:
		lea		(v_player).w,a1
		tst.w	obVelY(a1)	; is Sonic moving up/jumping?
		bmi.w	Plat_Exit	; if yes, branch

;		perform x-axis range check
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Plat_Exit
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.w	Plat_Exit

	Plat_NoXCheck:
		move.w	obY(a0),d0
		subq.w	#8,d0

Platform3:
;		perform y-axis range check
		move.w	obY(a1),d2
		move.b	obHeight(a1),d1
		ext.w	d1
		add.w	d2,d1
		addq.w	#4,d1
		sub.w	d1,d0
		bhi.w	Plat_Exit
		cmpi.w	#-$10,d0
		blo.w	Plat_Exit

		tst.b	(f_lockmulti).w
		bmi.w	Plat_Exit
		cmpi.b	#6,obRoutine(a1)
		bhs.w	Plat_Exit
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,obY(a1)
		addq.b	#2,obRoutine(a0)

loc_74AE:
		btst	#3,obStatus(a1)
		beq.s	loc_74DC
		moveq	#0,d0
		move.b	$3D(a1),d0
		lsl.w	#6,d0
		addi.l	#v_objspace&$FFFFFF,d0
		movea.l	d0,a2
		bclr	#3,obStatus(a2)
		clr.b	ob2ndRout(a2)
		cmpi.b	#4,obRoutine(a2)
		bne.s	loc_74DC
		subq.b	#2,obRoutine(a2)

loc_74DC:
		move.w	a0,d0
		subi.w	#-$3000,d0
		lsr.w	#6,d0
		andi.w	#$7F,d0
		move.b	d0,$3D(a1)
		move.b	#0,obAngle(a1)
		move.w	#0,obVelY(a1)
		move.w	obVelX(a1),obInertia(a1)
		btst	#1,obStatus(a1)
		beq.s	loc_7512
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	(Sonic_ResetOnFloor).l
		movea.l	(sp)+,a0

loc_7512:
		bset	#3,obStatus(a1)
		bset	#3,obStatus(a0)

Plat_Exit:
		rts	
; End of function PlatformObject

; ---------------------------------------------------------------------------
; Sloped platform subroutine (GHZ collapsing ledges and	SLZ seesaws)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SlopeObject:
		lea	(v_player).w,a1
		tst.w	obVelY(a1)
		bmi.w	Plat_Exit
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	Plat_Exit
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.s	Plat_Exit
		btst	#0,obRender(a0)
		beq.s	loc_754A
		not.w	d0
		add.w	d1,d0

loc_754A:
		lsr.w	#1,d0
		moveq	#0,d3
		move.b	(a2,d0.w),d3
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	Platform3
; End of function SlopeObject


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Swing_Solid:
		lea	(v_player).w,a1
		tst.w	obVelY(a1)
		bmi.w	Plat_Exit
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Plat_Exit
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.w	Plat_Exit
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.w	Platform3
; End of function Obj15_Solid

; ===========================================================================

		include	"_incObj\11 Bridge (part 2).asm"

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk or jump off	a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ExitPlatform:
		move.w	d1,d2

ExitPlatform2:
		add.w	d2,d2
		lea		(v_player).w,a1
		btst	#1,obStatus(a1)
		bne.s	loc_75E0
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_75E0
		cmp.w	d2,d0
		blo.s	locret_75F2

loc_75E0:
		bclr	#3,obStatus(a1)
		move.b	#2,obRoutine(a0)
		bclr	#3,obStatus(a0)

locret_75F2:
		rts	
; End of function ExitPlatform

		include	"_incObj\11 Bridge (part 3).asm"

		include	"_incObj\15 Swinging Platforms (part 1).asm"

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's position with a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MvSonicOnPtfm:
		lea	(v_player).w,a1
		move.w	obY(a0),d0
		sub.w	d3,d0
		bra.s	MvSonic2
; End of function MvSonicOnPtfm

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's position with a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MvSonicOnPtfm2:
		lea	(v_player).w,a1
		move.w	obY(a0),d0
		subi.w	#9,d0

MvSonic2:
		tst.b	(f_lockmulti).w
		bmi.s	locret_7B62
		cmpi.b	#6,(v_player+obRoutine).w
		bhs.s	locret_7B62
		tst.w	(v_debuguse).w
		bne.s	locret_7B62
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		sub.w	obX(a0),d2
		sub.w	d2,obX(a1)

locret_7B62:
		rts	
; End of function MvSonicOnPtfm2

		include	"_incObj\15 Swinging Platforms (part 2).asm"

		include	"_incObj\17 Spiked Pole Helix.asm"

		include	"_incObj\18 Platforms.asm"
		include	"_incObj\19.asm"

		include	"_incObj\1A Collapsing Ledge (part 1).asm"
		include	"_incObj\53 Collapsing Floors.asm"

; ===========================================================================

Ledge_Fragment:
		clr.b	ledge_collapse_flag(a0)

loc_847A:
		lea		(CFlo_Data1).l,a4
		moveq	#$18,d1
		addq.b	#2,obFrame(a0)

loc_8486:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		add.w	d0,d0
		movea.l	obMap(a0),a3
		adda.w	(a3,d0.w),a3
		addq.w	#1,a3
		bset	#5,obRender(a0)
		move.b	obID(a0),d4
		move.b	obRender(a0),d5
		movea.l	a0,a1
; SpirituInsanum Fix. Similar to what was applied to Lost Rings
		move.b	#6,obRoutine(a1)
		move.b	d4,obID(a1)
		move.l	a3,obMap(a1)
		move.b	d5,obRender(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.w	obPriority(a0),obPriority(a1)
		move.b	obActWid(a0),obActWid(a1)
		move.b	(a4)+,ledge_timedelay(a1)
		; Now since we created one object already, we have to decrease the counter
		subq.w	#1,d1
		; Here we begin what's replacing SingleObjLoad, in order to avoid resetting its d0 every time an object is created.
		lea		(v_lvlobjspace).w,a1
		move.w	#$5F,d0
; ===========================================================================

loc_84AA:
		;bsr.w	FindFreeObj - REMOVE THIS. It's the routine that causes such slowdown
		; We'll just copy/paste the content of loc_DA94 and correct the branches.
	@loop:
		tst.b	(a1)
		beq.s	@cont		; Let's correct the branches. Here we can also skip the bne that was originally after bsr.w FindFreeObj because we already know there's a free object slot in memory.
		lea		$40(a1),a1
		dbf		d0,@loop	; Branch correction again.
		bne.s	loc_84F2	; We're moving this line here.
	@cont:
	; And that's it, copy/paste complete.
		addq.w	#5,a3

loc_84B2:
		move.b	#6,obRoutine(a1)
		move.b	d4,obID(a1)
		move.l	a3,obMap(a1)
		move.b	d5,obRender(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.w	obPriority(a0),obPriority(a1)
		move.b	obActWid(a0),obActWid(a1)
		move.b	(a4)+,ledge_timedelay(a1)
		;cmpa.l	a0,a1                     ; Finally, this isn't necessary anymore, its only purpose was to skip DisplaySprite2 on the first object
		;bhs.s	loc_84EE
		bsr.w	DisplaySprite1

loc_84EE:
		dbf	d1,loc_84AA

loc_84F2:
		bsr.w	DisplaySprite
		sfx		sfx_Collapse,1,0,0	; play collapsing sound
; ===========================================================================
; ---------------------------------------------------------------------------
; Disintegration data for collapsing ledges (MZ, SLZ, SBZ)
; ---------------------------------------------------------------------------
CFlo_Data1:	dc.b $1C, $18, $14, $10, $1A, $16, $12,	$E, $A,	6, $18,	$14, $10, $C, 8, 4
		dc.b $16, $12, $E, $A, 6, 2, $14, $10, $C, 0
CFlo_Data2:	dc.b $1E, $16, $E, 6, $1A, $12,	$A, 2
CFlo_Data3:	dc.b $16, $1E, $1A, $12, 6, $E,	$A, 2

; ---------------------------------------------------------------------------
; Sloped platform subroutine (GHZ collapsing ledges and	MZ platforms)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SlopeObject2:
		lea	(v_player).w,a1
		btst	#3,obStatus(a1)
		beq.s	locret_856E
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		lsr.w	#1,d0
		btst	#0,obRender(a0)
		beq.s	loc_854E
		not.w	d0
		add.w	d1,d0

loc_854E:
		moveq	#0,d1
		move.b	(a2,d0.w),d1
		move.w	obY(a0),d0
		sub.w	d1,d0
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		sub.w	obX(a0),d2
		sub.w	d2,obX(a1)

locret_856E:
		rts	
; End of function SlopeObject2

; ===========================================================================
; ---------------------------------------------------------------------------
; Collision data for GHZ collapsing ledge
; ---------------------------------------------------------------------------
Ledge_SlopeData:
		incbin	"misc\GHZ Collapsing Ledge Heightmap.bin"
		even


		include	"_incObj\1C Scenery.asm"

		include	"_incObj\1D Unused Switch.asm"

		include	"_incObj\2A SBZ Small Door.asm"



; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj44_SolidWall:
		bsr.w	Obj44_SolidWall2
		beq.s	loc_8AA8
		bmi.w	loc_8AC4
		tst.w	d0
		beq.w	loc_8A92
		bmi.s	loc_8A7C
		tst.w	obVelX(a1)
		bmi.s	loc_8A92
		bra.s	loc_8A82
; ===========================================================================

loc_8A7C:
		tst.w	obVelX(a1)
		bpl.s	loc_8A92

loc_8A82:
		sub.w	d0,obX(a1)
		move.w	#0,obInertia(a1)
		move.w	#0,obVelX(a1)

loc_8A92:
		btst	#1,obStatus(a1)
		bne.s	loc_8AB6
		bset	#5,obStatus(a1)
		bset	#5,obStatus(a0)
		rts	
; ===========================================================================

loc_8AA8:
		btst	#5,obStatus(a0)
		beq.s	locret_8AC2

loc_8AB6:
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)

locret_8AC2:
		rts	
; ===========================================================================

loc_8AC4:
		tst.w	obVelY(a1)
		bpl.s	locret_8AD8
		tst.w	d3
		bpl.s	locret_8AD8
		sub.w	d3,obY(a1)
		move.w	#0,obVelY(a1)

locret_8AD8:
		rts	
; End of function Obj44_SolidWall


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj44_SolidWall2:
		lea	(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_8B48
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.s	loc_8B48
		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	obY(a1),d3

		cmpi.b	#aniID_SpinDash,obAnim(a1)
		beq.s	@short
		cmpi.b	#aniID_Duck,obAnim(a1)
		bne.s	@skip
		
	@short:
		subi.w	#5,d2
		addi.w	#5,d3
		
	@skip:
		sub.w	obY(a0),d3
		add.w	d2,d3
		bmi.s	loc_8B48
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bhs.s	loc_8B48
		tst.b	(f_lockmulti).w
		bmi.s	loc_8B48
		cmpi.b	#6,(v_player+obRoutine).w
		bhs.s	loc_8B48
		tst.w	(v_debuguse).w
		bne.s	loc_8B48
		move.w	d0,d5
		cmp.w	d0,d1
		bhs.s	loc_8B30
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5

loc_8B30:
		move.w	d3,d1
		cmp.w	d3,d2
		bhs.s	loc_8B3C
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

loc_8B3C:
		cmp.w	d1,d5
		bhi.s	loc_8B44
		moveq	#1,d4
		rts	
; ===========================================================================

loc_8B44:
		moveq	#-1,d4
		rts	
; ===========================================================================

loc_8B48:
		moveq	#0,d4
		rts	
; End of function Obj44_SolidWall2

; ===========================================================================

		include	"_incObj\1E Ball Hog.asm"

		include	"_incObj\20 Cannonball.asm"

		include	"_incObj\24, 27 & 3F Explosions.asm"

		include	"_incObj\28 Animals.asm"

		include	"_incObj\29 Points.asm"

		include	"_incObj\1F Crabmeat.asm"

		include	"_incObj\22 Buzz Bomber.asm"

		include	"_incObj\23 Buzz Bomber Missile.asm"

		include	"_incObj\25 & 37 Rings.asm"

		include	"_incObj\4B Giant Ring.asm"

		include	"_incObj\7C Ring Flash.asm"

		include	"_incObj\26 Monitor.asm"

		include	"_incObj\2E Monitor Content Power-Up.asm"

		include	"_incObj\26 Monitor (SolidSides subroutine).asm"

		include	"_incObj\0E Title Screen Sonic.asm"

		include	"_incObj\0F Press Start and TM.asm"

		include	"_incObj\sub AnimateSprite.asm"

		include	"_incObj\2B Chopper.asm"

		include	"_incObj\2C Jaws.asm"

		include	"_incObj\2D Burrobot.asm"

		include	"_incObj\2F MZ Large Grassy Platforms.asm"

		include	"_incObj\35 Burning Grass.asm"

		include	"_incObj\30 MZ Large Green Glass Blocks.asm"

		include	"_incObj\31 Chained Stompers.asm"

		include	"_incObj\45 Sideways Stomper.asm"

		include	"_incObj\32 Button.asm"

		include	"_incObj\33 Pushable Blocks.asm"

		include	"_incObj\34 Title Cards.asm"

		include	"_incObj\39 Game Over.asm"

		include	"_incObj\3A Got Through Card.asm"

		include	"_incObj\7E Special Stage Results.asm"

		include	"_incObj\7F SS Result Chaos Emeralds.asm"

		include	"_incObj\36 Spikes.asm"

		include	"_incObj\3B Purple Rock.asm"

		include	"_incObj\49 Waterfall Sound.asm"

		include	"_incObj\3C Smashable Wall.asm"

		include	"_incObj\sub SmashObject.asm"

; ===========================================================================
; Smashed block	fragment speeds
;
Smash_FragSpd1:	dc.w $400, -$500	; x-move speed,	y-move speed
		dc.w $600, -$100
		dc.w $600, $100
		dc.w $400, $500
		dc.w $600, -$600
		dc.w $800, -$200
		dc.w $800, $200
		dc.w $600, $600

Smash_FragSpd2:	dc.w -$600, -$600
		dc.w -$800, -$200
		dc.w -$800, $200
		dc.w -$600, $600
		dc.w -$400, -$500
		dc.w -$600, -$100
		dc.w -$600, $100
		dc.w -$400, $500

; ---------------------------------------------------------------------------
; Object code execution subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ExecuteObjects:
		lea	(v_objspace).w,a0 ; set address for object RAM
		moveq	#$7F,d7
		moveq	#0,d0
;Objects do not freeze when dying

loc_D348:
		move.b	(a0),d0		; load object number from RAM
		beq.s	loc_D358
		add.w	d0,d0
		add.w	d0,d0
		movea.l	Obj_Index-4(pc,d0.w),a1
		jsr		(a1)		; run the object's code
		moveq	#0,d0

loc_D358:
		lea		$40(a0),a0	; next object
		dbf		d7,loc_D348
		rts	
; ===========================================================================
; Freezes objects
loc_D362:
		cmpi.b  #$A,(v_player+obRoutine).w      ; Has Sonic drowned?
		beq.s   loc_D348                        ; If so, run objects a little longer
		moveq	#$1F,d7
		bsr.s	loc_D348
		moveq	#$5F,d7

loc_D368:
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	loc_D378
		tst.b	obRender(a0)
		bpl.s	loc_D378
		bsr.w	DisplaySprite

loc_D378:
		lea	$40(a0),a0

loc_D37C:
		dbf	d7,loc_D368
		rts	
; End of function ExecuteObjects

; ===========================================================================
; ---------------------------------------------------------------------------
; Object pointers
; ---------------------------------------------------------------------------
Obj_Index:
		include	"_inc\Object Pointers.asm"

		include	"_incObj\sub ObjectFall.asm"

		include	"_incObj\sub SpeedToPos.asm"

		include	"_incObj\sub DisplaySprite.asm"

		include	"_incObj\sub DeleteObject.asm"

		include "_inc\BuildSprites.asm"

		include	"_inc\RingsManager.asm"

		include "_inc\BuildHUD.asm"

		include	"_incObj\sub ChkObjectVisible.asm"

		include	"_inc\Object Manager.asm"

		include	"_incObj\sub FindFreeObj.asm"

		include	"_incObj\41 Springs.asm"

		include	"_incObj\42 Newtron.asm"

		include	"_incObj\43 Roller.asm"

		include	"_incObj\44 GHZ Edge Walls.asm"

		include	"_incObj\13 Lava Ball Maker.asm"

		include	"_incObj\14 Lava Ball.asm"

		include	"_incObj\6D Flamethrower.asm"

		include	"_incObj\46 MZ Bricks.asm"

		include	"_incObj\12 Light.asm"

		include	"_incObj\47 Bumper.asm"

		include	"_incObj\0D Signpost.asm" ; includes "GotThroughAct" subroutine

		include	"_incObj\4C & 4D Lava Geyser Maker.asm"

		include	"_incObj\4E Wall of Lava.asm"

		include	"_incObj\54 Lava Tag.asm"

		include	"_incObj\40 Moto Bug.asm" ; includes "_incObj\sub RememberState.asm"

		include	"_incObj\50 Yadrin.asm"

		include	"_incObj\sub SolidObject.asm"

		include	"_incObj\51 Smashable Green Block.asm"

		include	"_incObj\52 Moving Blocks.asm"

		include	"_incObj\55 Basaran.asm"

		include	"_incObj\56 Floating Blocks and Doors.asm"

		include	"_incObj\57 Spiked Ball and Chain.asm"

		include	"_incObj\58 Big Spiked Ball.asm"

		include	"_incObj\59 SLZ Elevators.asm"

		include	"_incObj\5A SLZ Circling Platform.asm"

		include	"_incObj\5B Staircase.asm"

		include	"_incObj\5C Pylon.asm"

		include	"_incObj\1B Water Surface.asm"

		include	"_incObj\0B Pole that Breaks.asm"

		include	"_incObj\0C Flapping Door.asm"

		include	"_incObj\71 Invisible Barriers.asm"

		include	"_incObj\5D Fan.asm"

		include	"_incObj\5E Seesaw.asm"

		include	"_incObj\5F Bomb Enemy.asm"

		include	"_incObj\60 Orbinaut.asm"

		include	"_incObj\16 Harpoon.asm"

		include	"_incObj\61 LZ Blocks.asm"

		include	"_incObj\62 Gargoyle.asm"

		include	"_incObj\63 LZ Conveyor.asm"

		include	"_incObj\64 Bubbles.asm"

		include	"_incObj\65 Waterfalls.asm"

		include "_incObj\Sonic Effects.asm"

		include "_players\00 Sonic.asm"

		include "_incObj\sub ApplySpeedSettings.asm"

		include	"_incObj\0A Drowning Countdown.asm"

		include "_incObj\sub ResumeMusic.asm"

		include	"_incObj\38 Shield and Invincibility.asm"

		include	"_incObj\4A Special Stage Entry (Unused).asm"

		include	"_incObj\03 Collision Switcher.asm"

		include	"_incObj\08 Water Splash.asm"

		include	"_players\Player AnglePos.asm"

		include	"_incObj\sub FindNearestTile.asm"

		include	"_incObj\sub FindFloor.asm"

		include	"_incObj\sub FindWall.asm"

; ---------------------------------------------------------------------------
; Subroutine to calculate how much space is in front of the player on the ground
; d0 = some input angle
; d1 = output about how many pixels (up to some high enough amount)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CalcRoomInFront:
		move.l	(v_colladdr1).w,(v_collindex).w		; MJ: load first collision data location
		cmpi.b	#$C,(v_top_solid_bit).w			; MJ: is second collision set to be used?
		beq.s	@first					; MJ: if not, branch
		move.l	(v_colladdr2).w,(v_collindex).w		; MJ: load second collision data location
@first:
		move.b	(v_lrb_solid_bit).w,d5			; MJ: load L/R/B soldity bit
		move.l	obX(a0),d3
		move.l	obY(a0),d2
		move.w	obVelX(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d3
		move.w	obVelY(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d2
		swap	d2
		swap	d3
		move.b	d0,(v_anglebuffer).w
		move.b	d0,($FFFFF76A).w
		move.b	d0,d1
		addi.b	#$20,d0
		bpl.s	loc_14D1A
		move.b	d1,d0
		bpl.s	loc_14D14
		subq.b	#1,d0

loc_14D14:
		addi.b	#$20,d0
		bra.s	loc_14D24
; ===========================================================================

loc_14D1A:
		move.b	d1,d0
		bpl.s	loc_14D20
		addq.b	#1,d0

loc_14D20:
		addi.b	#$1F,d0

loc_14D24:
		andi.b	#$C0,d0
		beq.w	loc_14DF0
		cmpi.b	#$80,d0
		beq.w	CheckCeilingDist_Part2
		andi.b	#$38,d1
		bne.s	loc_14D3C
		addq.w	#8,d2

loc_14D3C:
		cmpi.b	#$40,d0
		beq.w	loc_1504A
		bra.w	loc_14EBC

; End of function CalcRoomInFront

; ---------------------------------------------------------------------------
; Subroutine to calculate how much space is empty above Sonic's head
; d0 = input angle perpendicular to the spine
; d1 = output about how many pixels are overhead (up to some high enough amount)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CalcRoomOverHead: ; sub_14D48:
		move.l	(v_colladdr1).w,(v_collindex).w		; MJ: load first collision data location
		cmpi.b	#$C,(v_top_solid_bit).w			; MJ: is second collision set to be used?
		beq.s	@first					; MJ: if not, branch
		move.l	(v_colladdr2).w,(v_collindex).w		; MJ: load second collision data location
@first:
		move.b	(v_lrb_solid_bit).w,d5			; MJ: load L/R/B soldity bit
		move.b	d0,(v_anglebuffer).w
		move.b	d0,($FFFFF76A).w
		addi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	CheckLeftCeilingDist
		cmpi.b	#$80,d0
		beq.w	Sonic_CheckCeiling
		cmpi.b	#$C0,d0
		beq.w	CheckRightCeilingDist

; End of function CalcRoomOverHead

; ---------------------------------------------------------------------------
; Subroutine to check if Sonic/Tails is near the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_CheckFloor: ;Sonic_HitFloor:
		move.l	(v_colladdr1).w,(v_collindex).w		; MJ: load first collision data location
		cmpi.b	#$C,(v_top_solid_bit).w			; MJ: is second collision set to be used?
		beq.s	@first					; MJ: if not, branch
		move.l	(v_colladdr2).w,(v_collindex).w		; MJ: load second collision data location
@first:
		move.b	(v_top_solid_bit).w,d5			; MJ: load L/R/B soldity bit
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor	; MJ: check solidity
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	($FFFFF76A).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor	; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#0,d2

loc_14DD0:
		move.b	($FFFFF76A).w,d3
		cmp.w	d0,d1
		ble.s	loc_14DDE
		move.b	(v_anglebuffer).w,d3
		exg	d0,d1

loc_14DDE:
		btst	#0,d3
		beq.s	locret_14DE6
		move.b	d2,d3

locret_14DE6:
		rts
; End of function Sonic_CheckFloor
; ===========================================================================

loc_14DF0:
		addi.w	#$A,d2
		lea	(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor	; MJ: check solidity
		move.b	#0,d2

loc_14E0A:
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	locret_14E16
		move.b	d2,d3

locret_14E16:
		rts	

		include	"_incObj\sub ObjFloorDist.asm"


; ---------------------------------------------------------------------------
; Stores a distance to the nearest wall above Sonic/Tails,
; where "above" = right, into d1
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

;sub_14E50:
CheckRightCeilingDist:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall	; MJ: check solidity
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF76A).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall	; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#-$40,d2
		bra.w	loc_14DD0

; End of function CheckRightCeilingDist


; ---------------------------------------------------------------------------
; Stores a distance to the nearest wall on the right of Sonic/Tails into d1
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Checks a 16x16 block to find solid walls. May check an additional
; 16x16 block up for walls.
; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
; returns relevant block ID in (a1)
; returns distance in d1
; returns angle in d3, or zero if angle was odd
;sub_14EB4:
CheckRightWallDist:
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_14EBC:
		addi.w	#$A,d3
		lea	(v_anglebuffer).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall	; MJ: check solidity
		move.b	#-$40,d2
		bra.w	loc_14E0A

; End of function CheckRightWallDist

; ---------------------------------------------------------------------------
; Subroutine to	detect when an object hits a wall to its right
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitWallRight:
		add.w	obX(a0),d3
		move.w	obY(a0),d2
		lea	(v_anglebuffer).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5		; MJ: set solid type to check
		bsr.w	FindWall	; MJ: check solidity
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	locret_14F06
		move.b	#-$40,d3

locret_14F06:
		rts	

; End of function ObjHitWallRight

; ---------------------------------------------------------------------------
; Stores a distance from Sonic/Tails to the nearest ceiling into d1
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_CheckCeiling: ;Sonic_DontRunOnWalls:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(v_anglebuffer).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6	; MJ: $1000/2
		bsr.w	FindFloor	; MJ: check solidity
		move.w	d1,-(sp)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	($FFFFF76A).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6	; MJ: $1000/2
		bsr.w	FindFloor	; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#-$80,d2
		bra.w	loc_14DD0
; End of function Sonic_CheckCeiling

; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Checks a 16x16 block to find solid ceiling. May check an additional
; 16x16 block up for ceilings.
; d2 = y_pos
; d3 = x_pos
; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
; returns relevant block ID in (a1)
; returns distance in d1
; returns angle in d3, or zero if angle was odd

CheckCeilingDist_Part2: ;loc_14F7C:
		subi.w	#$A,d2
		eori.w	#$F,d2
		lea	(v_anglebuffer).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6	; MJ: $1000/2
		bsr.w	FindFloor	; MJ: check solidity
		move.b	#-$80,d2
		bra.w	loc_14E0A

; ---------------------------------------------------------------------------
; Stores a distance to the nearest wall above the object into d1
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


;ObjHitCeiling:
ObjCheckCeilingDist:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		lea	(v_anglebuffer).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6	; MJ: $1000/2
		moveq	#$D,d5		; MJ: set solid type to check
		bsr.w	FindFloor	; MJ: check solidity
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	locret_14FD4
		move.b	#-$80,d3

locret_14FD4:
		rts	
; End of function ObjCheckCeilingDist

; ===========================================================================

; ---------------------------------------------------------------------------
; Stores a distance to the nearest wall above Sonic/Tails,
; where "above" = left, into d1
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

;loc_14FD6:
CheckLeftCeilingDist:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea		(v_anglebuffer).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6	; MJ: $800/2
		bsr.w	FindWall	; MJ: check solidity
		move.w	d1,-(sp)

		move.w	obY(a0),d2
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obWidth(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea		($FFFFF76A).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6	; MJ: $800/2
		bsr.w	FindWall	; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#$40,d2
		bra.w	loc_14DD0

; ---------------------------------------------------------------------------
; Stores a distance to the nearest wall on the left of Sonic/Tails into d1
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Checks a 16x16 block to find solid walls. May check an additional
; 16x16 block up for walls.
; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
; returns relevant block ID in (a1)
; returns distance in d1
; returns angle in d3, or zero if angle was odd
; Sonic_HitWall:
CheckLeftWallDist:
		move.w	obY(a0),d2
		move.w	obX(a0),d3

loc_1504A:
		subi.w	#$A,d3
		eori.w	#$F,d3
		lea		(v_anglebuffer).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6	; MJ: $800/2
		bsr.w	FindWall	; MJ: check solidity
		move.b	#$40,d2
		bra.w	loc_14E0A
; End of function Sonic_HitWall

; ---------------------------------------------------------------------------
; Subroutine to	detect when an object hits a wall to its left
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitWallLeft:
		add.w	obX(a0),d3
		move.w	obY(a0),d2
		; Engine bug: colliding with left walls is erratic with this function.
		; The cause is this: a missing instruction to flip collision on the found
		; 16x16 block; this one:
		eori.w	#$F,d3
		lea	(v_anglebuffer).w,a4
		move.b	#0,(a4)
		movea.w	#-$10,a3
		move.w	#$400,d6	; MJ: $800/2
		moveq	#$D,d5		; MJ: set solid type to check
		bsr.w	FindWall	; MJ: check solidity
		move.b	(v_anglebuffer).w,d3
		btst	#0,d3
		beq.s	locret_15098
		move.b	#$40,d3

locret_15098:
		rts	
; End of function ObjHitWallLeft

; ===========================================================================

		include	"_incObj\66 Rotating Junction.asm"

		include	"_incObj\67 Running Disc.asm"

		include	"_incObj\68 Conveyor Belt.asm"

		include	"_incObj\69 SBZ Spinning Platforms.asm"

		include	"_incObj\6A Saws and Pizza Cutters.asm"

		include	"_incObj\6B SBZ Stomper and Door.asm"

		include	"_incObj\6C SBZ Vanishing Platforms.asm"

		include	"_incObj\6E Electrocuter.asm"

		include	"_incObj\6F SBZ Spin Platform Conveyor.asm"

		include	"_incObj\70 Girder Block.asm"

		include	"_incObj\72 Teleporter.asm"

		include	"_incObj\78 Caterkiller.asm"

		include	"_incObj\79 Lamppost.asm"

		include	"_incObj\7D Hidden Bonuses.asm"

		include	"_incObj\8A Credits.asm"

		include	"_incObj\3D Boss - Green Hill (part 1).asm"

; ---------------------------------------------------------------------------
; Defeated boss	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BossDefeated:
		move.b	(v_vbla_byte).w,d0
		andi.b	#7,d0
		bne.s	locret_178A2
		jsr		(FindFreeObj).l
		bne.s	locret_178A2
		move.b	#id_ExplosionBomb,obID(a1)	; load explosion object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		jsr		(RandomNumber).l
		move.w	d0,d1
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,obX(a1)
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,obY(a1)

locret_178A2:
		rts	
; End of function BossDefeated

; ---------------------------------------------------------------------------
; Subroutine to	move a boss (Similar to SpeedToPos, but for boss' buffer variables)
; Optimized by applying speed to the pos directly, instead of to d2 and d3.
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

BossMove:
		move.w	obVelX(a0),d0			; load horizontal speed
		ext.l	d0
		lsl.l	#8,d0					; multiply speed by $100
		add.l	d0,obBossBufferX(a0)	; add to buffer x-position
		move.w	obVelY(a0),d0			; load vertical	speed
		ext.l	d0
		lsl.l	#8,d0					; multiply by $100
		add.l	d0,obBossBufferY(a0)	; add to buffer y-position
		rts	
; End of function BossMove

; ===========================================================================

		include	"_incObj\3D Boss - Green Hill (part 2).asm"

		include	"_incObj\48 Eggman's Swinging Ball.asm"

		include	"_incObj\82 Eggman - Scrap Brain 2.asm"

		include	"_incObj\77 Boss - Labyrinth.asm"

		include	"_incObj\73 Boss - Marble.asm"

		include	"_incObj\74 MZ Boss Fire.asm"

		include	"_incObj\8E Boss - Labyrinth 2.asm"

		include	"_incObj\7A Boss - Star Light.asm"

		include	"_incObj\7B SLZ Boss Spikeball.asm"

		include	"_incObj\75 Boss - Spring Yard.asm"

		include	"_incObj\76 SYZ Boss Blocks.asm"

		include	"_incObj\83 SBZ Eggman's Crumbling Floor.asm"

		include	"_incObj\85 Boss - Final.asm"

		include	"_incObj\84 FZ Eggman's Cylinders.asm"

		include	"_incObj\86 FZ Plasma Ball Launcher.asm"

		include	"_incObj\3E Prison Capsule.asm"

		include	"_incObj\sub ReactToItem.asm"

		include "_incObj\4F Red Ring.asm" ; Complete Mode
		include "_incObj\8D Level Emerald.asm" ; Handheld Mode

; ---------------------------------------------------------------------------
; Subroutine to	show the special stage layout
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_ShowLayout:
		bsr.w	SS_AniWallsRings
		bsr.w	SS_AniItems
		move.w	d5,-(sp)
		lea	($FFFF8000).w,a1
		move.b	(v_ssangle).w,d0
		;andi.b	#$FC,d0				; Removed for smooth rotation (Cinossu)
		jsr	(CalcSine).l
		move.w	d0,d4
		move.w	d1,d5
		muls.w	#$18,d4
		muls.w	#$18,d5
		moveq	#0,d2
		move.w	(v_screenposx).w,d2
		divu.w	#$18,d2
		swap	d2
		neg.w	d2
		addi.w	#-$B4,d2
		moveq	#0,d3
		move.w	(v_screenposy).w,d3
		divu.w	#$18,d3
		swap	d3
		neg.w	d3
		addi.w	#-$B4,d3
		move.w	#$F,d7

loc_1B19E:
		movem.w	d0-d2,-(sp)
		movem.w	d0-d1,-(sp)
		neg.w	d0
		muls.w	d2,d1
		muls.w	d3,d0
		move.l	d0,d6
		add.l	d1,d6
		movem.w	(sp)+,d0-d1
		muls.w	d2,d0
		muls.w	d3,d1
		add.l	d0,d1
		move.l	d6,d2
		move.w	#$F,d6

loc_1B1C0:
		move.l	d2,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		move.l	d1,d0
		asr.l	#8,d0
		move.w	d0,(a1)+
		add.l	d5,d2
		add.l	d4,d1
		dbf	d6,loc_1B1C0

		movem.w	(sp)+,d0-d2
		addi.w	#$18,d3
		dbf	d7,loc_1B19E

		move.w	(sp)+,d5
		lea	($FF0000).l,a0
		moveq	#0,d0
		move.w	(v_screenposy).w,d0
		divu.w	#$18,d0
		mulu.w	#$80,d0
		adda.l	d0,a0
		moveq	#0,d0
		move.w	(v_screenposx).w,d0
		divu.w	#$18,d0
		adda.w	d0,a0
		lea	($FFFF8000).w,a4
		move.w	#$F,d7

loc_1B20C:
		move.w	#$F,d6

loc_1B210:
		moveq	#0,d0
		move.b	(a0)+,d0
		beq.s	loc_1B268
		cmpi.b	#$4E,d0
		bhi.s	loc_1B268
		move.w	(a4),d3
		addi.w	#$120,d3
		cmpi.w	#$70,d3
		blo.s	loc_1B268
		cmpi.w	#$1D0,d3
		bhs.s	loc_1B268
		move.w	2(a4),d2
		addi.w	#$F0,d2
		cmpi.w	#$70,d2
		blo.s	loc_1B268
		cmpi.w	#$170,d2
		bhs.s	loc_1B268
		lea	($FF4000).l,a5
		lsl.w	#3,d0
		lea	(a5,d0.w),a5
		movea.l	(a5)+,a1
		move.w	(a5)+,d1
		add.w	d1,d1
		adda.w	(a1,d1.w),a1
		movea.w	(a5)+,a3
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	loc_1B268
		jsr		(DrawSprite_Loop).l

loc_1B268:
		addq.w	#4,a4
		dbf	d6,loc_1B210

		lea	$70(a0),a0
		dbf	d7,loc_1B20C

		move.b	d5,(v_spritecount).w
		cmpi.b	#$50,d5
		beq.s	loc_1B288
		move.l	#0,(a2)
		rts	
; ===========================================================================

loc_1B288:
		move.b	#0,-5(a2)
		rts	
; End of function SS_ShowLayout

; ---------------------------------------------------------------------------
; Subroutine to	animate	walls and rings	in the special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_AniWallsRings:
		lea	($FF4005).l,a1
		subq.b	#1,(v_ani1_time).w
		bpl.s	loc_1B2C8
		move.b	#3,(v_ani1_time).w
		addq.b	#1,(v_ani1_frame).w
		andi.b	#7,(v_ani1_frame).w ; 8-frame rings

loc_1B2C8:
		move.b	(v_ani1_frame).w,$1D0(a1)
		subq.b	#1,(v_ani2_time).w
		bpl.s	loc_1B2E4
		move.b	#7,(v_ani2_time).w
		addq.b	#1,(v_ani2_frame).w
		andi.b	#1,(v_ani2_frame).w

loc_1B2E4:
		move.b	(v_ani2_frame).w,d0
		move.b	d0,$138(a1)
		move.b	d0,$160(a1)
		move.b	d0,$148(a1)
		move.b	d0,$150(a1)
		move.b	d0,$1D8(a1) ; Animation data for Chaos Emeralds. Change this to have them all flash to the same flicker frame, a la Sonic 1 (2013)
		move.b	d0,$1E0(a1)
		move.b	d0,$1E8(a1)
		move.b	d0,$1F0(a1)
		move.b	d0,$1F8(a1)
		move.b	d0,$200(a1)
		subq.b	#1,(v_ani3_time).w
		bpl.s	loc_1B326
		move.b	#4,(v_ani3_time).w
		addq.b	#1,(v_ani3_frame).w
		andi.b	#3,(v_ani3_frame).w

loc_1B326:
		move.b	(v_ani3_frame).w,d0
		move.b	d0,$168(a1)
		move.b	d0,$170(a1)
		move.b	d0,$178(a1)
		move.b	d0,$180(a1)
		subq.b	#1,(v_ani0_time).w
		bpl.s	loc_1B350
		move.b	#7,(v_ani0_time).w
		subq.b	#1,(v_ani0_frame).w
		andi.b	#7,(v_ani0_frame).w

loc_1B350:
		lea	($FF4016).l,a1
		lea	(SS_WaRiVramSet).l,a0
		moveq	#0,d0
		move.b	(v_ani0_frame).w,d0
		add.w	d0,d0
		lea	(a0,d0.w),a0
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		move.w	(a0),(a1)
		move.w	2(a0),8(a1)
		move.w	4(a0),$10(a1)
		move.w	6(a0),$18(a1)
		move.w	8(a0),$20(a1)
		move.w	$A(a0),$28(a1)
		move.w	$C(a0),$30(a1)
		move.w	$E(a0),$38(a1)
		adda.w	#$20,a0
		adda.w	#$48,a1
		rts	
; End of function SS_AniWallsRings

SS_LoadWalls:
		moveq	#0,d0
		move.b	(v_ssangle).w,d0		; get the Special Stage angle
		lsr.b	#2,d0					; modify so it can be used as a frame ID
		andi.w	#$F,d0
		cmp.b	(v_ssangleprev).w,d0	; does the modified angle match the recorded value?
		beq.s	@return					; if so, branch

		lea		($C00000).l,a6
		lea		(Art_SSWalls).l,a1		; load wall art
		move.w	d0,d1
		lsl.w	#8,d1
		add.w	d1,d1
		add.w	d1,a1

		locVRAM	$2840					; VRAM address

		move.w	#$F,d1					; number of 8x8 tiles
		jsr		LoadTiles
		move.b	d0,(v_ssangleprev).w	; record the modified angle for comparison

	@return:
		rts

; ===========================================================================
SS_WaRiVramSet:	dc.w $142, $6142, $142,	$142, $142, $142, $142,	$6142
		dc.w $142, $6142, $142,	$142, $142, $142, $142,	$6142
		dc.w $2142, $142, $2142, $2142,	$2142, $2142, $2142, $142
		dc.w $2142, $142, $2142, $2142,	$2142, $2142, $2142, $142
		dc.w $4142, $2142, $4142, $4142, $4142,	$4142, $4142, $2142
		dc.w $4142, $2142, $4142, $4142, $4142,	$4142, $4142, $2142
		dc.w $6142, $4142, $6142, $6142, $6142,	$6142, $6142, $4142
		dc.w $6142, $4142, $6142, $6142, $6142,	$6142, $6142, $4142
; ---------------------------------------------------------------------------
; Subroutine to	remove items when you collect them in the special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_RemoveCollectedItem:
		lea	($FF4400).l,a2
		move.w	#$1F,d0

loc_1B4C4:
		tst.b	(a2)
		beq.s	locret_1B4CE
		addq.w	#8,a2
		dbf	d0,loc_1B4C4

locret_1B4CE:
		rts	
; End of function SS_RemoveCollectedItem

; ---------------------------------------------------------------------------
; Subroutine to	animate	special	stage items when you touch them
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_AniItems:
		lea	($FF4400).l,a0
		move.w	#$1F,d7

loc_1B4DA:
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	loc_1B4E8
		lsl.w	#2,d0
		movea.l	SS_AniIndex-4(pc,d0.w),a1
		jsr	(a1)

loc_1B4E8:
		addq.w	#8,a0

loc_1B4EA:
		dbf	d7,loc_1B4DA

		rts	
; End of function SS_AniItems

; ===========================================================================
SS_AniIndex:
		dc.l SS_AniRingSparks
		dc.l SS_AniBumper
		dc.l SS_Ani1Up
		dc.l SS_AniReverse
		dc.l SS_AniEmeraldSparks
		dc.l SS_AniGlassBlock
; ===========================================================================

SS_AniRingSparks:
		subq.b	#1,2(a0)
		bpl.s	locret_1B530
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniRingData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B530
		clr.l	(a0)
		clr.l	4(a0)

locret_1B530:
		rts	
; ===========================================================================
SS_AniRingData:	dc.b $42, $43, $44, $45, 0, 0
; ===========================================================================

SS_AniBumper:
		subq.b	#1,2(a0)
		bpl.s	locret_1B566
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniBumpData(pc,d0.w),d0
		bne.s	loc_1B564
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$25,(a1)
		rts	
; ===========================================================================

loc_1B564:
		move.b	d0,(a1)

locret_1B566:
		rts	
; ===========================================================================
SS_AniBumpData:	dc.b $32, $33, $32, $33, 0, 0
; ===========================================================================

SS_Ani1Up:
		subq.b	#1,2(a0)
		bpl.s	locret_1B596
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_Ani1UpData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B596
		clr.l	(a0)
		clr.l	4(a0)

locret_1B596:
		rts	
; ===========================================================================
SS_Ani1UpData:	dc.b $46, $47, $48, $49, 0, 0
; ===========================================================================

SS_AniReverse:
		subq.b	#1,2(a0)
		bpl.s	locret_1B5CC
		move.b	#7,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniRevData(pc,d0.w),d0
		bne.s	loc_1B5CA
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#$2B,(a1)
		rts	
; ===========================================================================

loc_1B5CA:
		move.b	d0,(a1)

locret_1B5CC:
		rts	
; ===========================================================================
SS_AniRevData:	dc.b $2B, $31, $2B, $31, 0, 0
; ===========================================================================

SS_AniEmeraldSparks:
		subq.b	#1,2(a0)
		bpl.s	locret_1B60C
		move.b	#5,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniEmerData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B60C
		clr.l	(a0)
		clr.l	4(a0)
		move.b	#4,($FFFFD024).w
		sfx	sfx_SSGoal,0,0,0	; play special stage GOAL sound

locret_1B60C:
		rts	
; ===========================================================================
SS_AniEmerData:	dc.b $46, $47, $48, $49, 0, 0
; ===========================================================================

SS_AniGlassBlock:
		subq.b	#1,2(a0)
		bpl.s	locret_1B640
		move.b	#1,2(a0)
		moveq	#0,d0
		move.b	3(a0),d0
		addq.b	#1,3(a0)
		movea.l	4(a0),a1
		move.b	SS_AniGlassData(pc,d0.w),d0
		move.b	d0,(a1)
		bne.s	locret_1B640
		move.b	4(a0),(a1)
		clr.l	(a0)
		clr.l	4(a0)

locret_1B640:
		rts	
; ===========================================================================
SS_AniGlassData:dc.b $4B, $4C, $4D, $4E, $4B, $4C, $4D,	$4E, 0,	0

; ---------------------------------------------------------------------------
; Special stage	layout pointers
; ---------------------------------------------------------------------------
SS_LayoutIndex:
		dc.l SS_1
		dc.l SS_2
		dc.l SS_3
		dc.l SS_4
		dc.l SS_5
		dc.l SS_6
		even

; ---------------------------------------------------------------------------
; Special stage start locations
; ---------------------------------------------------------------------------
SS_StartLoc:	include	"_inc\Start Location Array - Special Stages.asm"

; ---------------------------------------------------------------------------
; Subroutine to	load special stage layout
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_Load:
		moveq	#0,d0
		move.b	(v_lastspecial).w,d0 ; load number of last special stage entered
		cmpi.b	#6,(v_emeralds).w    ; Does Sonic already have all emeralds?
		bcs.s	SS_Not7Emeralds      ; if not, branch
		addq.b	#1,(v_lastspecial).w ; if yes, Special Stage increments always.
		cmpi.b	#6,(v_lastspecial).w ; 6 (7 - Complete)
		bcs.s	SS_Not7Emeralds
		clr.b	(v_lastspecial).w ; reset if 7 or higher

SS_Not7Emeralds:
		cmpi.b	#6,d0                ; 6 (7) EMERALDS
		bcs.s	SS_LoadData
		move.b	#0,d0                ; reset if 6 (7) or higher
		move.b	d0,(v_lastspecial).w

SS_LoadData:
		lsl.w	#2,d0
		lea		SS_StartLoc(pc,d0.w),a1
		move.w	(a1)+,(v_player+obX).w
		move.w	(a1)+,(v_player+obY).w
		movea.l SS_LayoutIndex(pc,d0.w),a0 ; Replaced with lines below due to a length error. (LayoutIndex data is 130 bytes too far away)
;		lea	SS_LayoutIndex,a0 ; load index into an address register
;		movea.l (a0,d0.w),a0      ; then performs the same as above line
		lea	($FF4000).l,a1
		move.w	#0,d0
		jsr	(EniDec).l
		lea	($FF0000).l,a1
		move.w	#$FFF,d0

SS_ClrRAM3:
		clr.l	(a1)+
		dbf	d0,SS_ClrRAM3

		lea	($FF1020).l,a1
		lea	($FF4000).l,a0
		moveq	#$3F,d1

loc_1B6F6:
		moveq	#$3F,d2

loc_1B6F8:
;		move.b	(a0)+,(a1)+
		; SS Continued addition (Places a 1-Up icon instead of an emerald, if all emeralds are obtained)
		move.b	(a0)+,d0		; load the layout item into d0
		cmpi.b	#$3B,d0			; is the item an emerald?
		bcs.s	@notem
		cmpi.b	#$40,d0                 ; REV C EDIT - 7 EMERALDS
		bhi.s	@notem
		;cmpi.b	#7,(v_emeralds).w	; do you have all the emeralds? ; REV C EDIT - 7 EMERALDS
		move.b	d0,d3
		subi.b	#$3B,d3
		btst	d3,(v_emeraldlist).w	; does Sonic have this emerald?
		beq.s	@notem			; if not, branch
		move.b	#$28,d0			; else, make a 1up

	@notem:
		move.b	d0,(a1)+		; move the item into memory
		dbf	d2,loc_1B6F8

		lea	$40(a1),a1
		dbf	d1,loc_1B6F6

		lea	($FF4008).l,a1
		lea	(SS_MapIndex).l,a0
		moveq	#$4D,d1

loc_1B714:
		move.l	(a0)+,(a1)+
		move.w	#0,(a1)+
		move.b	-4(a0),-1(a1)
		move.w	(a0)+,(a1)+
		dbf	d1,loc_1B714

		lea	($FF4400).l,a1
		move.w	#$3F,d1

loc_1B730:

		clr.l	(a1)+
		dbf	d1,loc_1B730

		rts	
; End of function SS_Load

; ===========================================================================

SS_MapIndex:
		include	"_inc\Special Stage Mappings & VRAM Pointers.asm"

		include	"_incObj\09 Sonic in Special Stage.asm"

		include	"_incObj\10.asm"

		include	"_inc\AnimateLevelGfx.asm"

			include "_incObj\21.asm"



; ---------------------------------------------------------------------------
; Add points subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AddPoints:
		move.b	#1,(f_scorecount).w ; set score counter to update
		lea     (v_score).w,a3
		add.l   d0,(a3)
		move.l  #999999,d1
		cmp.l   (a3),d1 ; is score below 999999?
		bhi.s   @belowmax ; if yes, branch
		move.l  d1,(a3) ; reset score to 999999

	@belowmax:
		cmpi.b	#difHard,(v_difficulty).w
		beq.s	@noextralife

		move.l  (a3),d0
		cmp.l   (v_scorelife).w,d0 ; has Sonic got 50000+ points?
		blo.s   @noextralife ; if not, branch

		addi.l  #5000,(v_scorelife).w ; increase requirement by 50000
		cmpi.b	#$63,(v_lives).w	; are lives at max?
		beq.s	@playbgm
		addq.b	#1,(v_lives).w	; add 1 to number of lives
		addq.b	#1,(f_lifecount).w ; update the lives counter
	@playbgm:
		music	bgm_ExtraLife,1,0,0

@locret_1C6B6:
@noextralife:
		rts	
; End of function AddPoints

		include	"_inc\HUD_Update.asm"
		include	"_inc\HUD_Update_SS.asm"
		include	"_inc\HUD_Update_TA.asm"

; ---------------------------------------------------------------------------
; Subroutine to	load countdown numbers on the continue screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ContScrCounter:
		locVRAM	$DF80
		lea	(vdp_data_port).l,a6
		lea	(Hud_10).l,a2
		moveq	#1,d6
		moveq	#0,d4
		lea	Art_Hud(pc),a1 ; load numbers patterns

ContScr_Loop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C95A:
		sub.l	d3,d1
		blo.s	loc_1C962
		addq.w	#1,d2
		bra.s	loc_1C95A
; ===========================================================================

loc_1C962:
		add.l	d3,d1
		lsl.w	#6,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		dbf	d6,ContScr_Loop	; repeat 1 more	time

		rts	
; End of function ContScrCounter

; ===========================================================================

		include	"_inc\HUD (part 2).asm"

Art_Hud:	incbin	"artunc\HUD Numbers.bin" ; 8x16 pixel numbers on HUD
		even
Art_LivesNums:	incbin	"artunc\Lives Counter Numbers.bin" ; 8x8 pixel numbers on lives counter
		even

		include	"_incObj\DebugMode.asm"
		include	"_inc\DebugList.asm"
		include	"_inc\LevelHeaders.asm"
		include	"_inc\Pattern Load Cues.asm"

		align	$200,$FF

Nem_SegaLogo:	incbin	"artnem\Sega Logo.bin"	; large Sega logo
		even
Eni_SegaLogo:	incbin	"tilemaps\Sega Logo.bin" ; large Sega logo (mappings)
		even

Eni_Title:	incbin	"tilemaps\Title Screen.bin" ; title screen foreground (mappings) (Unc Chunks)
		even
Nem_TitleFg:	incbin	"artnem\Title Screen Foreground.bin"
		even
Nem_TitleSonic:	incbin	"artnem\Title Screen Sonic.bin"
		even
Nem_TitleTM:	incbin	"artnem\Title Screen TM.bin"
		even
Nem_TitleMenu:	incbin	"artnem\Title Screen Menu.bin"
		even
Eni_JapNames:	incbin	"tilemaps\Hidden Japanese Credits.bin" ; Japanese credits (mappings)
		even
Nem_JapNames:	incbin	"artnem\Hidden Japanese Credits.bin"
		even
Eni_MenuBack:	incbin	"tilemaps\SONIC MILES animated background.bin"
		even
Art_MenuBack:	incbin	"artunc\SONIC MILES background art.bin"
		even
Nem_MenuStuff:	incbin	"artnem\Level Select Font.bin"
		even
Eni_LevSel:		incbin	"tilemaps\Level Select.bin"
		even
Eni_LevSelIcons:	incbin	"tilemaps\Level Select Icons.bin"
		even
Nem_LevSelIcons:	incbin	"artnem\Level Select Icons.bin"
		even

; ---------------------------------------------------------------------------
; Level	select menu text - Easier editing thanks to SoullessSentinel
; ---------------------------------------------------------------------------
OptionMenuText:
		;incbin	"misc\Level Select Text.bin"
		dc.b "GAME MODE               " ; Dictates levels, emeralds... etc.
		dc.b "                        " ; ORIGINAL, MASTER SYSTEM, COMPLETE
		dc.b "CHARACTER               "
		dc.b "                        " ; SONIC, TAILS, KNUCKLES, MIGHTY, AMY, METAL
		dc.b "NULL OPTION             "
		dc.b "                        " ; BASIC, COMPLETE
		dc.b "DIFFICULTY              " ; LAYOUTS AND GAMEPLAY
		dc.b "                        " ; CASUAL, NORMAL, EXPERT
		dc.b "MONITORS                " ; SHIELD MONITOR SETTING
		dc.b "                        " ; CLASSIC, SONIC 3K, RANDOM
		dc.b "NULL OPTION             " ; TOTAL EMERALD SETTING
		dc.b "                        " ; 6 EMERALDS/7 EMERALDS - 7 EMERALDS=SUPER SONIC
		dc.b "NULL OPTION             "
		dc.b "                        " ; ORIGINAL, MASTER SYSTEM
		dc.b "NULL OPTION             "
		dc.b "                        " ; ORIGINAL, MASTER SYSTEM
		dc.b "SOUND TEST              "
		dc.b "                        " ; FAST ZONE MUSIC, INVINCIBILITY, SONIC 2 JINGLE
		dc.b "START NEW GAME          "
		dc.b "                        "
		dc.b "RESET TO TITLE SCREEN   "
		even

; ---------------------------------------------------------------------------
; Mode select menu text - Easier editing thanks to SoullessSentinel
; ---------------------------------------------------------------------------
ModeText_Classic:	dc.b "CLASSIC " ; Normal Sonic 1
ModeText_Original:	dc.b "ORIGINAL" ; Original (Beta) Sonic 1
ModeText_Handheld:	dc.b "HANDHELD" ; 8-bit Sonic 1
ModeText_Complete:	dc.b "COMPLETE" ; 8x16 (Complete)
; ===========================================================================

; ---------------------------------------------------------------------------
; Player select menu text - Easier editing thanks to SoullessSentinel
; ---------------------------------------------------------------------------
CharText_Sonic:		dc.b "SONIC   "
CharText_Tails:		dc.b "TAILS   "
CharText_Knuckles:	dc.b "KNUCKLES"
CharText_Mighty:	dc.b "MIGHTY  "
CharText_Ray:		dc.b "RAY     "
CharText_Amy:		dc.b "AMY     "
CharText_Metal:		dc.b "METAL   "
; ===========================================================================

; ---------------------------------------------------------------------------
; Difficulty select menu text - Easier editing thanks to SoullessSentinel
; ---------------------------------------------------------------------------
DifficultyText_Norm:	dc.b "NORMAL"
DifficultyText_Easy:	dc.b "CASUAL"
DifficultyText_Hard:	dc.b "EXPERT"
; ===========================================================================

; ---------------------------------------------------------------------------
; Difficulty select menu text - Easier editing thanks to SoullessSentinel
; ---------------------------------------------------------------------------
MonitorText_S1:		dc.b "ORIGINAL"
MonitorText_S3K:	dc.b "S1/S3K  "
; ===========================================================================

; ---------------------------------------------------------------------------
; Music	playlist
; ---------------------------------------------------------------------------
MusicList:
		dc.b bgm_GHZ	; GHZ
		dc.b bgm_LZ		; LZ
		dc.b bgm_MZ		; MZ
		dc.b bgm_SLZ	; SLZ
		dc.b bgm_SYZ	; SYZ
		dc.b bgm_SBZ	; SBZ
		dc.b bgm_FZ		; Ending
		dc.b bgm_GHZ	; BZ
		dc.b bgm_MZ		; JZ
		dc.b bgm_SLZ	; SKBZ
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Music	to play	after invincibility wears off
; ---------------------------------------------------------------------------
MusicList2:
		dc.b bgm_GHZ
		dc.b bgm_LZ
		dc.b bgm_MZ
		dc.b bgm_SLZ
		dc.b bgm_SYZ
		dc.b bgm_SBZ
		dc.b bgm_GHZ
		dc.b bgm_GHZ	; BZ
		dc.b bgm_MZ		; JZ
		dc.b bgm_SLZ	; SKBZ
		even
; ===========================================================================

; ---------------------------------------------------------------------------
; Palette data
; ---------------------------------------------------------------------------
		include	"_inc\Palette Pointers.asm"

Pal_Title:		incbin	"palette\Title Screen.bin"
Pal_Options:	incbin	"palette\Options.bin"
Pal_Sonic:		incbin	"palette\Sonic.bin"


Pal_GHZ:			incbin	"palette\Green Hill Zone.bin"
Pal_GHZ_Easy:		incbin	"palette\Green Hill Zone - Easy.bin"
Pal_GHZ_Hard:		incbin	"palette\Green Hill Zone - Hard.bin"
Pal_LZ:				incbin	"palette\Labyrinth Zone.bin"
Pal_LZ_Easy:		incbin	"palette\Labyrinth Zone - Easy.bin"
Pal_LZ_Hard:		incbin	"palette\Labyrinth Zone - Hard.bin"
Pal_LZWater:		incbin	"palette\Labyrinth Zone Underwater.bin"
Pal_LZWater_Easy:	incbin	"palette\Labyrinth Zone Underwater - Easy.bin"
Pal_LZWater_Hard:	incbin	"palette\Labyrinth Zone Underwater - Hard.bin"
Pal_MZ:				incbin	"palette\Marble Zone.bin"
Pal_MZ_Easy:		incbin	"palette\Marble Zone - Easy.bin"
Pal_MZ_Hard:		incbin	"palette\Marble Zone - Hard.bin"
Pal_SLZ:			incbin	"palette\Star Light Zone.bin"
Pal_SLZ_Easy:		incbin	"palette\Star Light Zone - Easy.bin"
Pal_SLZ_Hard:		incbin	"palette\Star Light Zone - Hard.bin"
Pal_SYZ:			incbin	"palette\Spring Yard Zone.bin"
Pal_SYZ_Easy:		incbin	"palette\Spring Yard Zone - Easy.bin"
Pal_SYZ_Hard:		incbin	"palette\Spring Yard Zone - Hard.bin"
Pal_SBZ1:			incbin	"palette\SBZ Act 1.bin"
Pal_SBZ1_Easy:		incbin	"palette\SBZ Act 1 - Easy.bin"
Pal_SBZ1_Hard:		incbin	"palette\SBZ Act 1 - Hard.bin"
Pal_SBZ2:			incbin	"palette\SBZ Act 2.bin"
Pal_SBZ2_Easy:		incbin	"palette\SBZ Act 2 - Easy.bin"
Pal_SBZ2_Hard:		incbin	"palette\SBZ Act 2 - Hard.bin"
Pal_SBZ3:			incbin	"palette\SBZ Act 3.bin"
Pal_SBZ3_Easy:		incbin	"palette\SBZ Act 3 - Easy.bin"
Pal_SBZ3_Hard:		incbin	"palette\SBZ Act 3 - Hard.bin"
Pal_SBZ3Water:		incbin	"palette\SBZ Act 3 Underwater.bin"
Pal_SBZ3Water_Easy:	incbin	"palette\SBZ Act 3 Underwater - Easy.bin"
Pal_SBZ3Water_Hard:	incbin	"palette\SBZ Act 3 Underwater - Hard.bin"
Pal_BZ:				incbin	"palette\Bridge Zone.bin"
Pal_BZ_Easy:		incbin	"palette\Bridge Zone - Easy.bin"
Pal_BZ_Hard:		incbin	"palette\Bridge Zone - Hard.bin"
Pal_JZ:				incbin	"palette\Jungle Zone.bin"
Pal_JZ_Easy:		incbin	"palette\Jungle Zone - Easy.bin"
Pal_JZ_Hard:		incbin	"palette\Jungle Zone - Hard.bin"
Pal_SKBZ:			incbin	"palette\Sky Base Zone.bin"
Pal_SKBZ_Easy:		incbin	"palette\Sky Base Zone - Easy.bin"
Pal_SKBZ_Hard:		incbin	"palette\Sky Base Zone - Hard.bin"

Pal_Special:	incbin	"palette\Special Stage.bin"
Pal_LZSonWater:	incbin	"palette\Sonic - LZ Underwater.bin"
Pal_SBZ3SonWat:	incbin	"palette\Sonic - SBZ3 Underwater.bin"
Pal_SSResult:	incbin	"palette\Special Stage Results.bin"
Pal_Continue:	incbin	"palette\Special Stage Continue Bonus.bin"
Pal_Ending:		incbin	"palette\Ending.bin"
Pal_Menu:		incbin	"palette\Menu.bin"
Pal_LevSelIcons: incbin "palette\Level Select Icons.bin"


; ---------------------------------------------------------------------------
; Sprite Animations
; ---------------------------------------------------------------------------

		include	"_anim\Sonic.asm"
		include "_anim\Effects.asm"		; Dash Dush and Skid Dust

		include	"_anim\Continue Screen Sonic.asm"
		include "_anim\Ending Sequence Sonic.asm"
		include "_anim\Try Again & End Eggman.asm"
		include	"_anim\SBZ Small Door.asm"
		include	"_anim\Ball Hog.asm"
		include	"_anim\Crabmeat.asm"
		include	"_anim\Buzz Bomber.asm"
		include	"_anim\Buzz Bomber Missile.asm"
		include	"_anim\Rings.asm"
		include	"_anim\Monitor.asm"
		include	"_anim\Title Screen Sonic.asm"
		include	"_anim\Press Start and TM.asm"
		include	"_anim\Chopper.asm"
		include	"_anim\Jaws.asm"
		include	"_anim\Burrobot.asm"
		include	"_anim\Burning Grass.asm"
		include	"_anim\Eggman.asm"
		include	"_anim\Eggman - Scrap Brain 2 & Final.asm"
		include	"_anim\FZ Eggman in Ship.asm"
		include	"_anim\Plasma Ball Launcher.asm"
		include	"_anim\Plasma Balls.asm"
		include	"_anim\Prison Capsule.asm"
		include	"_anim\Basaran.asm"
		include	"_anim\Flapping Door.asm"
		include	"_anim\Bomb Enemy.asm"
		include	"_anim\Orbinaut.asm"
		include	"_anim\Harpoon.asm"
		include	"_anim\Bubbles.asm"
		include	"_anim\Waterfalls.asm"
		include	"_anim\Drowning Countdown.asm"
		include	"_anim\Shield and Invincibility.asm"
		include	"_anim\Special Stage Entry (Unused).asm"
		include	"_anim\Water Splash.asm"
		include	"_anim\SBZ Spinning Platforms.asm"
		include	"_anim\SBZ Vanishing Platforms.asm"
		include	"_anim\Electrocuter.asm"
		include	"_anim\SBZ Spin Platform Conveyor.asm"
		include	"_anim\Caterkiller.asm"
		include	"_anim\Newtron.asm"
		include	"_anim\Springs.asm"
		include	"_anim\Roller.asm"
		include	"_anim\Fireballs.asm"
		include	"_anim\Flamethrower.asm"
		include	"_anim\Bumper.asm"
		include	"_anim\Signpost.asm"
		include	"_anim\Lava Geyser.asm"
		include	"_anim\Wall of Lava.asm"
		include	"_anim\Moto Bug.asm"
		include	"_anim\Yadrin.asm"


; ---------------------------------------------------------------------------
; Sprite Mappings
; ---------------------------------------------------------------------------

		include	"_maps\Sonic.asm"
		include	"_maps\Sonic - DPLC.asm"

Map_ContScr:	include	"_maps\Continue Screen.asm"
Map_ESon:	include	"_maps\Ending Sequence Sonic.asm"
Map_ECha:	include	"_maps\Ending Sequence Emeralds.asm"
Map_ESth:	include	"_maps\Ending Sequence STH.asm"
Map_EEgg:	include	"_maps\Try Again & End Eggman.asm"
Map_Bri:	include	"_maps\Bridge.asm"
Map_Swing_GHZ:	include	"_maps\Swinging Platforms (GHZ).asm"
Map_Swing_SLZ:	include	"_maps\Swinging Platforms (SLZ).asm"
Map_Hel:	include	"_maps\Spiked Pole Helix.asm"
Map_Plat_Unused:include	"_maps\Platforms (unused).asm"
Map_Plat_GHZ:	include	"_maps\Platforms (GHZ).asm"
Map_Plat_SYZ:	include	"_maps\Platforms (SYZ).asm"
Map_Plat_SLZ:	include	"_maps\Platforms (SLZ).asm"
Map_GBall:	include	"_maps\GHZ Ball.asm"
Map_Scen:	include	"_maps\Scenery.asm"
Map_Swi:	include	"_maps\Unused Switch.asm"
Map_ADoor:	include	"_maps\SBZ Small Door.asm"


Map_Ledge:	include	"_maps\Collapsing Ledge.asm"
Map_CFlo:	include	"_maps\Collapsing Floors.asm"
Map_Hog:	include	"_maps\Ball Hog.asm"
Map_MisDissolve:include	"_maps\Buzz Bomber Missile Dissolve.asm"
		include	"_maps\Explosions.asm"
Map_Animal1:	include	"_maps\Animals 1.asm"
Map_Animal2:	include	"_maps\Animals 2.asm"
Map_Animal3:	include	"_maps\Animals 3.asm"
Map_Poi:	include	"_maps\Points.asm"

Map_Crab:	include	"_maps\Crabmeat.asm"
		include	"_maps\Buzz Bomber.asm"
		include	"_maps\Buzz Bomber Missile.asm"


		include	"_maps\Rings.asm" ; THESE normal mappings are for debug rings, lost rings, and SS rings

Map_RingBIN:
		incbin	"_maps\Rings.bin" ; THESE special mappings are for the S2 Rings Manager
		even

		include	"_maps\Giant Ring.asm"
		include "_maps\Giant Ring - Dynamic Gfx Script.asm"

Map_Flash:	include	"_maps\Ring Flash.asm"

Map_Monitor:	include	"_maps\Monitor.asm"

Map_PSB:	include	"_maps\Press Start and TM.asm"
Map_TSon:	include	"_maps\Title Screen Sonic.asm"
Map_Chop:	include	"_maps\Chopper.asm"
Map_Jaws:	include	"_maps\Jaws.asm"
Map_Burro:	include	"_maps\Burrobot.asm"
Map_LGrass:	include	"_maps\MZ Large Grassy Platforms.asm"
Map_Fire:	include	"_maps\Fireballs.asm"
Map_Glass:	include	"_maps\MZ Large Green Glass Blocks.asm"

Map_CStom:	include	"_maps\Chained Stompers.asm"
Map_SStom:	include	"_maps\Sideways Stomper.asm"
Map_But:	include	"_maps\Button.asm"
Map_Push:	include	"_maps\Pushable Blocks.asm"

			include "_maps\Zone Title Cards.asm"
Map_Over:	include	"_maps\Game Over.asm"
			include "_maps\Got Through Cards.asm"

Map_SSRC:	include	"_maps\SS Result Chaos Emeralds.asm"

Map_Spike:	include	"_maps\Spikes.asm"
Map_PRock:	include	"_maps\Purple Rock.asm"
Map_Smash:	include	"_maps\Smashable Walls.asm"
Map_Spring:	include	"_maps\Springs.asm"
Map_Newt:	include	"_maps\Newtron.asm"
Map_Roll:	include	"_maps\Roller.asm"
Map_Edge:	include	"_maps\GHZ Edge Walls.asm"

Map_Flame:	include	"_maps\Flamethrower.asm"
Map_Brick:	include	"_maps\MZ Bricks.asm"
Map_Light	include	"_maps\Light.asm"
Map_Bump:	include	"_maps\Bumper.asm"

		include	"_maps\Signpost.asm"
		include	"_maps\Signpost - DPLC.asm"

Map_LTag:	include	"_maps\Lava Tag.asm"

Map_Geyser:	include	"_maps\Lava Geyser.asm"
Map_LWall:	include	"_maps\Wall of Lava.asm"
Map_Moto:	include	"_maps\Moto Bug.asm"
Map_Yad:	include	"_maps\Yadrin.asm"
Map_Smab:	include	"_maps\Smashable Green Block.asm"
Map_MBlock:	include	"_maps\Moving Blocks (MZ and SBZ).asm"
Map_MBlockLZ:	include	"_maps\Moving Blocks (LZ).asm"
Map_Bas:	include	"_maps\Basaran.asm"
Map_FBlock:	include	"_maps\Floating Blocks and Doors.asm"
Map_SBall:	include	"_maps\Spiked Ball and Chain (SYZ).asm"
Map_SBall2:	include	"_maps\Spiked Ball and Chain (LZ).asm"
Map_BBall:	include	"_maps\Big Spiked Ball.asm"
Map_Elev:	include	"_maps\SLZ Elevators.asm"
Map_Circ:	include	"_maps\SLZ Circling Platform.asm"
Map_Stair:	include	"_maps\Staircase.asm"
Map_Pylon:	include	"_maps\Pylon.asm"
Map_Surf:	include	"_maps\Water Surface.asm"
Map_Pole:	include	"_maps\Pole that Breaks.asm"
Map_Flap:	include	"_maps\Flapping Door.asm"
Map_Invis:	include	"_maps\Invisible Barriers.asm"
Map_Fan:	include	"_maps\Fan.asm"
Map_Seesaw:	include	"_maps\Seesaw.asm"
Map_SSawBall:	include	"_maps\Seesaw Ball.asm"
Map_Bomb:	include	"_maps\Bomb Enemy.asm"
Map_Orb:	include	"_maps\Orbinaut.asm"
Map_Harp:	include	"_maps\Harpoon.asm"
Map_LBlock:	include	"_maps\LZ Blocks.asm"

Map_Gar:	include	"_maps\Gargoyle.asm"
Map_LConv:	include	"_maps\LZ Conveyor.asm"
		include	"_maps\Bubbles.asm"

Map_WFall	include	"_maps\Waterfalls.asm"

Map_Drown:	include	"_maps\Drowning Countdown.asm"

Map_Vanish:	include	"_maps\Special Stage Entry (Unused).asm"

Map_Splash:	include	"_maps\Water Splash.asm"

Map_Jun:	include	"_maps\Rotating Junction.asm"
Map_Disc:	include	"_maps\Running Disc.asm"
Map_Trap:	include	"_maps\Trapdoor.asm"
Map_Spin:	include	"_maps\SBZ Spinning Platforms.asm"
Map_Saw:	include	"_maps\Saws and Pizza Cutters.asm"
Map_Stomp:	include	"_maps\SBZ Stomper and Door.asm"
Map_VanP:	include	"_maps\SBZ Vanishing Platforms.asm"
Map_Elec:	include	"_maps\Electrocuter.asm"
Map_Gird:	include	"_maps\Girder Block.asm"
Map_Cat:	include	"_maps\Caterkiller.asm"
Map_Lamp:	include	"_maps\Lamppost.asm"
Map_Bonus:	include	"_maps\Hidden Bonuses.asm"
Map_Cred:	include	"_maps\Credits.asm"

Map_Eggman:		include	"_maps\Eggman.asm"

Map_BossItems:	include	"_maps\Boss Items.asm"

				include "_maps\Eggman - Bridge Boss.asm"

Map_BSBall:	include	"_maps\SLZ Boss Spikeball.asm"

Map_BossBlock:	include	"_maps\SYZ Boss Blocks.asm"

Map_SEgg:	include	"_maps\Eggman - Scrap Brain 2.asm"

Map_FFloor:	include	"_maps\SBZ Eggman's Crumbling Floor.asm"

Map_FZDamaged:	include	"_maps\FZ Damaged Eggmobile.asm"
Map_FZLegs:	include	"_maps\FZ Eggmobile Legs.asm"
Map_EggCyl:	include	"_maps\FZ Eggman's Cylinders.asm"
Map_PLaunch:	include	"_maps\Plasma Ball Launcher.asm"
Map_Plasma:	include	"_maps\Plasma Balls.asm"
Map_Pri:	include	"_maps\Prison Capsule.asm"

Map_SS_R:	include	"_maps\SS R Block.asm"
Map_SS_Glass:	include	"_maps\SS Glass Block.asm"
Map_SS_Up:	include	"_maps\SS UP Block.asm"
Map_SS_Down:	include	"_maps\SS DOWN Block.asm"
		include	"_maps\SS Chaos Emeralds.asm"

		include	"_maps\HUD.asm"
		include	"_maps\HUD SS.asm"
		include	"_maps\HUD TA.asm"

; ---------------------------------------------------------------------------
; Uncompressed graphics
; ---------------------------------------------------------------------------
Art_Sonic:		incbin	"artunc\Sonic.bin"	; Sonic
		even
Art_Effects:	incbin	"artunc\Dust Effects.bin"	; Spindash/Skid Dust
		even
Art_Insta:		incbin	"artunc\Shield - Insta.bin"	; Spindash and Skidding dust (REV C EDIT)
		even
Art_Shield:		incbin	"artunc\Shield - Blue.bin"
		even
Art_Shield_F:	incbin	"artunc\Shield - Flame.bin"
		even
Art_Shield_B:	incbin	"artunc\Shield - Bubble.bin"
		even
Art_Shield_L:	incbin	"artunc\Shield - Lightning.bin"
		even
Art_Shield_L2:	incbin	"artunc\Shield - Lightning - Sparks.bin"
		even
Art_Stars:		incbin	"artunc\Invincibility Stars.bin"
		even
Art_SignPost:	incbin	"artunc\Signpost.bin"	; end of level signpost
		even
Art_BigRing:	incbin	"artunc\Giant Ring.bin"
		even
Art_RedRing:	incbin	"artunc\Red Ring.bin"
		even


		include	"_maps\Shield and Invincibility.asm"
		include "_maps\Shield - Dynamic Gfx Script.asm" ; AND INVINCIBILITY
		include "_maps\Shield - Flame.asm"
		include "_maps\Shield - Flame - Dynamic Gfx Script.asm"
		include "_maps\Shield - Bubble.asm"
		include "_maps\Shield - Bubble - Dynamic Gfx Script.asm"
		include "_maps\Shield - Lightning.asm"
		include "_maps\Shield - Lightning - Dynamic Gfx Script.asm"
		include "_maps\Shield - Insta.asm"
		include "_maps\Shield - Insta - Dynamic Gfx Script.asm"

		include "_maps\Effects.asm"
		include "_maps\Effects - Dynamic Gfx Script.asm"


		include "_maps\Red Ring.asm"
		include "_maps\Red Ring - DPLC.asm"
		include "_maps\Emerald.asm"

		include	"_maps\SS Walls.asm"

; ---------------------------------------------------------------------------
; Compressed graphics - special stage
; ---------------------------------------------------------------------------
Art_SSWalls:	incbin	"artunc\Special Walls.bin" ; special stage walls
		even
Eni_SSBg1:	incbin	"tilemaps\SS Background 1.bin" ; special stage background (mappings)
		even
Nem_SSBgFish:	incbin	"artnem\Special Birds & Fish.bin" ; special stage birds and fish background
		even
Eni_SSBg2:	incbin	"tilemaps\SS Background 2.bin" ; special stage background (mappings)
		even
Nem_SSBumper:	incbin	"artnem\Special Bumper.bin" ; special stage bumper art
		even
Nem_SSBgCloud:	incbin	"artnem\Special Clouds.bin" ; special stage clouds background
		even
Nem_SSGOAL:	incbin	"artnem\Special GOAL.bin" ; special stage GOAL block
		even
Nem_SSRBlock:	incbin	"artnem\Special R.bin"	; special stage R block
		even
Nem_SS1UpBlock:	incbin	"artnem\Special 1UP.bin" ; special stage 1UP block
		even
Nem_SSEmStars:	incbin	"artnem\Special Emerald Twinkle.bin" ; special stage stars from a collected emerald
		even
Nem_SSRedWhite:	incbin	"artnem\Special Red-White.bin" ; special stage red/white block
		even
Nem_SSZone1:	incbin	"artnem\Special ZONE1.bin" ; special stage ZONE1 block
		even
Nem_SSZone2:	incbin	"artnem\Special ZONE2.bin" ; ZONE2 block
		even
Nem_SSZone3:	incbin	"artnem\Special ZONE3.bin" ; ZONE3 block
		even
Nem_SSZone4:	incbin	"artnem\Special ZONE4.bin" ; ZONE4 block
		even
Nem_SSZone5:	incbin	"artnem\Special ZONE5.bin" ; ZONE5 block
		even
Nem_SSZone6:	incbin	"artnem\Special ZONE6.bin" ; ZONE6 block
		even
Nem_SSUpDown:	incbin	"artnem\Special UP-DOWN.bin" ; special stage UP/DOWN block
		even
Nem_SSEmerald:	incbin	"artnem\Special Emeralds.bin" ; special stage chaos emeralds
		even
Nem_SSGhost:	incbin	"artnem\Special Ghost.bin" ; special stage ghost block
		even
Nem_SSWBlock:	incbin	"artnem\Special W.bin"	; special stage W block
		even
Nem_SSGlass:	incbin	"artnem\Special Glass.bin" ; special stage destroyable glass block
		even
Nem_ResultEm:	incbin	"artnem\Special Result Emeralds.bin" ; chaos emeralds on special stage results screen
		even
; ---------------------------------------------------------------------------
; Compressed graphics - GHZ stuff
; ---------------------------------------------------------------------------
Nem_Stalk:		incbin	"artnem\GHZ Flower Stalk.bin"
		even
Nem_Swing:		incbin	"artnem\GHZ Swinging Platform.bin"
		even
Nem_Bridge:		incbin	"artnem\GHZ Bridge.bin"
		even
Nem_Ball:		incbin	"artnem\GHZ Giant Ball.bin"
		even
Nem_Spikes:		incbin	"artnem\Spikes.bin"
		even
Nem_GhzLog:		incbin	"artnem\Unused - GHZ Log.bin"
		even
Nem_SpikePole:	incbin	"artnem\GHZ Spiked Log.bin"
		even
Nem_PplRock:	incbin	"artnem\GHZ Purple Rock.bin"
		even
Nem_GhzWall1:	incbin	"artnem\GHZ Breakable Wall.bin"
		even
Nem_GhzWall2:	incbin	"artnem\GHZ Edge Wall.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - LZ stuff
; ---------------------------------------------------------------------------
Nem_WaterSurface:	incbin	"artnem\LZ Water Surface.bin"
		even
Nem_Waterfall:		incbin	"artnem\LZ Water & Splashes.bin"
		even
;Nem_Splash:	incbin	"artnem\Water Splash.bin"
;		even
Nem_LzSpikeBall:incbin	"artnem\LZ Spiked Ball & Chain.bin"
		even
Nem_FlapDoor:	incbin	"artnem\LZ Flapping Door.bin"
		even
Nem_Bubbles:	incbin	"artnem\LZ Bubbles & Countdown.bin"
		even
Nem_LzBlock3:	incbin	"artnem\LZ 32x16 Block.bin"
		even
Nem_LzDoor1:	incbin	"artnem\LZ Vertical Door.bin"
		even
Nem_Harpoon:	incbin	"artnem\LZ Harpoon.bin"
		even
Nem_LzPole:		incbin	"artnem\LZ Breakable Pole.bin"
		even
Nem_LzDoor2:	incbin	"artnem\LZ Horizontal Door.bin"
		even
Nem_LzWheel:	incbin	"artnem\LZ Wheel.bin"
		even
Nem_Gargoyle:	incbin	"artnem\LZ Gargoyle & Fireball.bin"
		even
Nem_LzBlock2:	incbin	"artnem\LZ Blocks.bin"
		even
Nem_LzPlatfm:	incbin	"artnem\LZ Rising Platform.bin"
		even
Nem_Cork:		incbin	"artnem\LZ Cork.bin"
		even
Nem_LzBlock1:	incbin	"artnem\LZ 32x32 Block.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - MZ stuff
; ---------------------------------------------------------------------------
Nem_MzMetal:	incbin	"artnem\MZ Metal Blocks.bin"
		even
Nem_MzSwitch:	incbin	"artnem\MZ Switch.bin"
		even
Nem_MzGlass:	incbin	"artnem\MZ Green Glass Block.bin"
		even
Nem_UnkGrass:	incbin	"artnem\Unused - Grass.bin"
		even
Nem_MzFire:		incbin	"artnem\Fireballs.bin"
		even
Nem_Lava:		incbin	"artnem\MZ Lava.bin"
		even
Nem_MzBlock:	incbin	"artnem\MZ Green Pushable Block.bin"
		even
Nem_MzUnkBlock:	incbin	"artnem\Unused - MZ Background.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SLZ stuff
; ---------------------------------------------------------------------------
Nem_Seesaw:		incbin	"artnem\SLZ Seesaw.bin"
		even
Nem_SlzSpike:	incbin	"artnem\SLZ Little Spikeball.bin"
		even
Nem_Fan:		incbin	"artnem\SLZ Fan.bin"
		even
Nem_SlzWall:	incbin	"artnem\SLZ Breakable Wall.bin"
		even
Nem_Pylon:		incbin	"artnem\SLZ Pylon.bin"
		even
Nem_SlzSwing:	incbin	"artnem\SLZ Swinging Platform.bin"
		even
Nem_SlzBlock:	incbin	"artnem\SLZ 32x32 Block.bin"
		even
Nem_SlzCannon:	incbin	"artnem\SLZ Cannon.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SYZ stuff
; ---------------------------------------------------------------------------
Nem_Bumper:		incbin	"artnem\SYZ Bumper.bin"
		even
Nem_SyzSpike2:	incbin	"artnem\SYZ Small Spikeball.bin"
		even
Nem_LzSwitch:	incbin	"artnem\Switch.bin"
		even
Nem_SyzSpike1:	incbin	"artnem\SYZ Large Spikeball.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SBZ stuff
; ---------------------------------------------------------------------------
Nem_SbzWheel1:	incbin	"artnem\SBZ Running Disc.bin"
		even
Nem_SbzWheel2:	incbin	"artnem\SBZ Junction Wheel.bin"
		even
Nem_Cutter:		incbin	"artnem\SBZ Pizza Cutter.bin"
		even
Nem_Stomper:	incbin	"artnem\SBZ Stomper.bin"
		even
Nem_SpinPform:	incbin	"artnem\SBZ Spinning Platform.bin"
		even
Nem_TrapDoor:	incbin	"artnem\SBZ Trapdoor.bin"
		even
Nem_SbzFloor:	incbin	"artnem\SBZ Collapsing Floor.bin"
		even
Nem_Electric:	incbin	"artnem\SBZ Electrocuter.bin"
		even
Nem_SbzBlock:	incbin	"artnem\SBZ Vanishing Block.bin"
		even
Nem_FlamePipe:	incbin	"artnem\SBZ Flaming Pipe.bin"
		even
Nem_SbzDoor1:	incbin	"artnem\SBZ Small Vertical Door.bin"
		even
Nem_SlideFloor:	incbin	"artnem\SBZ Sliding Floor Trap.bin"
		even
Nem_SbzDoor2:	incbin	"artnem\SBZ Large Horizontal Door.bin"
		even
Nem_Girder:		incbin	"artnem\SBZ Crushing Girder.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - enemies
; ---------------------------------------------------------------------------
Nem_BallHog:	incbin	"artnem\Enemy Ball Hog.bin"
		even
Nem_Crabmeat:	incbin	"artnem\Enemy Crabmeat.bin"
		even
Nem_Buzz:		incbin	"artnem\Enemy Buzz Bomber.bin"
		even
Nem_UnkExplode:	incbin	"artnem\Unused - Explosion.bin"
		even
Nem_Burrobot:	incbin	"artnem\Enemy Burrobot.bin"
		even
Nem_Chopper:	incbin	"artnem\Enemy Chopper.bin"
		even
Nem_Jaws:		incbin	"artnem\Enemy Jaws.bin"
		even
Nem_Roller:		incbin	"artnem\Enemy Roller.bin"
		even
Nem_Motobug:	incbin	"artnem\Enemy Motobug.bin"
		even
Nem_Newtron:	incbin	"artnem\Enemy Newtron.bin"
		even
Nem_Yadrin:		incbin	"artnem\Enemy Yadrin.bin"
		even
Nem_Basaran:	incbin	"artnem\Enemy Basaran.bin"
		even
Nem_Splats:		incbin	"artnem\Enemy Splats.bin"
		even
Nem_Bomb:		incbin	"artnem\Enemy Bomb.bin"
		even
Nem_Orbinaut:	incbin	"artnem\Enemy Orbinaut.bin"
		even
Nem_Cater:		incbin	"artnem\Enemy Caterkiller.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
Art_TitleCard:	incbin	"artunc\Title Cards.bin"
Art_TitleCard_End:		even
Nem_Hud:		incbin	"artnem\HUD.bin"	; HUD (score, time, rings)
		even
Nem_Hud_SS:		incbin	"artnem\HUD - SS.bin"	; HUD (time, rings)
		even
Nem_Lives:		incbin	"artnem\HUD - Life Counter Icon.bin"
		even
Nem_Ring:		incbin	"artnem\Rings.bin"
		even
Nem_Monitors:	incbin	"artnem\Monitors.bin"
		even
Nem_Explode:	incbin	"artnem\Explosion.bin"
		even
Nem_Points:		incbin	"artnem\Points.bin"	; points from destroyed enemy or object
		even
Nem_GameOver:	incbin	"artnem\Game Over.bin"	; game over / time over
		even
Nem_HSpring:	incbin	"artnem\Spring Horizontal.bin"
		even
Nem_VSpring:	incbin	"artnem\Spring Vertical.bin"
		even
Nem_Lamp:		incbin	"artnem\Lamppost.bin"
		even
Nem_BigFlash:	incbin	"artnem\Giant Ring Flash.bin"
		even
Nem_Bonus:		incbin	"artnem\Hidden Bonuses.bin" ; hidden bonuses at end of a level
		even
Nem_ChaosEm:	incbin	"artnem\Emerald.bin" ; Chaos Emerald found in levels
		even
; ---------------------------------------------------------------------------
; Compressed graphics - continue screen
; ---------------------------------------------------------------------------
Nem_ContSonic:	incbin	"artnem\Continue Screen Sonic.bin"
		even
Nem_MiniSonic:	incbin	"artnem\Continue Screen Stuff.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - animals
; ---------------------------------------------------------------------------
Nem_Rabbit:	incbin	"artnem\Animal Rabbit.bin"
		even
Nem_Chicken:	incbin	"artnem\Animal Chicken.bin"
		even
Nem_BlackBird:	incbin	"artnem\Animal Blackbird.bin"
		even
Nem_Seal:	incbin	"artnem\Animal Seal.bin"
		even
Nem_Pig:	incbin	"artnem\Animal Pig.bin"
		even
Nem_Flicky:	incbin	"artnem\Animal Flicky.bin"
		even
Nem_Squirrel:	incbin	"artnem\Animal Squirrel.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
Nem_Title:		incbin	"artnem\Title Screen Background.bin"	; Title patterns
		even
LvlArt_GHZ:		incbin	"lvlart\GHZ.bin"	; GHZ primary patterns
		even
Blk16_GHZ:		incbin	"map16\GHZ.bin"
		even
Blk128_GHZ:		incbin	"map128\GHZ.bin"
		even
LvlArt_LZ:		incbin	"lvlart\LZ.bin"		; LZ primary patterns
		even
Blk16_LZ:		incbin	"map16\LZ.bin"
		even
Blk128_LZ:		incbin	"map128\LZ.bin"
		even
LvlArt_MZ:		incbin	"lvlart\MZ.bin"		; MZ primary patterns
		even
Blk16_MZ:		incbin	"map16\MZ.bin"
		even
Blk128_MZ:		incbin	"map128\MZ.bin"
		even
LvlArt_SLZ:		incbin	"lvlart\SLZ.bin" 	; SLZ primary patterns
		even
Blk16_SLZ:		incbin	"map16\SLZ.bin"
		even
Blk128_SLZ:		incbin	"map128\SLZ.bin"
		even
LvlArt_SYZ:		incbin	"lvlart\SYZ.bin"	; SYZ primary patterns
		even
Blk16_SYZ:		incbin	"map16\SYZ.bin"
		even
Blk128_SYZ:		incbin	"map128\SYZ.bin"
		even
LvlArt_SBZ:		incbin	"lvlart\SBZ.bin"	; SBZ primary patterns
		even
Blk16_SBZ:		incbin	"map16\SBZ.bin"
		even
Blk128_SBZ:		incbin	"map128\SBZ.bin"
		even
LvlArt_SBZ3:	incbin	"lvlart\SBZ3.bin"	; SBZ Act 3 primary patterns
		even
Blk16_SBZ3:		incbin	"map16\SBZ3.bin"
		even
Blk128_SBZ3:	incbin	"map128\SBZ3.bin"
		even
LvlArt_BZ:		incbin	"lvlart\BZ.bin"	; BZ primary patterns
		even
Blk16_BZ:		incbin	"map16\BZ.bin"
		even
Blk128_BZ:		incbin	"map128\BZ.bin"
		even
LvlArt_JZ:		incbin	"lvlart\JZ.bin"	; JZ primary patterns
		even
Blk16_JZ:		incbin	"map16\JZ.bin"
		even
Blk128_JZ:		incbin	"map128\JZ.bin"
		even
LvlArt_SKBZ:	incbin	"lvlart\SKBZ.bin"	; SKBZ primary patterns
		even
Blk16_SKBZ:		incbin	"map16\SKBZ.bin"
		even
Blk128_SKBZ:	incbin	"map128\SKBZ.bin"
		even
; ---------------------------------------------------------------------------
; Compressed graphics - bosses and ending sequence
; ---------------------------------------------------------------------------
Nem_Eggman:		incbin	"artnem\Boss - Main.bin"
		even
Nem_Eggman_Alt: incbin	"artnem\Boss - Alt Bosses.bin"
		even
Nem_Weapons:	incbin	"artnem\Boss - Weapons.bin"
		even
Nem_Prison:		incbin	"artnem\Prison Capsule.bin"
		even
Nem_Sbz2Eggman:	incbin	"artnem\Boss - Eggman in SBZ2 & FZ.bin"
		even
Nem_FzBoss:		incbin	"artnem\Boss - Final Zone.bin"
		even
Nem_FzEggman:	incbin	"artnem\Boss - Eggman after FZ Fight.bin"
		even
Nem_Exhaust:	incbin	"artnem\Boss - Exhaust Flame.bin"
		even
Nem_EndEm:		incbin	"artnem\Ending - Emeralds.bin"
		even
Nem_EndSonic:	incbin	"artnem\Ending - Sonic.bin"
		even
Nem_TryAgain:	incbin	"artnem\Ending - Try Again.bin"
		even
Kos_EndFlowers:	incbin	"artkos\Flowers at Ending.bin" ; ending sequence animated flowers
		even
Nem_EndFlower:	incbin	"artnem\Ending - Flowers.bin"
		even
Nem_CreditText:	incbin	"artnem\Ending - Credits.bin"
		even
Nem_EndStH:		incbin	"artnem\Ending - StH Logo.bin"
		even

		dcb.b $40,$FF

; ---------------------------------------------------------------------------
; Collision data
; ---------------------------------------------------------------------------
AngleMap:	incbin	"collide\Angle Map.bin"
		even
CollArray1:	incbin	"collide\Collision Array (Normal).bin"
		even
CollArray2:	incbin	"collide\Collision Array (Rotated).bin"
		even
Col_GHZ_1:	incbin	"collide\GHZ1.bin"	; GHZ index 1
		even
Col_GHZ_2:	incbin	"collide\GHZ2.bin"	; GHZ index 2
		even
Col_LZ_1:	incbin	"collide\LZ1.bin"	; LZ index 1
		even
Col_LZ_2:	incbin	"collide\LZ2.bin"	; LZ index 2
		even
Col_MZ_1:	incbin	"collide\MZ1.bin"	; MZ index 1
		even
Col_MZ_2:	incbin	"collide\MZ2.bin"	; MZ index 2
		even
Col_SLZ_1:	incbin	"collide\SLZ1.bin"	; SLZ index 1
		even
Col_SLZ_2:	incbin	"collide\SLZ2.bin"	; SLZ index 2
		even
Col_SYZ_1:	incbin	"collide\SYZ1.bin"	; SYZ index 1
		even
Col_SYZ_2:	incbin	"collide\SYZ2.bin"	; SYZ index 2
		even
Col_SBZ_1:	incbin	"collide\SBZ1.bin"	; SBZ index 1
		even
Col_SBZ_2:	incbin	"collide\SBZ2.bin"	; SBZ index 2
		even
Col_BZ_1:	incbin	"collide\BZ1.bin"	; BZ index 1
		even
Col_BZ_2:	incbin	"collide\BZ2.bin"	; BZ index 2
		even
Col_JZ_1:	incbin	"collide\JZ1.bin"	; JZ index 1
		even
Col_JZ_2:	incbin	"collide\JZ2.bin"	; JZ index 2
		even
Col_SKBZ_1:	incbin	"collide\SKBZ1.bin"	; SKBZ index 1
		even
Col_SKBZ_2:	incbin	"collide\SKBZ2.bin"	; SKBZ index 2
		even
; ---------------------------------------------------------------------------
; Special Stage layouts
; ---------------------------------------------------------------------------
SS_1:		incbin	"sslayout\1.bin"
		even
SS_2:		incbin	"sslayout\2.bin"
		even
SS_3:		incbin	"sslayout\3.bin"
		even
SS_4:		incbin	"sslayout\4.bin"
		even
SS_5:		incbin	"sslayout\5.bin"
		even
SS_6:		incbin	"sslayout\6.bin"
		even
; ---------------------------------------------------------------------------
; Animated uncompressed graphics
; ---------------------------------------------------------------------------
Art_GhzWater:	incbin	"artunc\GHZ Waterfall.bin"
		even
Art_GhzFlower1:	incbin	"artunc\GHZ Flower Large.bin"
		even
Art_GhzFlower2:	incbin	"artunc\GHZ Flower Small.bin"
		even
Art_MzLava1:	incbin	"artunc\MZ Lava Surface.bin"
		even
Art_MzLava2:	incbin	"artunc\MZ Lava.bin"
		even
Art_MzTorch:	incbin	"artunc\MZ Background Torch.bin"
		even
Art_SbzSmoke:	incbin	"artunc\SBZ Background Smoke.bin"
		even

; ---------------------------------------------------------------------------
; Level	order arrays
; ---------------------------------------------------------------------------
LevelOrder_Classic:
		; Green Hill Zone
		dc.w id_GHZ2, id_GHZ3, id_MZ1, id_MZ1
		; Labyrinth Zone
		dc.w id_LZ2, id_LZ3, id_SLZ1, id_SBZF ; Act 4 is SBZ3
		; Marble Zone
		dc.w id_MZ2, id_MZ3, id_SYZ1, id_SYZ1
		; Star Light Zone
		dc.w id_SLZ2, id_SLZ3, id_SBZ1, id_SBZ1
		; Spring Yard Zone
		dc.w id_SYZ2, id_SYZ3, id_LZ1, id_LZ1
		; Scrap Brain Zone
		dc.w id_SBZ2, id_SBZ3, 0, 0
		; Bridge/Jungle/Sky Base Zone
		dc.l 0, 0, 0, 0, 0, 0
		even
LevelOrderEasy_Classic:
		; Green Hill Zone
		dc.w id_GHZ2, id_MZ1, id_MZ1, id_MZ1
		; Labyrinth Zone
		dc.w id_LZ2, id_SLZ1, id_SLZ1, id_SBZF ; Act 4 is SBZ3
		; Marble Zone
		dc.w id_MZ2, id_SYZ1, id_SYZ1, id_SYZ1
		; Star Light Zone
		dc.w id_SLZ2, id_SBZ1, id_SBZ1, id_SBZ1
		; Spring Yard Zone
		dc.w id_SYZ2, id_LZ1, id_LZ1, id_LZ1
		; Scrap Brain Zone
		dc.w id_SBZ2, id_SBZ3, 0, 0
		; Bridge/Jungle/Sky Base Zone
		dc.l 0, 0, 0, 0, 0, 0
		even
LevelOrder_Original:
		; Green Hill Zone
		dc.w id_GHZ2, id_GHZ3, id_LZ1, id_LZ1
		; Labyrinth Zone
		dc.w id_LZ2, id_LZ3, id_MZ1, id_SBZF ; Act 4 is SBZ3
		; Marble Zone
		dc.w id_MZ2, id_MZ3, id_SLZ1, id_SLZ1
		; Star Light Zone
		dc.w id_SLZ2, id_SLZ3, id_SYZ1, id_SYZ1
		; Spring Yard Zone
		dc.w id_SYZ2, id_SYZ3, id_SBZ1, id_SBZ1
		; Scrap Brain Zone
		dc.w id_SBZ2, id_SBZ3, 0, 0
		; Bridge/Jungle/Sky Base Zone
		dc.l 0, 0, 0, 0, 0, 0
		even
LevelOrderEasy_Original:
		; Green Hill Zone
		dc.w id_GHZ2, id_LZ1, id_LZ1, id_LZ1
		; Labyrinth Zone
		dc.w id_LZ2, id_MZ1, id_MZ1, id_SBZF ; Act 4 is SBZ3
		; Marble Zone
		dc.w id_MZ2, id_SLZ1, id_SLZ1, id_SLZ1
		; Star Light Zone
		dc.w id_SLZ2, id_SYZ1, id_SYZ1, id_SYZ1
		; Spring Yard Zone
		dc.w id_SYZ2, id_SBZ1, id_SBZ1, id_SBZ1
		; Scrap Brain Zone
		dc.w id_SBZ2, id_SBZ3, 0, 0
		; Bridge/Jungle/Sky Base Zone
		dc.l 0, 0, 0, 0, 0, 0
		even
LevelOrder_Handheld:
		; Green Hill Zone
		dc.w id_GHZ2, id_GHZ3, id_BZ1, id_BZ1
		; Labyrinth Zone
		dc.w id_LZ2, id_LZ3, id_SBZ1, id_SBZF ; Act 4 is SBZ3
		; Marble/Star Light/Spring Yard Zone
		dc.l 0, 0, 0, 0, 0, 0
		; Scrap Brain Zone
		dc.w id_SBZ2, id_SBZ3, id_SKBZ1, id_SKBZ1
		; Bridge Zone
		dc.w id_BZ2, id_BZ3, id_JZ1, id_JZ1
		; Jungle Zone
		dc.w id_JZ2, id_JZ3, id_LZ1, id_LZ1
		; Sky Base Zone
		dc.w id_SKBZ2, id_SKBZ3, 0, 0
		even
LevelOrderEasy_Handheld:
		; Green Hill Zone
		dc.w id_GHZ2, id_BZ1, id_BZ1, id_BZ1
		; Labyrinth Zone
		dc.w id_LZ2, id_SBZ1, id_SBZ1, id_SBZF ; Act 4 is SBZ3
		; Marble/Star Light/Spring Yard Zone
		dc.l 0, 0, 0, 0, 0, 0
		; Scrap Brain Zone
		dc.w id_SBZ2, id_SKBZ1, id_SKBZ1, id_SKBZ1
		; Bridge Zone
		dc.w id_BZ2, id_JZ1, id_JZ1, id_JZ1
		; Jungle Zone
		dc.w id_JZ2, id_LZ1, id_LZ1, id_LZ1
		; Sky Base Zone
		dc.w id_SKBZ2, 0, 0, 0
		even
LevelOrder_Complete:
		; Green Hill Zone
		dc.w id_GHZ2, id_GHZ3, id_BZ1, id_BZ1
		; Labyrinth Zone
		dc.w id_LZ2, id_LZ3, id_SLZ1, id_SBZF ; Act 4 is SBZ3
		; Marble Zone
		dc.w id_MZ2, id_MZ3, id_SYZ1, id_SYZ1
		; Star Light Zone
		dc.w id_SLZ2, id_SLZ3, id_SBZ1, id_SBZ1
		; Spring Yard Zone
		dc.w id_SYZ2, id_SYZ3, id_JZ1, id_JZ1
		; Scrap Brain Zone
		dc.w id_SBZ2, id_SBZ3, id_SKBZ1, id_SKBZ1
		; Bridge Zone
		dc.w id_BZ2, id_BZ3, id_MZ1, id_MZ1
		; Jungle Zone
		dc.w id_JZ2, id_JZ3, id_LZ1, id_LZ1
		; Sky Base Zone
		dc.w id_SKBZ2, id_SKBZ3, 0, 0
		even
LevelOrderEasy_Complete:
		; Green Hill Zone
		dc.w id_GHZ2, id_BZ1, id_BZ1, id_BZ1
		; Labyrinth Zone
		dc.w id_LZ2, id_SLZ1, id_SLZ1, id_SBZF ; Act 4 is SBZ3
		; Marble Zone
		dc.w id_MZ2, id_SYZ1, id_SYZ1, id_SYZ1
		; Star Light Zone
		dc.w id_SLZ2, id_SBZ1, id_SBZ1, id_SBZ1
		; Spring Yard Zone
		dc.w id_SYZ2, id_JZ1, id_JZ1, id_JZ1
		; Scrap Brain Zone
		dc.w id_SBZ2, id_SKBZ1, id_SKBZ1, id_SKBZ1
		; Bridge Zone
		dc.w id_BZ2, id_MZ1, id_MZ1, id_MZ1
		; Jungle Zone
		dc.w id_JZ2, id_LZ1, id_LZ1, id_LZ1
		; Sky Base Zone
		dc.w id_SKBZ2, 0, 0, 0
		even
; ===========================================================================

; ---------------------------------------------------------------------------
; Level	layout index
; Added chunk layout locations for each difficulty
; Every difficulty is 4 bytes apart
; Every act is now $10 bytes apart
; Every zone is $40 bytes apart
; ---------------------------------------------------------------------------

Level_Index:
		dc.l Level_GHZ1, Level_GHZ1E, Level_GHZ1H, Level_Null
		dc.l Level_GHZ2, Level_GHZ2E, Level_GHZ2H, Level_Null
		dc.l Level_GHZ3, Level_GHZ2E, Level_GHZ3H, Level_Null
		dc.l Level_GHZ1, Level_GHZ1E, Level_GHZ1H, Level_Null

		dc.l Level_LZ1, Level_LZ1E, Level_LZ1H, Level_Null
		dc.l Level_LZ2, Level_LZ2E, Level_LZ2H, Level_Null
		dc.l Level_LZ3, Level_LZ2E, Level_LZ3H, Level_Null
		dc.l Level_SBZ3, Level_SBZ3, Level_SBZ3H, Level_Null

		dc.l Level_MZ1, Level_MZ1E, Level_MZ1H, Level_Null
		dc.l Level_MZ2, Level_MZ2E, Level_MZ2H, Level_Null
		dc.l Level_MZ3, Level_MZ2E, Level_MZ3H, Level_Null
		dc.l Level_MZ1, Level_MZ1E, Level_MZ1H, Level_Null

		dc.l Level_SLZ1, Level_SLZ1E, Level_SLZ1H, Level_Null
		dc.l Level_SLZ2, Level_SLZ2E, Level_SLZ2H, Level_Null
		dc.l Level_SLZ3, Level_SLZ2E, Level_SLZ3H, Level_Null
		dc.l Level_SLZ1, Level_SLZ1E, Level_SLZ1H, Level_Null

		dc.l Level_SYZ1, Level_SYZ1E, Level_SYZ1H, Level_Null
		dc.l Level_SYZ2, Level_SYZ2E, Level_SYZ2H, Level_Null
		dc.l Level_SYZ3, Level_SYZ2E, Level_SYZ3H, Level_Null
		dc.l Level_SYZ1, Level_SYZ1E, Level_SYZ1H, Level_Null

		dc.l Level_SBZ1, Level_SBZ1E, Level_SBZ1H, Level_Null
		dc.l Level_SBZ2, Level_SBZ2E, Level_SBZ2H, Level_Null
		dc.l Level_SBZ2, Level_SBZ2E, Level_SBZ2H, Level_Null
		dc.l Level_SBZ1, Level_SBZ1E, Level_SBZ1H, Level_Null

		dc.l Level_End, Level_End, Level_End, Level_Null
		dc.l Level_End, Level_End, Level_End, Level_Null
		dc.l Level_Null, Level_Null, Level_Null, Level_Null
		dc.l Level_Null, Level_Null, Level_Null, Level_Null

		dc.l Level_BZ1, Level_BZ1E, Level_BZ1H, Level_Null
		dc.l Level_BZ2, Level_BZ2E, Level_BZ2H, Level_Null
		dc.l Level_BZ3, Level_BZ2E, Level_BZ3H, Level_Null
		dc.l Level_BZ1, Level_BZ1E, Level_BZ1H, Level_Null

		dc.l Level_JZ1, Level_JZ1E, Level_JZ1H, Level_Null
		dc.l Level_JZ2, Level_JZ2E, Level_JZ2H, Level_Null
		dc.l Level_JZ3, Level_JZ2E, Level_JZ3H, Level_Null
		dc.l Level_JZ1, Level_JZ1E, Level_JZ1H, Level_Null

		dc.l Level_SKBZ1, Level_SKBZ1E, Level_SKBZ1H, Level_Null
		dc.l Level_SKBZ2, Level_SKBZ2E, Level_SKBZ2H, Level_Null
		dc.l Level_SKBZ3, Level_SKBZ2E, Level_SKBZ3H, Level_Null
		dc.l Level_SKBZ1, Level_SKBZ1E, Level_SKBZ1H, Level_Null

Level_Null:

Level_GHZ1:	incbin	levels\ghz1.bin
		even
Level_GHZ1E:	incbin	levels\ghz1e.bin
		even
Level_GHZ1H:	incbin	levels\ghz1h.bin
		even
Level_GHZ2:	incbin	levels\ghz2.bin
		even
Level_GHZ2E:	incbin	levels\ghz2e.bin
		even
Level_GHZ2H:	incbin	levels\ghz2h.bin
		even
Level_GHZ3:	incbin	levels\ghz3.bin
		even
Level_GHZ3H:	incbin	levels\ghz3h.bin
		even
Level_LZ1:	incbin	levels\lz1.bin
		even
Level_LZ1E:	incbin	levels\lz1e.bin
		even
Level_LZ1H:	incbin	levels\lz1h.bin
		even
Level_LZ2:	incbin	levels\lz2.bin
		even
Level_LZ2E:	incbin	levels\lz2e.bin
		even
Level_LZ2H:	incbin	levels\lz2h.bin
		even
Level_LZ3NoWall:	incbin	levels\lz3_nowall.bin
		even
Level_LZ3HNoWall:	incbin	levels\lz3h_nowall.bin
		even
Level_LZ3:	incbin	levels\lz3_wall.bin
		even
Level_LZ3H:	incbin	levels\lz3h_wall.bin
		even
Level_SBZ3:	incbin	levels\sbz3.bin
		even
Level_SBZ3H:	incbin	levels\sbz3h.bin
		even
Level_MZ1:	incbin	levels\mz1.bin
		even
Level_MZ1E:	incbin	levels\mz1e.bin
		even
Level_MZ1H:	incbin	levels\mz1h.bin
		even
Level_MZ2:	incbin	levels\mz2.bin
		even
Level_MZ2E:	incbin	levels\mz2e.bin
		even
Level_MZ2H:	incbin	levels\mz2h.bin
		even
Level_MZ3:	incbin	levels\mz3.bin
		even
Level_MZ3H:	incbin	levels\mz3h.bin
		even
Level_SLZ1:	incbin	levels\slz1.bin
		even
Level_SLZ1E:	incbin	levels\slz1e.bin
		even
Level_SLZ1H:	incbin	levels\slz1h.bin
		even
Level_SLZ2:	incbin	levels\slz2.bin
		even
Level_SLZ2E:	incbin	levels\slz2e.bin
		even
Level_SLZ2H:	incbin	levels\slz2h.bin
		even
Level_SLZ3:	incbin	levels\slz3.bin
		even
Level_SLZ3H:	incbin	levels\slz3h.bin
		even
Level_SYZ1:	incbin	levels\syz1.bin
		even
Level_SYZ1E:	incbin	levels\syz1e.bin
		even
Level_SYZ1H:	incbin	levels\syz1h.bin
		even
Level_SYZ2:	incbin	levels\syz2.bin
		even
Level_SYZ2E:	incbin	levels\syz2e.bin
		even
Level_SYZ2H:	incbin	levels\syz2h.bin
		even
Level_SYZ3:	incbin	levels\syz3.bin
		even
Level_SYZ3H:	incbin	levels\syz3h.bin
		even
Level_SBZ1:	incbin	levels\sbz1.bin
		even
Level_SBZ1E:	incbin	levels\sbz1e.bin
		even
Level_SBZ1H:	incbin	levels\sbz1h.bin
		even
Level_SBZ2:	incbin	levels\sbz2.bin
		even
Level_SBZ2E:	incbin	levels\sbz2e.bin
		even
Level_SBZ2H:	incbin	levels\sbz2h.bin
		even
Level_End:	incbin	levels\ending.bin
		even
Level_EndGood:	incbin	levels\ending_good.bin
		even
Level_BZ1:	incbin	levels\bz1.bin
		even
Level_BZ1E:	incbin	levels\bz1e.bin
		even
Level_BZ1H:	incbin	levels\bz1h.bin
		even
Level_BZ2:	incbin	levels\bz2.bin
		even
Level_BZ2E:	incbin	levels\bz2e.bin
		even
Level_BZ2H:	incbin	levels\bz2h.bin
		even
Level_BZ3:	incbin	levels\bz3.bin
		even
Level_BZ3H:	incbin	levels\bz3h.bin
		even
Level_JZ1:	incbin	levels\jz1.bin
		even
Level_JZ1E:	incbin	levels\jz1e.bin
		even
Level_JZ1H:	incbin	levels\jz1h.bin
		even
Level_JZ2:	incbin	levels\jz2.bin
		even
Level_JZ2E:	incbin	levels\jz2e.bin
		even
Level_JZ2H:	incbin	levels\jz2h.bin
		even
Level_JZ3:	incbin	levels\jz3.bin
		even
Level_JZ3H:	incbin	levels\jz3h.bin
		even
Level_SKBZ1:	incbin	levels\skbz1.bin
		even
Level_SKBZ1E:	incbin	levels\skbz1e.bin
		even
Level_SKBZ1H:	incbin	levels\skbz1h.bin
		even
Level_SKBZ2:	incbin	levels\skbz2.bin
		even
Level_SKBZ2E:	incbin	levels\skbz2e.bin
		even
Level_SKBZ2H:	incbin	levels\skbz2h.bin
		even
Level_SKBZ3:	incbin	levels\skbz3.bin
		even
Level_SKBZ3H:	incbin	levels\skbz3h.bin
		even

		align	$100,$FF

; ---------------------------------------------------------------------------
; Object locations index
; Added object locations for each difficulty
; Every difficulty is 4 bytes apart
; Every act is now $10 bytes apart
; Every zone is $40 bytes apart
; ---------------------------------------------------------------------------
ObjPos_Index:
		dc.l ObjPos_GHZ1, ObjPos_GHZ1E, ObjPos_GHZ1H, ObjPos_Null
		dc.l ObjPos_GHZ2, ObjPos_GHZ2E, ObjPos_GHZ2H, ObjPos_Null
		dc.l ObjPos_GHZ3, ObjPos_GHZ1E, ObjPos_GHZ3H, ObjPos_Null
		dc.l ObjPos_GHZ1, ObjPos_GHZ2E, ObjPos_GHZ1H, ObjPos_Null

		dc.l ObjPos_LZ1, ObjPos_LZ1E, ObjPos_LZ1H, ObjPos_Null
		dc.l ObjPos_LZ2, ObjPos_LZ2E, ObjPos_LZ2H, ObjPos_Null
		dc.l ObjPos_LZ3, ObjPos_LZ2E, ObjPos_LZ3H, ObjPos_Null
		dc.l ObjPos_SBZ3, ObjPos_SBZ3, ObjPos_SBZ3H, ObjPos_Null

		dc.l ObjPos_MZ1, ObjPos_MZ1E, ObjPos_MZ1H, ObjPos_Null
		dc.l ObjPos_MZ2, ObjPos_MZ2E, ObjPos_MZ2H, ObjPos_Null
		dc.l ObjPos_MZ3, ObjPos_MZ2E, ObjPos_MZ3H, ObjPos_Null
		dc.l ObjPos_MZ1, ObjPos_MZ1E, ObjPos_MZ1H, ObjPos_Null

		dc.l ObjPos_SLZ1, ObjPos_SLZ1E, ObjPos_SLZ1H, ObjPos_Null
		dc.l ObjPos_SLZ2, ObjPos_SLZ2E, ObjPos_SLZ2H, ObjPos_Null
		dc.l ObjPos_SLZ3, ObjPos_SLZ2E, ObjPos_SLZ3H, ObjPos_Null
		dc.l ObjPos_SLZ1, ObjPos_SLZ1E, ObjPos_SLZ1H, ObjPos_Null

		dc.l ObjPos_SYZ1, ObjPos_SYZ1E, ObjPos_SYZ1H, ObjPos_Null
		dc.l ObjPos_SYZ2, ObjPos_SYZ2E, ObjPos_SYZ2H, ObjPos_Null
		dc.l ObjPos_SYZ3, ObjPos_SYZ2E, ObjPos_SYZ3H, ObjPos_Null
		dc.l ObjPos_SYZ1, ObjPos_SYZ1E, ObjPos_SYZ1H, ObjPos_Null

		dc.l ObjPos_SBZ1, ObjPos_SBZ1E, ObjPos_SBZ1H, ObjPos_Null
		dc.l ObjPos_SBZ2, ObjPos_SBZ2E, ObjPos_SBZ2H, ObjPos_Null
		dc.l ObjPos_FZ, ObjPos_FZ, ObjPos_FZ, ObjPos_Null
		dc.l ObjPos_SBZ1, ObjPos_SBZ1E, ObjPos_SBZ1H, ObjPos_Null

		dc.l ObjPos_End, ObjPos_End, ObjPos_End, ObjPos_Null
		dc.l ObjPos_End, ObjPos_End, ObjPos_End, ObjPos_Null
		dc.l ObjPos_End, ObjPos_End, ObjPos_End, ObjPos_Null
		dc.l ObjPos_End, ObjPos_End, ObjPos_End, ObjPos_Null

		dc.l ObjPos_BZ1, ObjPos_BZ1E, ObjPos_BZ1H, ObjPos_Null
		dc.l ObjPos_BZ2, ObjPos_BZ2E, ObjPos_BZ2H, ObjPos_Null
		dc.l ObjPos_BZ3, ObjPos_BZ2E, ObjPos_BZ3H, ObjPos_Null
		dc.l ObjPos_BZ1, ObjPos_BZ1E, ObjPos_BZ1H, ObjPos_Null

		dc.l ObjPos_JZ1, ObjPos_JZ1E, ObjPos_JZ1H, ObjPos_Null
		dc.l ObjPos_JZ2, ObjPos_JZ2E, ObjPos_JZ2H, ObjPos_Null
		dc.l ObjPos_JZ3, ObjPos_JZ2E, ObjPos_JZ3H, ObjPos_Null
		dc.l ObjPos_JZ1, ObjPos_JZ1E, ObjPos_JZ1H, ObjPos_Null

		dc.l ObjPos_SKBZ1, ObjPos_SKBZ1E, ObjPos_SKBZ1H, ObjPos_Null
		dc.l ObjPos_SKBZ2, ObjPos_SKBZ2E, ObjPos_SKBZ2H, ObjPos_Null
		dc.l ObjPos_SKBZ3, ObjPos_SKBZ2E, ObjPos_SKBZ3H, ObjPos_Null
		dc.l ObjPos_SKBZ2, ObjPos_SKBZ1E, ObjPos_SKBZ1H, ObjPos_Null

ObjPosLZPlatform_Index:
		dc.l ObjPos_LZ1pf1, ObjPos_LZ1pf2
		dc.l ObjPos_LZ2pf1, ObjPos_LZ2pf2
		dc.l ObjPos_LZ3pf1, ObjPos_LZ3pf2
		dc.l ObjPos_LZ1pf1, ObjPos_LZ1pf2
ObjPosSBZPlatform_Index:
		dc.l ObjPos_SBZ1pf1, ObjPos_SBZ1pf2
		dc.l ObjPos_SBZ1pf3, ObjPos_SBZ1pf4
		dc.l ObjPos_SBZ1pf5, ObjPos_SBZ1pf6
		dc.l ObjPos_SBZ1pf1, ObjPos_SBZ1pf2

		dc.b $FF, $FF, 0, 0, 0,	0
ObjPos_GHZ1:	incbin	"objpos\ghz1.bin"
		even
ObjPos_GHZ1E:	incbin	"objpos\ghz1e.bin"
		even
ObjPos_GHZ1H:	incbin	"objpos\ghz1h.bin"
		even
ObjPos_GHZ2:	incbin	"objpos\ghz2.bin"
		even
ObjPos_GHZ2E:	incbin	"objpos\ghz2e.bin"
		even
ObjPos_GHZ2H:	incbin	"objpos\ghz2h.bin"
		even
ObjPos_GHZ3:	incbin	"objpos\ghz3.bin"
		even
ObjPos_GHZ3H:	incbin	"objpos\ghz3h.bin"
		even
ObjPos_LZ1:		incbin	"objpos\lz1.bin"
		even
ObjPos_LZ1E:	incbin	"objpos\lz1e.bin"
		even
ObjPos_LZ1H:	incbin	"objpos\lz1h.bin"
		even
ObjPos_LZ2:		incbin	"objpos\lz2.bin"
		even
ObjPos_LZ2E:	incbin	"objpos\lz2e.bin"
		even
ObjPos_LZ2H:	incbin	"objpos\lz2h.bin"
		even
ObjPos_LZ3:		incbin	"objpos\lz3.bin"
		even
ObjPos_LZ3H:	incbin	"objpos\lz3h.bin"
		even
ObjPos_SBZ3:	incbin	"objpos\sbz3.bin"
		even
ObjPos_SBZ3H:	incbin	"objpos\sbz3h.bin"
		even
ObjPos_LZ1pf1:	incbin	"objpos\lz1pf1.bin"
		even
ObjPos_LZ1pf2:	incbin	"objpos\lz1pf2.bin"
		even
ObjPos_LZ2pf1:	incbin	"objpos\lz2pf1.bin"
		even
ObjPos_LZ2pf2:	incbin	"objpos\lz2pf2.bin"
		even
ObjPos_LZ3pf1:	incbin	"objpos\lz3pf1.bin"
		even
ObjPos_LZ3pf2:	incbin	"objpos\lz3pf2.bin"
		even
ObjPos_MZ1:		incbin	"objpos\mz1.bin"
		even
ObjPos_MZ1E:	incbin	"objpos\mz1e.bin"
		even
ObjPos_MZ1H:	incbin	"objpos\mz1h.bin"
		even
ObjPos_MZ2:		incbin	"objpos\mz2.bin"
		even
ObjPos_MZ2E:	incbin	"objpos\mz2e.bin"
		even
ObjPos_MZ2H:	incbin	"objpos\mz2h.bin"
		even
ObjPos_MZ3:		incbin	"objpos\mz3.bin"
		even
ObjPos_MZ3H:	incbin	"objpos\mz3h.bin"
		even
ObjPos_SLZ1:	incbin	"objpos\slz1.bin"
		even
ObjPos_SLZ1E:	incbin	"objpos\slz1e.bin"
		even
ObjPos_SLZ1H:	incbin	"objpos\slz1h.bin"
		even
ObjPos_SLZ2:	incbin	"objpos\slz2.bin"
		even
ObjPos_SLZ2E:	incbin	"objpos\slz2e.bin"
		even
ObjPos_SLZ2H:	incbin	"objpos\slz2h.bin"
		even
ObjPos_SLZ3:	incbin	"objpos\slz3.bin"
		even
ObjPos_SLZ3H:	incbin	"objpos\slz3h.bin"
		even
ObjPos_SYZ1:	incbin	"objpos\syz1.bin"
		even
ObjPos_SYZ1E:	incbin	"objpos\syz1e.bin"
		even
ObjPos_SYZ1H:	incbin	"objpos\syz1h.bin"
		even
ObjPos_SYZ2:	incbin	"objpos\syz2.bin"
		even
ObjPos_SYZ2E:	incbin	"objpos\syz2e.bin"
		even
ObjPos_SYZ2H:	incbin	"objpos\syz2h.bin"
		even
ObjPos_SYZ3:	incbin	"objpos\syz3.bin"
		even
ObjPos_SYZ3H:	incbin	"objpos\syz3h.bin"
		even
ObjPos_SBZ1:	incbin	"objpos\sbz1.bin"
		even
ObjPos_SBZ1E:	incbin	"objpos\sbz1e.bin"
		even
ObjPos_SBZ1H:	incbin	"objpos\sbz1h.bin"
		even
ObjPos_SBZ2:	incbin	"objpos\sbz2.bin"
		even
ObjPos_SBZ2E:	incbin	"objpos\sbz2e.bin"
		even
ObjPos_SBZ2H:	incbin	"objpos\sbz2h.bin"
		even
ObjPos_FZ:		incbin	"objpos\fz.bin"
		even

ObjPos_BZ1:		incbin	"objpos\bz1.bin"
		even
ObjPos_BZ1E:	incbin	"objpos\bz1e.bin"
		even
ObjPos_BZ1H:	incbin	"objpos\bz1h.bin"
		even
ObjPos_BZ2:		incbin	"objpos\bz2.bin"
		even
ObjPos_BZ2E:	incbin	"objpos\bz2e.bin"
		even
ObjPos_BZ2H:	incbin	"objpos\bz2h.bin"
		even
ObjPos_BZ3:		incbin	"objpos\bz3.bin"
		even
ObjPos_BZ3H:	incbin	"objpos\bz3h.bin"
		even
ObjPos_JZ1:		incbin	"objpos\jz1.bin"
		even
ObjPos_JZ1E:	incbin	"objpos\jz1e.bin"
		even
ObjPos_JZ1H:	incbin	"objpos\jz1h.bin"
		even
ObjPos_JZ2:		incbin	"objpos\jz2.bin"
		even
ObjPos_JZ2E:	incbin	"objpos\jz2e.bin"
		even
ObjPos_JZ2H:	incbin	"objpos\jz2h.bin"
		even
ObjPos_JZ3:		incbin	"objpos\jz3.bin"
		even
ObjPos_JZ3H:	incbin	"objpos\jz3h.bin"
		even
ObjPos_SKBZ1:	incbin	"objpos\skbz1.bin"
		even
ObjPos_SKBZ1E:	incbin	"objpos\skbz1e.bin"
		even
ObjPos_SKBZ1H:	incbin	"objpos\skbz1h.bin"
		even
ObjPos_SKBZ2:	incbin	"objpos\skbz2.bin"
		even
ObjPos_SKBZ2E:	incbin	"objpos\skbz2e.bin"
		even
ObjPos_SKBZ2H:	incbin	"objpos\skbz2h.bin"
		even
ObjPos_SKBZ3:	incbin	"objpos\skbz3.bin"
		even
ObjPos_SKBZ3H:	incbin	"objpos\skbz3h.bin"
		even

ObjPos_SBZ1pf1:	incbin	"objpos\sbz1pf1.bin"
		even
ObjPos_SBZ1pf2:	incbin	"objpos\sbz1pf2.bin"
		even
ObjPos_SBZ1pf3:	incbin	"objpos\sbz1pf3.bin"
		even
ObjPos_SBZ1pf4:	incbin	"objpos\sbz1pf4.bin"
		even
ObjPos_SBZ1pf5:	incbin	"objpos\sbz1pf5.bin"
		even
ObjPos_SBZ1pf6:	incbin	"objpos\sbz1pf6.bin"
		even
ObjPos_End:		incbin	"objpos\ending.bin"
		even
ObjPos_Null:	dc.b $FF, $FF, 0, 0, 0,	0

; --------------------------------------------------------------------------------------
; Offset index of ring locations
; --------------------------------------------------------------------------------------
RingPos_Index:
		dc.l RingPos_GHZ1, RingPos_GHZ1E, RingPos_GHZ1H, RingPos_Null
		dc.l RingPos_GHZ2, RingPos_GHZ2E, RingPos_GHZ2H, RingPos_Null
		dc.l RingPos_GHZ3, RingPos_GHZ2E, RingPos_GHZ3H, RingPos_Null
		dc.l RingPos_GHZ1, RingPos_GHZ1E, RingPos_GHZ1H, RingPos_Null

		dc.l RingPos_LZ1, RingPos_LZ1E, RingPos_LZ1H, RingPos_Null
		dc.l RingPos_LZ2, RingPos_LZ2E, RingPos_LZ2H, RingPos_Null
		dc.l RingPos_LZ3, RingPos_LZ2E, RingPos_LZ3H, RingPos_Null
		dc.l RingPos_SBZ3, RingPos_SBZ3, RingPos_SBZ3H, RingPos_Null

		dc.l RingPos_MZ1, RingPos_MZ1E, RingPos_MZ1H, RingPos_Null
		dc.l RingPos_MZ2, RingPos_MZ2E, RingPos_MZ2H, RingPos_Null
		dc.l RingPos_MZ3, RingPos_MZ2E, RingPos_MZ3H, RingPos_Null
		dc.l RingPos_MZ1, RingPos_MZ1E, RingPos_MZ1H, RingPos_Null

		dc.l RingPos_SLZ1, RingPos_SLZ1E, RingPos_SLZ1H, RingPos_Null
		dc.l RingPos_SLZ2, RingPos_SLZ2E, RingPos_SLZ2H, RingPos_Null
		dc.l RingPos_SLZ3, RingPos_SLZ2E, RingPos_SLZ3H, RingPos_Null
		dc.l RingPos_SLZ1, RingPos_SLZ1E, RingPos_SLZ1H, RingPos_Null

		dc.l RingPos_SYZ1, RingPos_SYZ1E, RingPos_SYZ1H, RingPos_Null
		dc.l RingPos_SYZ2, RingPos_SYZ2E, RingPos_SYZ2H, RingPos_Null
		dc.l RingPos_SYZ3, RingPos_SYZ2E, RingPos_SYZ3H, RingPos_Null
		dc.l RingPos_SYZ1, RingPos_SYZ1E, RingPos_SYZ1H, RingPos_Null

		dc.l RingPos_SBZ1, RingPos_SBZ1E, RingPos_SBZ1H, RingPos_Null
		dc.l RingPos_SBZ2, RingPos_SBZ2E, RingPos_SBZ2H, RingPos_Null
		dc.l RingPos_Null, RingPos_Null, RingPos_Null, RingPos_Null	; Final Zone... will have 3 rings in easy mode.
		dc.l RingPos_SBZ1, RingPos_SBZ1E, RingPos_SBZ1H, RingPos_Null

		dc.l RingPos_Null, RingPos_Null, RingPos_Null, RingPos_Null
		dc.l RingPos_Null, RingPos_Null, RingPos_Null, RingPos_Null
		dc.l RingPos_Null, RingPos_Null, RingPos_Null, RingPos_Null
		dc.l RingPos_Null, RingPos_Null, RingPos_Null, RingPos_Null

		dc.l RingPos_BZ1, RingPos_BZ1E, RingPos_BZ1H, RingPos_Null
		dc.l RingPos_BZ2, RingPos_BZ2E, RingPos_BZ2H, RingPos_Null
		dc.l RingPos_BZ3, RingPos_BZ2E, RingPos_BZ3H, RingPos_Null
		dc.l RingPos_BZ1, RingPos_BZ1E, RingPos_BZ1H, RingPos_Null

		dc.l RingPos_JZ1, RingPos_JZ1E, RingPos_JZ1H, RingPos_Null
		dc.l RingPos_JZ2, RingPos_JZ2E, RingPos_JZ2H, RingPos_Null
		dc.l RingPos_JZ3, RingPos_JZ2E, RingPos_JZ3H, RingPos_Null
		dc.l RingPos_JZ1, RingPos_JZ1E, RingPos_JZ1H, RingPos_Null

		dc.l RingPos_SKBZ1, RingPos_SKBZ1E, RingPos_SKBZ1H, RingPos_Null
		dc.l RingPos_SKBZ2, RingPos_SKBZ2E, RingPos_SKBZ2H, RingPos_Null
		dc.l RingPos_SKBZ3, RingPos_SKBZ2E, RingPos_SKBZ3H, RingPos_Null
		dc.l RingPos_SKBZ2, RingPos_SKBZ1E, RingPos_SKBZ1H, RingPos_Null

RingPos_GHZ1:	incbin	ringpos\ghz1.bin
		even
RingPos_GHZ1E:	incbin	ringpos\ghz1e.bin
		even
RingPos_GHZ1H:	incbin	ringpos\ghz1h.bin
		even
RingPos_GHZ2:	incbin	ringpos\ghz2.bin
		even
RingPos_GHZ2E:	incbin	ringpos\ghz2e.bin
		even
RingPos_GHZ2H:	incbin	ringpos\ghz2h.bin
		even
RingPos_GHZ3:	incbin	"ringpos\ghz3.bin"
		even
RingPos_GHZ3H:	incbin	ringpos\ghz3h.bin
		even
RingPos_LZ1:	incbin	"ringpos\lz1.bin"
		even
RingPos_LZ1E:	incbin	"ringpos\lz1e.bin"
		even
RingPos_LZ1H:	incbin	"ringpos\lz1h.bin"
		even
RingPos_LZ2:	incbin	ringpos\lz2.bin
		even
RingPos_LZ2E:	incbin	ringpos\lz2e.bin
		even
RingPos_LZ2H:	incbin	ringpos\lz2h.bin
		even
RingPos_LZ3:	incbin	"ringpos\lz3.bin"
		even
RingPos_LZ3H:	incbin	"ringpos\lz3h.bin"
		even
RingPos_SBZ3:	incbin	ringpos\sbz3.bin
		even
RingPos_SBZ3H:	incbin	ringpos\sbz3h.bin
		even
RingPos_MZ1:	incbin	"ringpos\mz1.bin"
		even
RingPos_MZ1E:	incbin	"ringpos\mz1e.bin"
		even
RingPos_MZ1H:	incbin	"ringpos\mz1h.bin"
		even
RingPos_MZ2:	incbin	ringpos\mz2.bin
		even
RingPos_MZ2E:	incbin	ringpos\mz2e.bin
		even
RingPos_MZ2H:	incbin	ringpos\mz2h.bin
		even
RingPos_MZ3:	incbin	ringpos\mz3.bin
		even
RingPos_MZ3H:	incbin	ringpos\mz3h.bin
		even
RingPos_SLZ1:	incbin	ringpos\slz1.bin
		even
RingPos_SLZ1E:	incbin	ringpos\slz1e.bin
		even
RingPos_SLZ1H:	incbin	ringpos\slz1h.bin
		even
RingPos_SLZ2:	incbin	ringpos\slz2.bin
		even
RingPos_SLZ2E:	incbin	ringpos\slz2e.bin
		even
RingPos_SLZ2H:	incbin	ringpos\slz2h.bin
		even
RingPos_SLZ3:	incbin	ringpos\slz3.bin
		even
RingPos_SLZ3H:	incbin	ringpos\slz3h.bin
		even
RingPos_SYZ1:	incbin	ringpos\syz1.bin
		even
RingPos_SYZ1E:	incbin	ringpos\syz1e.bin
		even
RingPos_SYZ1H:	incbin	ringpos\syz1h.bin
		even
RingPos_SYZ2:	incbin	ringpos\syz2.bin
		even
RingPos_SYZ2E:	incbin	ringpos\syz2e.bin
		even
RingPos_SYZ2H:	incbin	ringpos\syz2h.bin
		even
RingPos_SYZ3:	incbin	"ringpos\syz3.bin"
		even
RingPos_SYZ3H:	incbin	"ringpos\syz3h.bin"
		even
RingPos_SBZ1:	incbin	"ringpos\sbz1.bin"
		even
RingPos_SBZ1E:	incbin	"ringpos\sbz1e.bin"
		even
RingPos_SBZ1H:	incbin	"ringpos\sbz1h.bin"
		even
RingPos_SBZ2:	incbin	"ringpos\sbz2.bin"
		even
RingPos_SBZ2E:	incbin	"ringpos\sbz2e.bin"
		even
RingPos_SBZ2H:	incbin	"ringpos\sbz2h.bin"
		even
RingPos_BZ1:	incbin	"ringpos\bz1.bin"
		even
RingPos_BZ1E:	incbin	"ringpos\bz1e.bin"
		even
RingPos_BZ1H:	incbin	"ringpos\bz1h.bin"
		even
RingPos_BZ2:	incbin	"ringpos\bz2.bin"
		even
RingPos_BZ2E:	incbin	"ringpos\bz2e.bin"
		even
RingPos_BZ2H:	incbin	"ringpos\bz2h.bin"
		even
RingPos_BZ3:	incbin	"ringpos\bz3.bin"
		even
RingPos_BZ3H:	incbin	"ringpos\bz3h.bin"
		even
RingPos_JZ1:	incbin	"ringpos\jz1.bin"
		even
RingPos_JZ1E:	incbin	"ringpos\jz1e.bin"
		even
RingPos_JZ1H:	incbin	"ringpos\jz1h.bin"
		even
RingPos_JZ2:	incbin	"ringpos\jz2.bin"
		even
RingPos_JZ2E:	incbin	"ringpos\jz2e.bin"
		even
RingPos_JZ2H:	incbin	"ringpos\jz2h.bin"
		even
RingPos_JZ3:	incbin	"ringpos\jz3.bin"
		even
RingPos_JZ3H:	incbin	"ringpos\jz3h.bin"
		even
RingPos_SKBZ1:	incbin	"ringpos\skbz1.bin"
		even
RingPos_SKBZ1E:	incbin	"ringpos\skbz1e.bin"
		even
RingPos_SKBZ1H:	incbin	"ringpos\skbz1h.bin"
		even
RingPos_SKBZ2:	incbin	"ringpos\skbz2.bin"
		even
RingPos_SKBZ2E:	incbin	"ringpos\skbz2e.bin"
		even
RingPos_SKBZ2H:	incbin	"ringpos\skbz2h.bin"
		even
RingPos_SKBZ3:	incbin	"ringpos\skbz3.bin"
		even
RingPos_SKBZ3H:	incbin	"ringpos\skbz3h.bin"
		even

RingPos_Null:	dc.b $FF, $FF, 0, 0, 0,	0

		dcb.b $63C,$FF

		;dcb.b ($10000-(*%$10000))-(EndOfRom-SoundDriver),$FF

SoundDriver:	include "s1.sounddriver.asm"

; end of 'ROM'
		even

; ==============================================================
; --------------------------------------------------------------
; Debugging modules
; --------------------------------------------------------------

   include   "ErrorHandler.asm"


EndOfRom:


		END
