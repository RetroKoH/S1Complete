; ---------------------------------------------------------------------------
; Sprite mappings - red ring
; ---------------------------------------------------------------------------

RedRingDynPLC:	mappingsTable
	mappingsTableEntry.w	@front
	mappingsTableEntry.w	@angle1
	mappingsTableEntry.w	@angle2
	mappingsTableEntry.w	@angle3
	mappingsTableEntry.w	@edge
	mappingsTableEntry.w	@angle3
	mappingsTableEntry.w	@angle2
	mappingsTableEntry.w	@angle1
	mappingsTableEntry.w	@sparkle
	mappingsTableEntry.w	@sparkle
	mappingsTableEntry.w	@sparkle
	mappingsTableEntry.w	@sparkle
	mappingsTableEntry.w	@blank

@front:	dplcHeader
	dplcEntry	4, 0
@front_End

@angle1:	dplcHeader
	dplcEntry	4, 4
@angle1_End

@angle2:	dplcHeader
	dplcEntry	4, 8
@angle2_End

@angle3:	dplcHeader
	dplcEntry	2, $C
@angle3_End

@edge:	dplcHeader
	dplcEntry	2, $E
@edge_End

@sparkle:	dplcHeader
	dplcEntry	4, $10
@sparkle_End

@blank:	dplcHeader
@blank_End

	even