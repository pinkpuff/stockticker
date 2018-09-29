; $0000 and $0001 contain the address of the nametable you wish to load
;  (including attribute information)
; $0002 contains the index of the nametable to write to (0, 1, 2, 3)

SetBackground:
   jsr WaitFrame
   lda #$00
   sta PPUMASK ;turn off rendering in order to write the entire background
   ldx $02
   beq @AddressFound
@FindAddressLoop:
   clc
   adc #$4
   dex
   bne @FindAddressLoop
@AddressFound:
   clc
   adc #$20
   sta PPUADDR
   lda #$00
   sta PPUADDR
   tay
   ldx #$04

@DrawBackgroundLoop:
   lda ($00), y
   sta PPUDATA
   iny
   bne @DrawBackgroundLoop
   inc $01
   dex
   bne @DrawBackgroundLoop

   lda ScrollX
   sta PPUSCROLL
   lda ScrollY
   sta PPUSCROLL
   
   ; turn the rendering back on
   jsr WaitFrame
   lda #%00011000
   sta PPUMASK
   rts
