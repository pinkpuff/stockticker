; The ResourceUpdateAddress should already be set (this doesn't set it).
; The ResourceUpdateData (1 or 2) address should be in 0001 to 0002
; The zero tile for the desired palette should be in 0003
; The number to be drawn should be stored in bcdResult.
; Uses X and Y but restores their previous values

DrawNumber:
   ldx #$04
   ldy #$00
@SkipInitialZeroLoop:
   lda bcdResult, x
   bne @RemainingDigits
   sta ($01), y
   dex
   iny
   cpy #$05
   bne @SkipInitialZeroLoop
   jmp @Done
@RemainingDigits:
   lda bcdResult, x
   clc
   ;adc #ZERO_PAL1
   adc $03
   sta ($01), y
   dex
   iny
   cpy #$05
   bne @RemainingDigits
@Done:
   rts
