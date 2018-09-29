;NMI:
   pha ;Save state
   txa
   pha
   tya
   pha
   
ReadJoysticks:
   lda ButtonsP1
   sta PreviousButtonsP1
   lda ButtonsP2
   sta PreviousButtonsP2
   lda ButtonsP3
   sta PreviousButtonsP3
   lda ButtonsP4
   sta PreviousButtonsP4
   lda #$01
   sta JOYSTICK1
   sta ButtonsP1
   sta ButtonsP2
   sta ButtonsP3
   sta ButtonsP4
   lsr a
   sta JOYSTICK1

@JoystickP1Loop:
   lda JOYSTICK1
   lsr a
   rol ButtonsP1
   bcc @JoystickP1Loop
@JoystickP3Loop:
   lda JOYSTICK1
   lsr a
   rol ButtonsP3
   bcc @JoystickP3Loop

   lda #$01
   sta JOYSTICK2
   lsr a
   sta JOYSTICK2

@JoystickP2Loop:
   lda JOYSTICK2
   lsr a
   rol ButtonsP2
   bcc @JoystickP2Loop
@JoystickP4Loop:
   lda JOYSTICK2
   lsr a
   rol ButtonsP4
   bcc @JoystickP4Loop

;@JoystickReadLoop:
   ;lda JOYSTICK1
   ;and #$03
   ;cmp #$01
   ;rol ButtonsP1
   ;lda JOYSTICK2
   ;and #$03
   ;cmp #$01
   ;rol ButtonsP2
   ;lda JOYSTICK1
   ;and #$03
   ;cmp #$01
   ;rol ButtonsP3
   ;lda JOYSTICK2
   ;and #$03
   ;cmp #$01
   ;rol ButtonsP4
   ;bcc @JoystickReadLoop

   ldx #$00
@StoreButtons:
   lda ButtonsP1,x
   eor #$FF
   and PreviousButtonsP1,x
   sta ReleasedButtonsP1,x
   lda PreviousButtonsP1,x
   eor #$FF
   and ButtonsP1,x
   sta PressedButtonsP1,x
   inx
   cpx #$04
   bne @StoreButtons
     
DrawSprites:
   lda SpritesNeedUpdate
   beq UpdateBackground
   lda #$00
   sta OAMADDR
   lda #>SpriteBuffer
   sta OAMDMA
   dec SpritesNeedUpdate
   
UpdateBackground:
   bit PPUSTATUS
   lda ResourceUpdateAddress1
   beq @CheckResource2
   sta PPUADDR
   lda ResourceUpdateAddress1+1
   sta PPUADDR
   ldx #$00
@Resource1Loop:
   lda ResourceUpdateData1,x
   sta PPUDATA
   inx
   cpx #$07
   bne @Resource1Loop

@CheckResource2:
   lda ResourceUpdateAddress2
   beq @CheckStock
   sta PPUADDR
   lda ResourceUpdateAddress2+1
   sta PPUADDR
   ldx #$00
@Resource2Loop:
   lda ResourceUpdateData2,x
   sta PPUDATA
   inx
   cpx #$07
   bne @Resource2Loop

@CheckStock:
   lda StockUpdateAddress
   beq @ClearBackgroundUpdates
   sta PPUADDR
   lda StockUpdateAddress+1
   sta PPUADDR
   lda #%10001100 ;draw going down
   sta PPUCTRL
   ldx #$00
@StockLoop:
   lda StockUpdateData, x
   sta PPUDATA
   inx
   cpx #$15
   bne @StockLoop

@ClearBackgroundUpdates:
   lda #%10001000
   sta PPUCTRL ;restore draw horizontal mode in case it was changed
   lda #$00
   sta ResourceUpdateAddress1
   sta ResourceUpdateAddress2
   sta StockUpdateAddress

   
SetScrollPosition:
   bit PPUSTATUS
   lda ScrollX
   sta PPUSCROLL
   lda ScrollY
   sta PPUSCROLL

   ;Signal to the "WaitFrame" subroutine that the frame is done
   lda #$00
   sta Sleeping
   
   pla ;Restore state
   tay
   pla
   tax
   pla

   rti

