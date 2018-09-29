SetPalette:
   lda #$3F
   sta PPUADDR
   lda #$00
   sta PPUADDR
   tay

@set_palette_loop:
   lda ($00), y
   sta PPUDATA
   iny
   cpy #$20
   bne @set_palette_loop
   rts
