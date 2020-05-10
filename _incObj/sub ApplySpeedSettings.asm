; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to collect the right speed setting for a character (REV C EDIT)
; Originally by redhotsonic. Optimizations by MoDule.
; Adapted for Sonic 1 Complete by KoH.
; a0 must be character
; a1 will be the result and have the correct speed settings
; a2 is characters' speed
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

ApplySpeedSettings:
		moveq   #0,d0                           ; Quickly clear d0
		btst	#stsShoes,(v_status_secondary).w            ; Does character have speedshoes?
		beq.s   @noshoes                        ; If not, branch
		addq.b  #8,d0

	@noshoes:
		btst    #staWater,obStatus(a0)            ; Is the character underwater?
		beq.s   @nowater                        ; If not, branch
		addi.b  #$10,d0

	@nowater:
		btst	#stsSuper,(v_status_secondary).w ; Is character Super?
		beq.s   @nosuper                         ; If not, branch
		addi.b  #$20,d0

	@nosuper:
		lea	SpeedSettings(pc,d0.w),a1       ; Load correct speed settings into a1
;		cmpi.b	#4,character_id(a0)
;		bne.s	@notamy
;		lea	AmySpeedSettings(pc,d0.w),a1
;	@notamy:
		addq.l  #2,a1                           ; Increment a1 by 2 quickly
		move.l  (a1)+,(a2)+                     ; Set character's new top speed and acceleration
		move.w  (a1),(a2)                       ; Set character's deceleration
		rts
; End of function ApplySpeedSettings

; ----------------------------------------------------------------------------
; Speed Settings Array - This array defines what speeds the character should be set to.
; ----------------------------------------------------------------------------
;               blank   top_speed       acceleration    deceleration    ; #     ; Comment
SpeedSettings:
        dc.w	$0,     $600,           $C,             $80             ; $00   ; Normal
        dc.w	$0,     $C00,           $18,            $80             ; $08   ; Normal Speedshoes
        dc.w	$0,     $300,           $6,             $40             ; $10   ; Normal Underwater
        dc.w	$0,     $600,           $C,             $40             ; $18   ; Normal Underwater Speedshoes
        dc.w	$0,     $A00,           $30,            $100            ; $20   ; Super
        dc.w	$0,     $C00,           $30,            $100            ; $28   ; Super Speedshoes
        dc.w	$0,     $500,           $18,            $80             ; $30   ; Super Underwater
        dc.w	$0,     $A00,           $30,            $80             ; $38   ; Super Underwater Speedshoes
; ===========================================================================

; ----------------------------------------------------------------------------
; Amy's Speed Settings Array - This array defines what speeds Amy should be set to.
; ----------------------------------------------------------------------------
;               blank   top_speed       acceleration    deceleration    ; #     ; Comment
AmySpeedSettings:
        dc.w	$0,     $550,           $C,             $80             ; $00   ; Normal
        dc.w	$0,     $B00,           $18,            $80             ; $08   ; Normal Speedshoes
        dc.w	$0,     $250,           $6,             $40             ; $10   ; Normal Underwater
        dc.w	$0,     $500,           $C,             $40             ; $18   ; Normal Underwater Speedshoes
        dc.w	$0,     $950,           $30,            $100            ; $20   ; Super
        dc.w	$0,     $B00,           $30,            $100            ; $28   ; Super Speedshoes
        dc.w	$0,     $450,           $18,            $80             ; $30   ; Super Underwater
        dc.w	$0,     $950,           $30,            $80             ; $38   ; Super Underwater Speedshoes
; ===========================================================================
