; X should contain the index of the stock to be updated.
; Y is used for various loops
;----
;$0000 - Stock index (X) parity * #$10 (for determining color)
;$0001 - Offset (Y) of cap tile
;$0002 - Border cap tile

UpdateTicker:
   ;Trigger debugger
   sta $F0
   
   ;Determine color
   txa
   and #%00000001
   asl ;Multiply by 16 (double four times) to get #$10 if odd or #$00 if even
   asl
   asl
   asl 
   sta $00
   
   ;Determine the cap position
   lda #$29
   sec
   sbc GrainPrice, x
   lsr ; [41 (#$29) minus price] / 2 = tile position of cap (could be 0)
   sta $01
   
   ;Determine cap tile
   lda #$0C ;Full-bar tile
   clc
   adc $00
   sta $02
   lda GrainPrice, x
   and #%00000001
   bne @CheckLow ;Odd needs a full bar above div line but a blank below
   ;It's even so it's a half-bar
   dec $02
@CheckLow:
   lda GrainPrice, x
   cmp #$14
   bcs @DoneCap ;It was high so we're done
   and #%00000001
   beq @DecAgain
   lda #$00 ;It's odd and low, so we need a blank
   sta $02
@DecAgain:
   ;It's even and low, so dec again to get bottom half-bar
   dec $02
@DoneCap:
   
   ;Fill the entire column with full-bars
   lda $00
   clc
   adc #$0C ;Full-bar tile
   ldy #$14
@FullBarLoop:
   sta StockUpdateData, y
   dey
   bne @FullBarLoop
   
   ;Fill the top portion with blanks down to the div line or cap tile
   lda $01
   beq @DoneTopBlanks
   cmp #$0A
   bcc @TopFill
   lda #$0A
@TopFill:
   tay
   lda #$00 ;Blank tile
@TopFillLoop:
   sta StockUpdateData, y
   cpy #$00 ;It's done this way to avoid overflow (Y might start at 0)
   beq @DoneTopBlanks
   dey
   jmp @TopFillLoop
@DoneTopBlanks:

   ;Fill the bottom portion with blanks up to the div line or cap tile
   ldy $01
   cmp #$14
   beq @DoneBottomBlanks
   cpy #$0A
   bcs @BottomFill
   ldy #$0A
@BottomFill:
   lda #$00 ;Blank tile
@BottomFillLoop:
   sta StockUpdateData, y
   cpy #$14
   beq @DoneBottomBlanks
   iny
   jmp @BottomFillLoop
@DoneBottomBlanks:

   ;Put the proper border tile in
   lda $02
   ldy $01
   sta StockUpdateData, y
   
   ;Put the proper div line tile in the middle
   lda #$0F
   clc
   adc $00
   sta StockUpdateData+10
   lda GrainPrice, x
   cmp #$14
   beq @DoneDivLine
   dec StockUpdateData+10
   cmp #$14
   bcs @DoneDivLine
   dec StockUpdateData+10
@DoneDivLine:
   
   ;Store the update address to indicate it's ready to update next frame
   txa
   clc
   adc #$64
   sta StockUpdateAddress+1
   lda #$20
   sta StockUpdateAddress

   ;Finished
   rts
