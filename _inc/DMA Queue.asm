; ---------------------------------------------------------------------------
; Subroutine for queueing VDP commands (seems to only queue transfers to VRAM),
; to be issued the next time ProcessDMAQueue is called.
; Can be called a maximum of 18 times before the buffer needs to be cleared
; by issuing the commands (this subroutine DOES check for overflow)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_144E: DMA_68KtoVRAM: QueueCopyToVRAM: QueueVDPCommand: Add_To_DMA_Queue:
QueueDMATransfer: ; First 2 lines for VIntSafeDMA
		move.w	sr,-(sp)
		move.w	#$2700,sr

		movea.w	(VDP_Command_Buffer_Slot).w,a1
		cmpa.w	#VDP_Command_Buffer_Slot,a1
		beq.s	QueueDMATransfer_Done	; return if there's no more room in the buffer

		lsr.l	#1,d1					; Source address is in words for the VDP registers
		move.w	d1,d0					; d0 = (src_address >> 1) & $FFFF
		subq.w  #1,d0					; To guard against the case where (d0+d3)&$FFFF == 0
		; Note: unless you modded your Genesis for 128kB of VRAM, then d3 can be at
		; most $7FFF here in a valid call; we will assume this is the case
		add.w	d3,d0								; d0 = ((src_address >> 1) & $FFFF) + (xfer_len >> 1)
		bcs.s	QueueDMATransfer_double_transfer	; Carry set = ($10000 << 1) = $20000, or new 128kB block

		; Store VDP commands for specifying DMA into the queue
		swap	d1					; Want the high byte first
		move.w	#$977F,d0			; Command to specify source address & $FE0000, plus bitmask for the given byte
		and.b	d1,d0				; Mask in source address & $FE0000, stripping high bit in the process
		move.w	d0,(a1)+			; Store command
		move.w	d3,d1				; Put length together with (source address & $01FFFE) >> 1...
		movep.l	d1,1(a1)			; ... and stuff them all into RAM in their proper places (movep for the win)
		lea	8(a1),a1				; Skip past all of these commands

		lsl.l	#2,d2				; Move high bits into (word-swapped) position, accidentally moving everything else
		addq.w	#1,d2				; Add write bit...
		ror.w	#2,d2				; ... and put it into place, also moving all other bits into their correct (word-swapped) places
		swap	d2					; Put all bits in proper places
		andi.w	#3,d2				; Strip whatever junk was in upper word of d2
		tas.b	d2					; Add in the DMA bit -- tas fails on memory, but works on registers
		move.l	d2,(a1)+			; Store command

		clr.w	(a1)				; Put a stop token at the end of the used part of the queue
		move.w	a1,(VDP_Command_Buffer_Slot).w	; Set the next free slot address, potentially undoing the above clr (this is intentional!)

; return_14AA:
QueueDMATransfer_Done:
		move.w	(sp)+,sr			; Restore interrupts to previous state
		rts
; End of function QueueDMATransfer

