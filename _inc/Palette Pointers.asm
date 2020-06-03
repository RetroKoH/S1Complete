; ---------------------------------------------------------------------------
; Palette pointers
; ---------------------------------------------------------------------------

palp:	macro paladdress,ramaddress,colours
	dc.l paladdress
	dc.w ramaddress, (colours>>1)-1
	endm

PalPointers:

; palette address, RAM address, colours

ptr_Pal_Title:		palp	Pal_Title,v_pal_dry,$20			; 1 - title screen
ptr_Pal_Options:	palp	Pal_Options,v_pal_dry,$40		; 2 - Options
ptr_Pal_Sonic:		palp	Pal_Sonic,v_pal_dry,$10			; 3 - Sonic

Pal_Levels:
ptr_Pal_GHZ:		palp	Pal_GHZ,v_pal_dry+$20, $30			; 4 - GHZ
ptr_Pal_GHZ_Easy:	palp	Pal_GHZ_Easy,v_pal_dry+$20, $30		; 7 - GHZ - Easy Mode
ptr_Pal_GHZ_Hard:	palp	Pal_GHZ_Hard,v_pal_dry+$20, $30		; 7 - GHZ - Hard Mode
ptr_Pal_LZ:			palp	Pal_LZ,v_pal_dry+$20,$30			; 5 - LZ
ptr_Pal_LZ_Easy:	palp	Pal_LZ_Easy,v_pal_dry+$20,$30		; 8 - LZ - Easy Mode
ptr_Pal_LZ_Hard:	palp	Pal_LZ_Hard,v_pal_dry+$20,$30		; 8 - LZ - Hard Mode
ptr_Pal_MZ:			palp	Pal_MZ,v_pal_dry+$20,$30			; 6 - MZ
ptr_Pal_MZ_Easy:	palp	Pal_MZ_Easy,v_pal_dry+$20,$30		; 9 - MZ - Easy Mode
ptr_Pal_MZ_Hard:	palp	Pal_MZ_Hard,v_pal_dry+$20,$30		; 9 - MZ - Hard Mode
ptr_Pal_SLZ:		palp	Pal_SLZ,v_pal_dry+$20,$30			; 7 - SLZ
ptr_Pal_SLZ_Easy:	palp	Pal_SLZ_Easy,v_pal_dry+$20,$30		; $A - SLZ - Easy Mode
ptr_Pal_SLZ_Hard:	palp	Pal_SLZ_Hard,v_pal_dry+$20,$30		; $A - SLZ - Hard Mode
ptr_Pal_SYZ:		palp	Pal_SYZ,v_pal_dry+$20,$30			; 8 - SYZ
ptr_Pal_SYZ_Easy:	palp	Pal_SYZ_Easy,v_pal_dry+$20,$30		; $B - SYZ - Easy Mode
ptr_Pal_SYZ_Hard:	palp	Pal_SYZ_Hard,v_pal_dry+$20,$30		; $B - SYZ - Hard Mode
ptr_Pal_SBZ1:		palp	Pal_SBZ1,v_pal_dry+$20,$30			; 9 - SBZ1
ptr_Pal_SBZ1_Easy:	palp	Pal_SBZ1_Easy,v_pal_dry+$20,$30		; $C - SBZ1 - Easy Mode
ptr_Pal_SBZ1_Hard:	palp	Pal_SBZ1_Hard,v_pal_dry+$20,$30		; $C - SBZ1 - Hard Mode
ptr_Pal_BZ:			palp	Pal_BZ,$FB20, $30					; $D - BZ
ptr_Pal_BZ_Easy:	palp	Pal_BZ_Easy,$FB20, $30				; $D - BZ - Easy Mode
ptr_Pal_BZ_Hard:	palp	Pal_BZ_Hard,$FB20, $30				; $D - BZ - Hard Mode
ptr_Pal_JZ:			palp	Pal_JZ,$FB20, $30					; $D - JZ
ptr_Pal_JZ_Easy:	palp	Pal_JZ_Easy,$FB20, $30				; $D - JZ - Easy Mode
ptr_Pal_JZ_Hard:	palp	Pal_JZ_Hard,$FB20, $30				; $D - JZ - Hard Mode
ptr_Pal_SKBZ:		palp	Pal_SKBZ,$FB20, $30					; $D - SKBZ
ptr_Pal_SKBZ_Easy:	palp	Pal_SKBZ_Easy,$FB20, $30			; $D - SKBZ - Easy Mode
ptr_Pal_SKBZ_Hard:	palp	Pal_SKBZ_Hard,$FB20, $30			; $D - SKBZ - Hard Mode

