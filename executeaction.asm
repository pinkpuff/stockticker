;Do what it says on the dice.
;Uses both X and Y.
;=====
;$0000-$0001 are used to store a temproary address
;$0002 is used to temporarily store player index

ExecuteAction:
   ldx StockDie
   lda ActionDie
   beq @StockGoUp
   cmp #$01
   beq @StockGoDown

   ;Otherwise div
   lda GrainPrice, x
   cmp #$14
   bcc @NoDiv ;Only div if stock price is on or above div line
   ldy #$00
@DivLoop:
   jsr DivStock
   iny
   cpy #$04
   bne @DivLoop
@NoDiv:
   rts
   
@StockGoUp:
   lda #$01
   ldy AmountDie
@StockUpLoop:
   beq @DoneStockUp
   asl
   dey
   jmp @StockUpLoop
@DoneStockUp:
   clc
   adc GrainPrice, x
   sta GrainPrice, x
   jsr UpdateTicker
   rts
   
@StockGoDown:
   lda #$01
   ldy AmountDie
@StockDownLoop:
   beq @DoneStockDown
   asl
   dey
   jmp @StockDownLoop
@DoneStockDown:
   sec
   sbc GrainPrice, x
   sta GrainPrice, x
   jsr UpdateTicker
   rts

DivStock:
   lda #<GrainP1
   sta $00
   lda #>GrainP1
   sta $01
   txa
   asl
   asl
   clc
   adc $00
   sta $00
   lda #$00
   adc $01
   sta $01
   lda ($00), y ;Now A should contain the amount of the stock the player has
   sty $02
   ldy AmountDie
@DoublingLoop:
   beq @DoneDoubling
   asl
   dey
   jmp @DoublingLoop
@DoneDoubling:
   ;A should now contain the stock amount multiplied by the appropriate factor
   ldy $02
   clc
   adc MoneyP1, y
   sta MoneyP1, y
   lda #$00
   adc MoneyP1, y
   sta MoneyP1, y
   rts
   
   
