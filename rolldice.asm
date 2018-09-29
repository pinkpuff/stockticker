;Rolls the dice and stores the results in StockDie, ActionDie, and AmountDie.
;Sprites updated to reflect die faces
;
;StockDie holds a value 0 to 5 corresponding to the stock index.
;ActionDie holds a value 0 to 2 representing which action to take:
;0 - Up
;1 - Down
;2 - Div
;AmountDie holds a value 0 to 2 representing "how much" to do the action by:
;0 - "by 5"
;1 - "by 10"
;2 - "by 20"
;
;======

RollDice:
   lda #$00
   sta StockDie
   sta ActionDie
   sta AmountDie
   
   jsr RNG
@StockDieLoop:
   cmp #$06
   bcc @StockDieDone
   sec
   sbc #$06
   jmp @StockDieLoop
@StockDieDone:
   sta StockDie
   clc
   adc #$04 ;Get the appropriate stock symbol for the die face sprite
   sta SpriteBuffer+17
   lda #$BF
   sta SpriteBuffer+16
   lda StockDie
   lsr
   clc
   adc #$01 ;Palette index is (stock index / 2) + 1
   sta SpriteBuffer+18
   lda #$B0
   sta SpriteBuffer+19
   
   jsr RNG
@ActionDieLoop:
   cmp #$03
   bcc @ActionDieDone
   sec
   sbc #$03
   jmp @ActionDieLoop
@ActionDieDone:
   sta ActionDie
   clc
   adc #$2D ;Get the appropriate action symbol for the die face sprite
   sta SpriteBuffer+21
   lda #$BF
   sta SpriteBuffer+20
   lda #$00
   sta SpriteBuffer+22
   lda #$C8
   sta SpriteBuffer+23
   
   jsr RNG
@AmountDieLoop:
   cmp #$03
   bcc @AmountDieDone
   sec
   sbc #$03
   jmp @AmountDieLoop
@AmountDieDone:
   sta AmountDie
   clc
   adc #$7B ;Get the appropriate amount symbol for the die face sprite
   sta SpriteBuffer+25
   lda #$BF
   sta SpriteBuffer+24
   lda #$00
   sta SpriteBuffer+26
   lda #$E0
   sta SpriteBuffer+27

   lda #$01
   sta SpritesNeedUpdate
   rts
