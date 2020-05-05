; ---------------------------------------------------------------
; uncompressed art to VRAM loader
; ---------------------------------------------------------------
; INPUT:
;       a0      - Source Offset
;   d0  - length in tiles
; ---------------------------------------------------------------
LoadUncArt:
        move    #$2700,sr   ; disable interrupts
        lea $C00000.l,a6    ; get VDP data port
 
LoadArt_Loop:
        move.l  (a0)+,(a6)  ; transfer 4 bytes
        move.l  (a0)+,(a6)  ; transfer 4 more bytes
        move.l  (a0)+,(a6)  ; and so on and so forth
        move.l  (a0)+,(a6)  ;
        move.l  (a0)+,(a6)  ;
        move.l  (a0)+,(a6)  ;
        move.l  (a0)+,(a6)  ; in total transfer 32 bytes
        move.l  (a0)+,(a6)  ; which is 1 full tile
 
        dbf d0, LoadArt_Loop; loop until d0 = 0
        move    #$2300,sr   ; enable interrupts
        rts