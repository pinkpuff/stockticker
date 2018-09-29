; Returns a random 8-bit number in A (0-255), clobbers X (0).
; Requires a 2-byte value on the zero page called "Seed".
RNG:
   ldx #8
   lda Seed+0
@Shift:
   asl
   rol Seed+1
   bcc @Continue
   eor #$2D
@Continue:
   dex
   bne @Shift
   sta Seed+0
   cmp #0
   rts
