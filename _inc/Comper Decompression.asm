; ===============================================================
; ---------------------------------------------------------------
; COMPER compressed art to VRAM loader
; ---------------------------------------------------------------
; INPUT:
;       a0      - Source Offset
;   d4  - VDP mode
; ---------------------------------------------------------------
LoadCompArt:
        lea $FF0000.l,a1    ; get address of compdec buffer
        bsr.s   CompDec     ; decompress art
 
        lea $FF0000.l,a3    ; get address of compdec buffer again
        lea $C00000.l,a6    ; get VDP data port
 
        move.l  a1,d0       ; move end address to d0
        sub.l   a3,d0       ; substract the compdec buffer address from d0
        lsr.l   #2,d0       ; shift 2 bits to right (as we transfer longword per loop)
        subq.l  #1,d0       ; substract 1 from d0 because of dbf
 
        move    #$2700,sr   ; disable interrupts
        move.l  d4,4(a6)    ; set VDP transfer mode
 
	@loop:
		move.l  (a3)+,(a6)  ; transfer next longword
        dbf d0,@loop    ; loop until d0 = 0
        move    #$2300,sr   ; enable interrupts
        rts
 
; ===============================================================
; ---------------------------------------------------------------
; COMPER Decompressor
; ---------------------------------------------------------------
; INPUT:
;       a0      - Source Offset
;       a1      - Destination Offset
;
;  Full credits of this to Vladikcomper
; ---------------------------------------------------------------
 
CompDec:
	@newblock:
        move.w  (a0)+,d0                ; fetch description field
        moveq   #15,d3                  ; set bits counter to 16
 
	@mainloop:
        add.w   d0,d0                   ; roll description field
        bcs.s   @flag                   ; if a flag issued, branch
        move.w  (a0)+,(a1)+             ; otherwise, do uncompressed data
        dbf     d3,@mainloop            ; if bits counter remains, parse the next word
        bra.s   @newblock               ; start a new block
 
; ---------------------------------------------------------------
	@flag:
	    moveq   #-1,d1                  ; init displacement
        move.b  (a0)+,d1                ; load displacement
        add.w   d1,d1
        moveq   #0,d2                   ; init copy count
        move.b  (a0)+,d2                ; load copy length
        beq.s   @end                    ; if zero, branch
        lea     (a1,d1),a3              ; load start copy address
 
	@loop:
	    move.w  (a3)+,(a1)+             ; copy given sequence
        dbf     d2,@loop                ; repeat
        dbf     d3,@mainloop            ; if bits counter remains, parse the next word
        bra.s   @newblock               ; start a new block
 
	@end:
	    rts