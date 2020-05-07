; ---------------------------------------------------------------------------
; Uncompressed graphics	loading	array for the Signpost
; ---------------------------------------------------------------------------
SignpostDynPLC:	mappingsTable
	mappingsTableEntry.w	SignpostPLC_Eggman
	mappingsTableEntry.w	SignpostPLC_Spin1
	mappingsTableEntry.w	SignpostPLC_Spin2
	mappingsTableEntry.w	SignpostPLC_Spin3
	mappingsTableEntry.w	SignpostPLC_Sonic
	mappingsTableEntry.w	SignpostPLC_Tails
	mappingsTableEntry.w	SignpostPLC_Knux
	mappingsTableEntry.w	SignpostPLC_Mighty
	mappingsTableEntry.w	SignpostPLC_Amy
	mappingsTableEntry.w	SignpostPLC_Ray
	mappingsTableEntry.w	SignpostPLC_Metal

SignpostPLC_Eggman:	dplcHeader
	dplcEntry	$C, 0
	dplcEntry	5, $38
SignpostPLC_Eggman_End

SignpostPLC_Spin1:	dplcHeader
	dplcEntry	$10, $C
	dplcEntry	2, $38
SignpostPLC_Spin1_End

SignpostPLC_Spin2:	dplcHeader
	dplcEntry	4, $1C
	dplcEntry	2, $38
SignpostPLC_Spin2_End

SignpostPLC_Spin3:	dplcHeader
	dplcEntry	$10, $C
	dplcEntry	2, $38
SignpostPLC_Spin3_End

SignpostPLC_Sonic:	dplcHeader
	dplcEntry	$C, $20
	dplcEntry	$C, $2C
        dplcEntry	2, $38
SignpostPLC_Sonic_End

SignpostPLC_Tails:	dplcHeader
	dplcEntry	$C, $3D
	dplcEntry	$C, $49
        dplcEntry	2, $38
SignpostPLC_Tails_End

SignpostPLC_Knux:	dplcHeader
	dplcEntry	$C, $55
	dplcEntry	$C, $61
        dplcEntry	2, $38
SignpostPLC_Knux_End

SignpostPLC_Mighty:	dplcHeader
	dplcEntry	$C, $6D
	dplcEntry	$C, $79
        dplcEntry	2, $38
SignpostPLC_Mighty_End

SignpostPLC_Amy:	dplcHeader
	dplcEntry	$C, $85
	dplcEntry	$C, $91
        dplcEntry	2, $38
SignpostPLC_Amy_End

SignpostPLC_Ray:	dplcHeader
	dplcEntry	$C, $20
	dplcEntry	$C, $2C
        dplcEntry	2, $38
SignpostPLC_Ray_End

SignpostPLC_Metal:	dplcHeader
	dplcEntry	$C, $9D
	dplcEntry	$C, $A9
        dplcEntry	2, $38
SignpostPLC_Metal_End

	even
