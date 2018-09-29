; The player number (0 - 3) should be in memory address 0000

UpdateMoney:
   lda $00
   asl ;The resource totals are two bytes long so we need X to be double
   tax
   lda MoneyP1, x
   lsr
   lsr
   sta bcdNum
   lda MoneyP1+1, x
   lsr
   lsr
   sta bcdNum+1
   jsr bcdConvert
   ;Compute the address to display the number
   lda #$20
   sta ResourceUpdateAddress2
   lda #$AD
   sta ResourceUpdateAddress2+1
   ;If player number is even (offset is odd) add horizontal offset
   lda $00
   and #%00000001
   beq @Player3or4Money
   lda ResourceUpdateAddress2+1
   clc
   adc #$0A
   sta ResourceUpdateAddress2+1
   lda ResourceUpdateAddress2
   adc #$00
   sta ResourceUpdateAddress2
@Player3or4Money:
   ;If player number is greater than 2 (offset > 1) add vertical offset
   lda $00
   and #%00000010
   beq @MoneyData
   lda ResourceUpdateAddress2+1
   clc
   adc #$40
   sta ResourceUpdateAddress2+1
   lda ResourceUpdateAddress2
   adc #$01
   sta ResourceUpdateAddress2
@MoneyData:
   ;Queue up the appropriate digits to be drawn
   lda #<ResourceUpdateData2
   sta $01
   lda #>ResourceUpdateData2
   sta $02
   lda #ZERO_PAL1
   sta $03
   sta ResourceUpdateData2+5
   sta ResourceUpdateData2+6
   lda MoneyP1, x
   and #%00000011
   beq @DoneMoneyFinalDigits
   cmp #$01
   bne @Check2
   lda #ZERO_PAL1+2
   sta ResourceUpdateData2+5
   lda #ZERO_PAL1+5
   sta ResourceUpdateData2+6
   jmp @DoneMoneyFinalDigits
@Check2:
   cmp #$02
   bne @Check3
   lda #ZERO_PAL1+5
   sta ResourceUpdateData2+5 ;The final digit should already be 0
   jmp @DoneMoneyFinalDigits
@Check3:
   lda #ZERO_PAL1+7
   sta ResourceUpdateData2+5
   lda #ZERO_PAL1+5
   sta ResourceUpdateData2+6
@DoneMoneyFinalDigits:
   jsr DrawNumber
   rts

UpdateGrain:
   lda ResourceUpdateAddress1
   bne UpdateGrain
   lda $00
   asl ;The resource totals are two bytes long so we need X to be double
   tax
   lda GrainP1, x
   lsr
   sta bcdNum
   lda GrainP1+1, x
   lsr
   sta bcdNum+1
   jsr bcdConvert
   lda #$20
   sta ResourceUpdateAddress1
   lda #$CD
   sta ResourceUpdateAddress1+1
   jsr AddPlayerResourceAddress
   lda #<ResourceUpdateData1
   sta $01
   lda #>ResourceUpdateData1
   sta $02
   lda #ZERO_PAL2
   sta ResourceUpdateData1+5
   sta ResourceUpdateData1+6
   sta $03
   jsr DrawNumber
   jsr UpdateMoney
   rts
   
UpdateIndustry:
   lda ResourceUpdateAddress1
   bne UpdateIndustry
   lda $00
   asl ;The resource totals are two bytes long so we need X to be double
   tax
   lda IndustryP1, x
   sta bcdNum
   lda IndustryP1+1, x
   sta bcdNum+1
   jsr bcdConvert
   lda #$20
   sta ResourceUpdateAddress1
   lda #$ED
   sta ResourceUpdateAddress1+1
   jsr AddPlayerResourceAddress
   lda #<ResourceUpdateData1
   sta $01
   lda #>ResourceUpdateData1
   sta $02
   lda #ZERO_PAL3
   sta ResourceUpdateData1+5
   sta ResourceUpdateData1+6
   sta $03
   jsr DrawNumber
   jsr UpdateMoney
   rts
   