QueueDMATransfer_double_transfer:
		; Hand-coded version to break the DMA transfer into two smaller transfers
		; that do not cross a 128kB boundary. This is done much faster (at the cost
		; of space) than by the method of saving parameters and calling the normal
		; DMA function twice, as Sonic3_Complete does.
		; If we got here, d0 now has bit 15 clear
		; d0 is the number of words that got over the end of the 128kB boundary
		addq.w  #1,d0
		sub.w	d0,d3	; First transfer will use only up to the end of the 128kB boundary
		; Store VDP commands for specifying DMA into the queue
		swap	d1	; Want the high byte first
		; Sadly, all registers we can spare are in use right now, so we can't use
		; no-cost RAM source safety.
		andi.w	#$7F,d1					; Strip high bit
		ori.w	#$9700,d1				; Command to specify source address & $FE0000
		move.w	d1,(a1)+				; Store command
		addq.b	#1,d1					; Advance to next 128kB boundary (**)
		move.w	d1,12(a1)				; Store it now (safe to do in all cases, as we will overwrite later if queue got filled) (**)
		move.w	d3,d1					; Put length together with (source address & $01FFFE) >> 1...
		movep.l	d1,1(a1)				; ... and stuff them all into RAM in their proper places (movep for the win)
		lea	8(a1),a1				; Skip past all of these commands

		move.w	d2,d3					; Save for later
		lsl.l	#2,d2					; Move high bits into (word-swapped) position, accidentally moving everything else
		addq.w	#1,d2					; Add write bit...
		ror.w	#2,d2					; ... and put it into place, also moving all other bits into their correct (word-swapped) places
		swap	d2					; Put all bits in proper places
		andi.w	#3,d2					; Strip whatever junk was in upper word of d2
		tas.b	d2					; Add in the DMA bit -- tas fails on memory, but works on registers
		move.l	d2,(a1)+				; Store command

		cmpa.w	#VDP_Command_Buffer_Slot,a1		; Did this command fill the queue?
		beq.s	@skip_second_transfer			; Branch if so

		; Store VDP commands for specifying DMA into the queue
		; The source address high byte was done above already in the comments marked
		; with (**)
		ext.l	d0								; Since d0 was at most $7FFF, fills high word with 0: this corresponds to a 128kB block start
		movep.l	d0,3(a1)						; ... and stuff them all into RAM in their proper places (movep for the win)
		lea	10(a1),a1							; Skip past all of these commands
		; d1 contains length up to the end of the 128kB boundary
		add.w	d1,d1							; Convert it into byte length...
		add.w	d1,d3							; ... and offset destination by the correct amount
		lsl.l	#2,d3							; Move high bits into (word-swapped) position, accidentally moving everything else
		addq.w	#1,d3							; Add write bit...
		ror.w	#2,d3							; ... and put it into place, also moving all other bits into their correct (word-swapped) places
		swap	d3								; Put all bits in proper places
		andi.w	#3,d3							; Strip whatever junk was in upper word of d3
		tas.b	d3								; Add in the DMA bit -- tas fails on memory, but works on registers
		move.l	d3,(a1)+						; Store command

		clr.w	(a1)							; Put a stop token at the end of the used part of the queue
		move.w	a1,(VDP_Command_Buffer_Slot).w	; Set the next free slot address, potentially undoing the above clr (this is intentional!)

		move.w	(sp)+,sr						; Restore interrupts to previous state
		rts
	; ---------------------------------------------------------------------------
	@skip_second_transfer:
		move.w	a1,(a1)							; Set the next free slot address, overwriting what the second (**) instruction did
		move.w	(sp)+,sr						; Restore interrupts to previous state
		rts
; End of function QueueDMATransfer
; ===========================================================================


; BLOCKS BELOW ARE COMPLETED

; ---------------------------------------------------------------------------
; Subroutine for issuing all VDP commands that were queued
; (by earlier calls to QueueDMATransfer)
; Resets the queue when it's done
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_14AC: CopyToVRAM: IssueVDPCommands: Process_DMA: Process_DMA_Queue:
ProcessDMAQueue:
		lea	(vdp_control_port).l,a5
		lea	(VDP_Command_Buffer).w,a1
		move.w	a1,(VDP_Command_Buffer_Slot).w
; loc_14B6:
;ProcessDMAQueue_Loop:
		rept (VDP_Command_Buffer_Slot-VDP_Command_Buffer)/(7*2)
		move.w	(a1)+,d0
		beq.w	ProcessDMAQueue_Done ; branch if we reached a stop token
		; issue a set of VDP commands...
		move.w	d0,(a5)		; transfer length
		move.l	(a1)+,(a5)	; transfer length + source address
		move.l	(a1)+,(a5)	; source address
		move.l	(a1)+,(a5)	; destination
		endr
		;cmpa.w	#$C8FC,a1
		;bne.s	ProcessDMAQueue_Loop ; loop if we haven't reached the end of the buffer
; loc_14CE:
ProcessDMAQueue_Done:
		move.w	#0,(VDP_Command_Buffer).w
		rts
; End of function ProcessDMAQueue

; ---------------------------------------------------------------------------
; Subroutine for initializing the DMA queue.
; In comments is an example on how to optimize loops. Commented out is the old way, with the new way shown next to it
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

InitDMAQueue:
		lea	(VDP_Command_Buffer).w,a1
		move.w	#0,(a1)
		move.w	a1,(VDP_Command_Buffer_Slot).w
		move.l	#$96959493,d1

;-------------------------------------------------------------
;InitDMAQueue_Loop:
		rept (VDP_Command_Buffer_Slot-VDP_Command_Buffer)/(7*2)
;-------------------------------------------------------------

		movep.l	d1,2(a1)
		lea	14(a1),a1

;--------------------------------------------------------------
		endr
;		cmpa.w	#$C8FC,a1
;		bne.s	InitDMAQueue_Loop ; loop if we haven't reached the end of the buffer
;InitDMAQueue_Done:
;---------------------------------------------------------------

		rts
; End of function InitDMAQueue
; ===========================================================================