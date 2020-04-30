; ---------------------------------------------------------------------------
; Sonic when he's drowning
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Drowned:
        bsr.w   SpeedToPos              ; Make Sonic able to move
        addi.w  #$10,y_vel(a0)          ; Apply gravity
        bsr.w   Sonic_RecordPosition    ; Record position
        bsr.s   Sonic_Animate           ; Animate Sonic
        bsr.w   Sonic_LoadGfx           ; Load Sonic's DPLCs
        bra.w   DisplaySprite           ; And finally, display Sonic