UpdateBonds:
   lda ResourceUpdateAddress1
   bne UpdateBonds
   lda $00
   asl ;The resource totals are two bytes long so we need X to be double
   tax
   lda BondsP1, x
   sta bcdNum
   lda BondsP1+1, x
   sta bcdNum+1
   jsr bcdConvert
   lda #$21
   sta ResourceUpdateAddress1
   lda #$0D
   sta ResourceUpdateAddress1+1
   jsr AddPlayerResourceAddress
   lda #<ResourceUpdateData1
   sta $01
   lda #>ResourceUpdateData1
   sta $02
   lda #ZERO_PAL2
   sta ResourceUpdateData1+5
   sta ResourceUpdateData1+6
   sta $03
   jsr DrawNumber
   jsr UpdateMoney
   rts
   
UpdateOil:
   lda ResourceUpdateAddress1
   bne UpdateOil
   lda $00
   asl ;The resource totals are two bytes long so we need X to be double
   tax
   lda OilP1, x
   sta bcdNum
   lda OilP1+1, x
   sta bcdNum+1
   jsr bcdConvert
   lda #$21
   sta ResourceUpdateAddress1
   lda #$2D
   sta ResourceUpdateAddress1+1
   jsr AddPlayerResourceAddress
   lda #<ResourceUpdateData1
   sta $01
   lda #>ResourceUpdateData1
   sta $02
   lda #ZERO_PAL3
   sta ResourceUpdateData1+5
   sta ResourceUpdateData1+6
   sta $03
   jsr DrawNumber
   jsr UpdateMoney
   rts
   
UpdateSilver:
   lda ResourceUpdateAddress1
   bne UpdateSilver
   lda $00
   asl ;The resource totals are two bytes long so we need X to be double
   tax
   lda SilverP1, x
   sta bcdNum
   lda SilverP1+1, x
   sta bcdNum+1
   jsr bcdConvert
   lda #$21
   sta ResourceUpdateAddress1
   lda #$4D
   sta ResourceUpdateAddress1+1
   jsr AddPlayerResourceAddress
   lda #<ResourceUpdateData1
   sta $01
   lda #>ResourceUpdateData1
   sta $02
   lda #ZERO_PAL2
   sta ResourceUpdateData1+5
   sta ResourceUpdateData1+6
   sta $03
   jsr DrawNumber
   jsr UpdateMoney
   rts
   
UpdateGold:
   lda ResourceUpdateAddress1
   bne UpdateGold
   lda $00
   asl ;The resource totals are two bytes long so we need X to be double
   tax
   lda GoldP1, x
   sta bcdNum
   lda GoldP1+1, x
   sta bcdNum+1
   jsr bcdConvert
   lda #$21
   sta ResourceUpdateAddress1
   lda #$6D
   sta ResourceUpdateAddress1+1
   jsr AddPlayerResourceAddress
   lda #<ResourceUpdateData1
   sta $01
   lda #>ResourceUpdateData1
   sta $02
   lda #ZERO_PAL3
   sta ResourceUpdateData1+5
   sta ResourceUpdateData1+6
   sta $03
   jsr DrawNumber
   jsr UpdateMoney
   rts
   
AddPlayerResourceAddress:
   ;If player number is even (offset is odd) add horizontal offset
   lda $00
   and #%00000001
   beq @Player3or4
   lda ResourceUpdateAddress1+1
   clc
   adc #$0A
   sta ResourceUpdateAddress1+1
   lda ResourceUpdateAddress1
   adc #$00
   sta ResourceUpdateAddress1
@Player3or4:
   ;If player number is greater than 2 (offset > 1) add vertical offset
   lda $00
   and #%00000010
   beq @DoneAddress
   lda ResourceUpdateAddress1+1
   clc
   adc #$40
   sta ResourceUpdateAddress1+1
   lda ResourceUpdateAddress1
   adc #$01
   sta ResourceUpdateAddress1
@DoneAddress:   
   rts