ptr_Pal_Special:	palp	Pal_Special,v_pal_dry,$40			; $A (10) - special stage
ptr_Pal_LZWater:	palp	Pal_LZWater,v_pal_dry,$40			; $B (11) - LZ underwater
ptr_Pal_LZWater_Easy:	palp	Pal_LZWater_Easy,v_pal_dry,$40		; $11 - LZ underwater - Easy Mode
ptr_Pal_LZWater_Hard:	palp	Pal_LZWater_Hard,v_pal_dry,$40		; $11 - LZ underwater - Hard Mode
ptr_Pal_SBZ3:		palp	Pal_SBZ3,v_pal_dry+$20,$30			; $C (12) - SBZ3
ptr_Pal_SBZ3_Easy:	palp	Pal_SBZ3_Easy,v_pal_dry+$20,$30			; $12 - SBZ3 - Easy Mode
ptr_Pal_SBZ3_Hard:	palp	Pal_SBZ3_Hard,v_pal_dry+$20,$30			; $12 - SBZ3 - Hard Mode
ptr_Pal_SBZ3Water:	palp	Pal_SBZ3Water,v_pal_dry,$40			; $D (13) - SBZ3 underwater
ptr_Pal_SBZ3Water_Easy:	palp	Pal_SBZ3Water_Easy,v_pal_dry,$40	; $13 - SBZ3 underwater - Easy Mode
ptr_Pal_SBZ3Water_Hard:	palp	Pal_SBZ3Water_Hard,v_pal_dry,$40	; $13 - SBZ3 underwater - Hard Mode
ptr_Pal_SBZ2:		palp	Pal_SBZ2,v_pal_dry+$20,$30			; $E (14) - SBZ2
ptr_Pal_SBZ2_Easy:	palp	Pal_SBZ2_Easy,v_pal_dry+$20,$30			; $14 - SBZ2 - Easy Mode
ptr_Pal_SBZ2_Hard:	palp	Pal_SBZ2_Hard,v_pal_dry+$20,$30			; $14 - SBZ2 - Hard Mode
ptr_Pal_LZSonWater:	palp	Pal_LZSonWater,v_pal_dry,$10		; $F (15) - LZ Sonic underwater
ptr_Pal_SBZ3SonWat:	palp	Pal_SBZ3SonWat,v_pal_dry,$10		; $10 (16) - SBZ3 Sonic underwater
ptr_Pal_SSResult:	palp	Pal_SSResult,v_pal_dry,$40			; $11 (17) - special stage results
ptr_Pal_Continue:	palp	Pal_Continue,v_pal_dry,$20			; $12 (18) - special stage results continue
ptr_Pal_Ending:		palp	Pal_Ending,v_pal_dry,$40			; $13 (19) - ending sequence

ptr_Pal_Menu:			palp	Pal_Menu,$FB00,$40			; S2 Menu Screen (Level Select/Time Attack)
ptr_Pal_LevSelIcons:	palp	Pal_LevSelIcons,$FB40,$10	; Level Select Icons
			even


palid_Title:		equ (ptr_Pal_Title-PalPointers)/8
palid_Options:		equ (ptr_Pal_Options-PalPointers)/8
palid_Sonic:		equ (ptr_Pal_Sonic-PalPointers)/8

