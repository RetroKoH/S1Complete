; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------
Map_HUD_SS:
		dc.w @allyellow-Map_HUD_SS
		dc.w @ringgone-Map_HUD_SS
	@allyellow:
		dc.b $5
		dc.b $80, $D, $A0, 2, 0		; RING
		dc.b $80, 1, $A0, 0, $20	; S
		dc.b $80, 9, $80, $30, $30	; rings
		dc.b $40, 5, $80, $36, 0	; icon
		dc.b $40, $D, $A0, $3A, $10	; SONIC x nn
	@ringgone:
		dc.b 3
		;dc.b $80, $D, $A0, $C, 0	; RING
		;dc.b $80, 1, $A0, $A, $20	; S
		dc.b $80, 9, $80, $30, $30	; rings
		dc.b $40, 5, $80, $36, 0	; icon
		dc.b $40, $D, $A0, $3A, $10	; SONIC x nn
		even
		