palid_GHZ:			equ (ptr_Pal_GHZ-PalPointers)/8
palid_GHZ_Easy:		equ (ptr_Pal_GHZ_Easy-PalPointers)/8
palid_GHZ_Hard:		equ (ptr_Pal_GHZ_Hard-PalPointers)/8
palid_LZ:			equ (ptr_Pal_LZ-PalPointers)/8
palid_LZ_Easy:		equ (ptr_Pal_LZ_Easy-PalPointers)/8
palid_LZ_Hard:		equ (ptr_Pal_LZ_Hard-PalPointers)/8
palid_MZ:			equ (ptr_Pal_MZ-PalPointers)/8
palid_MZ_Easy:		equ (ptr_Pal_MZ_Easy-PalPointers)/8
palid_MZ_Hard:		equ (ptr_Pal_MZ_Hard-PalPointers)/8
palid_SLZ:			equ (ptr_Pal_SLZ-PalPointers)/8
palid_SLZ_Easy:		equ (ptr_Pal_SLZ_Easy-PalPointers)/8
palid_SLZ_Hard:		equ (ptr_Pal_SLZ_Hard-PalPointers)/8
palid_SYZ:			equ (ptr_Pal_SYZ-PalPointers)/8
palid_SYZ_Easy:		equ (ptr_Pal_SYZ_Easy-PalPointers)/8
palid_SYZ_Hard:		equ (ptr_Pal_SYZ_Hard-PalPointers)/8
palid_SBZ1:			equ (ptr_Pal_SBZ1-PalPointers)/8
palid_SBZ1_Easy:	equ (ptr_Pal_SBZ1_Easy-PalPointers)/8
palid_SBZ1_Hard:	equ (ptr_Pal_SBZ1_Hard-PalPointers)/8
palid_BZ:			equ (ptr_Pal_BZ-PalPointers)/8
palid_BZ_Easy:		equ (ptr_Pal_BZ_Easy-PalPointers)/8
palid_BZ_Hard:		equ (ptr_Pal_BZ_Hard-PalPointers)/8
palid_JZ:			equ (ptr_Pal_JZ-PalPointers)/8
palid_JZ_Easy:		equ (ptr_Pal_JZ_Easy-PalPointers)/8
palid_JZ_Hard:		equ (ptr_Pal_JZ_Hard-PalPointers)/8
palid_SKBZ:				equ (ptr_Pal_SKBZ-PalPointers)/8
palid_SKBZ_Easy:		equ (ptr_Pal_SKBZ-PalPointers)/8
palid_SKBZ_Hard:		equ (ptr_Pal_SKBZ-PalPointers)/8
palid_Special:			equ (ptr_Pal_Special-PalPointers)/8
palid_LZWater:			equ (ptr_Pal_LZWater-PalPointers)/8
palid_LZWater_Easy:		equ (ptr_Pal_LZWater_Easy-PalPointers)/8
palid_LZWater_Hard:		equ (ptr_Pal_LZWater_Hard-PalPointers)/8
palid_SBZ3:				equ (ptr_Pal_SBZ3-PalPointers)/8
palid_SBZ3_Easy:		equ (ptr_Pal_SBZ3_Easy-PalPointers)/8
palid_SBZ3_Hard:		equ (ptr_Pal_SBZ3_Hard-PalPointers)/8
palid_SBZ3Water:		equ (ptr_Pal_SBZ3Water-PalPointers)/8
palid_SBZ3Water_Easy:	equ (ptr_Pal_SBZ3Water_Easy-PalPointers)/8
palid_SBZ3Water_Hard:	equ (ptr_Pal_SBZ3Water_Hard-PalPointers)/8
palid_SBZ2:				equ (ptr_Pal_SBZ2-PalPointers)/8
palid_SBZ2_Easy:		equ (ptr_Pal_SBZ2_Easy-PalPointers)/8
palid_SBZ2_Hard:		equ (ptr_Pal_SBZ2_Hard-PalPointers)/8

palid_LZSonWater:	equ (ptr_Pal_LZSonWater-PalPointers)/8
palid_SBZ3SonWat:	equ (ptr_Pal_SBZ3SonWat-PalPointers)/8
palid_SSResult:		equ (ptr_Pal_SSResult-PalPointers)/8
palid_Continue:		equ (ptr_Pal_Continue-PalPointers)/8
palid_Ending:		equ (ptr_Pal_Ending-PalPointers)/8
palid_Menu:		equ (ptr_Pal_Menu-PalPointers)/8
palid_LevSelIcons:	equ (ptr_Pal_LevSelIcons-PalPointers)/8
