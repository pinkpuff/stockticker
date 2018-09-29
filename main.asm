Code:
;----------------------------------------------------------------
; constants
;----------------------------------------------------------------

PPUCTRL =   $2000
PPUMASK =   $2001
PPUSTATUS = $2002
OAMADDR =   $2003
OAMDATA =   $2004
PPUSCROLL = $2005
PPUADDR =   $2006
PPUDATA =   $2007
OAMDMA =    $4014
JOYSTICK1 = $4016
JOYSTICK2 = $4017

A_BUTTON =      %10000000
B_BUTTON =      %01000000
SELECT_BUTTON = %00100000
START_BUTTON =  %00010000
UP_BUTTON =     %00001000
DOWN_BUTTON =   %00000100
LEFT_BUTTON =   %00000010
RIGHT_BUTTON =  %00000001

GRAIN_INDEX =    %00000001
INDUSTRY_INDEX = %00000010
BONDS_INDEX =    %00000100
OIL_INDEX =      %00001000
SILVER_INDEX =   %00010000
GOLD_INDEX =     %00100000
CASH_INDEX =     %01000000

ZERO_PAL1 = $30
ZERO_PAL2 = $B4
ZERO_PAL3 = $F4

BCD_BITS = 19

PRG_COUNT = 2 ;1 = 16KB, 2 = 32KB
MIRRORING = %0001 ;%0000 = horizontal, %0001 = vertical, %1000 = four-screen

;----------------------------------------------------------------
; variables
;----------------------------------------------------------------

   .enum $0000

   ;NOTE: declare variables using the DSB and DSW directives, like this:

   ;MyVariable0 .dsb 1
   ;MyVariable1 .dsb 3

   .ende
   
   .enum $0010
      ;Used for waiting for the next frame
      Sleeping .dsb 1
      ;Controller reading
      ButtonsP1 .dsb 1
      ButtonsP2 .dsb 1
      ButtonsP3 .dsb 1
      ButtonsP4 .dsb 1
      PreviousButtonsP1 .dsb 1
      PreviousButtonsP2 .dsb 1
      PreviousButtonsP3 .dsb 1
      PreviousButtonsP4 .dsb 1
      PressedButtonsP1 .dsb 1
      PressedButtonsP2 .dsb 1
      PressedButtonsP3 .dsb 1
      PressedButtonsP4 .dsb 1
      ReleasedButtonsP1 .dsb 1
      ReleasedButtonsP2 .dsb 1
      ReleasedButtonsP3 .dsb 1
      ReleasedButtonsP4 .dsb 1
      ;Sprites
      SpritesNeedUpdate .dsb 1
      ;Background
      ResourceUpdateAddress1 .dsb 2
      ResourceUpdateData1 .dsb 7
      ResourceUpdateAddress2 .dsb 2
      ResourceUpdateData2 .dsb 7
      StockUpdateAddress .dsb 2
      StockUpdateData .dsb 21
      ;Scroll position
      ScrollX .dsb 1
      ScrollY .dsb 1
      ;Seed for RNG
      Seed .dsb 2
      ;Die faces
      StockDie .dsb 1
      ActionDie .dsb 1
      AmountDie .dsb 1
      ;Stock prices
      GrainPrice .dsb 1
      IndustryPrice .dsb 1
      BondsPrice .dsb 1
      OilPrice .dsb 1
      SilverPrice .dsb 1
      GoldPrice .dsb 1
      ;Player resources
      MoneyP1 .dsb 2
      MoneyP2 .dsb 2
      MoneyP3 .dsb 2
      MoneyP4 .dsb 2
      GrainP1 .dsb 2
      GrainP2 .dsb 2
      GrainP3 .dsb 2
      GrainP4 .dsb 2
      IndustryP1 .dsb 2
      IndustryP2 .dsb 2
      IndustryP3 .dsb 2
      IndustryP4 .dsb 2
      BondsP1 .dsb 2
      BondsP2 .dsb 2
      BondsP3 .dsb 2
      BondsP4 .dsb 2
      OilP1 .dsb 2
      OilP2 .dsb 2
      OilP3 .dsb 2
      OilP4 .dsb 2
      SilverP1 .dsb 2
      SilverP2 .dsb 2
      SilverP3 .dsb 2
      SilverP4 .dsb 2
      GoldP1 .dsb 2
      GoldP2 .dsb 2
      GoldP3 .dsb 2
      GoldP4 .dsb 2
      ;Used for binary to decimal conversion routine
      bcdNum .dsb 2
      bcdResult .dsb 5
      curDigit .dsb 1
      b .dsb 1
      ;Flags initial 0s to prevent drawing them
      FoundFirstDigit .dsb 1
      ;Used for debugging purposes
      DebugValue .dsb 1
   .ende

   ;NOTE: you can also split the variable declarations into individual pages, like this:

   .enum $0100
      BackgroundBuffer .dsb 160
   .ende

   .enum $0200
      SpriteBuffer .dsb 256
   .ende
   
   .enum $0300
      MusicBuffer .dsb 256
   .ende
   
;----------------------------------------------------------------
; iNES header
;----------------------------------------------------------------

   ;.db "NES", $1a ;identification of the iNES header
   ;.db $02 ;number of 16KB PRG-ROM pages
   ;.db $01 ;number of 8KB CHR-ROM pages
   ;.db $00 ;NROM
   ;.dsb 9, $00 ;clear the remaining bytes

.db "NES",$1A
.db 2,1,$00
.db 0,0,0,0,0,0,0,0,0

;----------------------------------------------------------------
; program bank(s)
;----------------------------------------------------------------

   .base $10000-(PRG_COUNT*$4000)

NMI:

   .include nmi.asm
   ;rti

IRQ:

   ;.include irq.asm
   rti

;Generic subroutines
   
   .include waitframe.asm
   .include setbackground.asm
   .include setpalette.asm
   .include rng.asm
   .include binary-to-decimal.asm
   .include drawnumber.asm
   .include updateresource.asm
   .include updateticker.asm
   .include rolldice.asm
   .include executeaction.asm

Reset:

   .include initialize.asm
   
   ;Set the palettes
   lda #<BoardPalette
   sta $00
   lda #>BoardPalette
   sta $01
   jsr SetPalette
   
   ;Turn on NMIs
   inc SpritesNeedUpdate
   lda #%10001000
   sta PPUCTRL

   ;Load title screen
   lda #<TitleScreen
   sta $00
   lda #>TitleScreen
   sta $01
   lda #$00
   sta $02
   jsr SetBackground

   
ShowTitle:
   ;Wait for keypress and set seed
   clc
   lda Seed
   adc #$01
   sta Seed
   lda Seed+1
   adc #$00
   sta Seed+1
   lda PressedButtonsP1
   and #START_BUTTON
   beq ShowTitle
   lda Seed
   bne @GoodSeed
   lda Seed+1
   bne @GoodSeed
   clc
   lda Seed
   adc #$01
   sta Seed
   lda Seed+1
   adc #$00
   sta Seed+1

@GoodSeed:   
   ;The first result is always 0 for some reason so let's throw that away
   jsr RNG

   ;;Roll the dice (for testing purposes only; there will be a "real" routine later)
   ;jsr RNG
   ;sta StockDie
   ;jsr RNG
   ;sta ActionDie
   ;jsr RNG
   ;sta AmountDie
   
   ;;Random initial values for testing
   ;ldy #$00
;@InitialResourceLoop:
   ;jsr RNG
   ;sta MoneyP1, y
   ;jsr RNG
   ;sta GrainP1, y
   ;jsr RNG
   ;sta IndustryP1, y
   ;jsr RNG
   ;sta BondsP1, y
   ;jsr RNG
   ;sta OilP1, y
   ;jsr RNG
   ;sta SilverP1, y
   ;jsr RNG
   ;sta GoldP1, y
   ;iny
   ;iny
   ;cpy #$08
   ;bne @InitialResourceLoop

   lda #$28
   sta MoneyP1
   sta MoneyP2
   sta MoneyP3
   sta MoneyP4
   lda #$00
   sta MoneyP1+1
   sta MoneyP2+1
   sta MoneyP3+1
   sta MoneyP4+1
   
   ldx #$00
@InitialResourceLoop:
   lda #$02
   sta GrainP1, x
   sta IndustryP1, x
   sta BondsP1, x
   sta OilP1, x
   sta SilverP1, x
   sta GoldP1, x
   inx
   lda #$00
   sta GrainP1+1, x
   sta IndustryP1+1, x
   sta BondsP1+1, x
   sta OilP1+1, x
   sta SilverP1+1, x
   sta GoldP1+1, x
   inx
   cpx #$08
   bne @InitialResourceLoop
   
   ;lda #$20
   ;sta GrainPrice
   ;lda #$15
   ;sta IndustryPrice
   ;lda #$13
   ;sta BondsPrice
   ;lda #$0A
   ;sta OilPrice
   ;lda #$23
   ;sta SilverPrice
   ;lda #$17
   ;sta GoldPrice
   
   lda #$14
   sta GrainPrice
   sta IndustryPrice
   sta BondsPrice
   sta OilPrice
   sta SilverPrice
   sta GoldPrice
   
LoadBoard:
   ;Set the background
   lda #<BoardBackground
   sta $00
   lda #>BoardBackground
   sta $01
   lda #$00
   sta $02
   jsr SetBackground

   lda #$00
   sta PPUMASK
   
   lda #$00
   sta $00
@InitialResourceDisplayLoop:
   jsr UpdateGrain
   jsr UpdateIndustry
   jsr UpdateBonds
   jsr UpdateOil
   jsr UpdateSilver
   jsr UpdateGold
   inc $00
   lda $00
   cmp #$04
   bne @InitialResourceDisplayLoop
   
   ldx #$00
   jsr UpdateTicker
   jsr WaitFrame
   inx
   jsr UpdateTicker
   jsr WaitFrame
   inx
   jsr UpdateTicker
   jsr WaitFrame
   inx
   jsr UpdateTicker
   jsr WaitFrame
   inx
   jsr UpdateTicker
   jsr WaitFrame
   inx
   jsr UpdateTicker
   
   lda #$2F
   sta SpriteBuffer
   lda #$01
   sta SpriteBuffer+1
   lda #$00
   sta SpriteBuffer+2
   lda #$58
   sta SpriteBuffer+3
   
   lda #$2F
   sta SpriteBuffer+4
   lda #$01
   sta SpriteBuffer+5
   lda #$00
   sta SpriteBuffer+6
   lda #$A8
   sta SpriteBuffer+7
   
   lda #$7F
   sta SpriteBuffer+8
   lda #$01
   sta SpriteBuffer+9
   lda #$00
   sta SpriteBuffer+10
   lda #$58
   sta SpriteBuffer+11
   
   lda #$7F
   sta SpriteBuffer+12
   lda #$01
   sta SpriteBuffer+13
   lda #$00
   sta SpriteBuffer+14
   lda #$A8
   sta SpriteBuffer+15
   
   
   inc SpritesNeedUpdate
   jsr WaitFrame
   lda #%00011000
   sta PPUMASK

   
Main:
   ldx #$00
   ldy #$00
   lda #$2F
   sta $01
   lda #$57
   sta $02
@ControllerLoop:
   lda PressedButtonsP1, x
   and #DOWN_BUTTON
   beq @NoDown
   lda SpriteBuffer, y
   cmp $02
   beq @NoDown
   clc
   adc #$08
   sta SpriteBuffer, y
   lda #$01
   sta SpritesNeedUpdate
@NoDown:
   lda PressedButtonsP1, x
   and #UP_BUTTON
   beq @NoUp
   lda SpriteBuffer, y
   cmp $01
   beq @NoUp
   sec
   sbc #$08
   sta SpriteBuffer, y
   lda #$01
   sta SpritesNeedUpdate
@NoUp:
   iny
   iny
   iny
   iny
   inx
   cpx #$02
   bne @DontAdjustBounds
   lda #$7F
   sta $01
   lda #$A7
   sta $02
@DontAdjustBounds:
   cpx #$04
   bne @ControllerLoop
   
   lda PressedButtonsP1
   and #START_BUTTON
   beq @NoRoll
   jsr RollDice
   jsr ExecuteAction
@NoRoll:
   
   jsr WaitFrame
   jmp Main

BoardPalette:
   ;Background palettes
   .db $0F, $30, $16, $1A ;Red/green      (dice/$)
   .db $0F, $30, $28, $25 ;Yellow/pink    (Grain/Industry)
   .db $0F, $30, $29, $11 ;Green/blue     (Bonds/Oil)
   .db $0F, $30, $3C, $18 ;Metallic/brown (Silver/Gold)
   ;Sprite palettes
   .db $0F, $30, $16, $1A ;$2A
   .db $0F, $30, $28, $25
   .db $0F, $30, $29, $11
   .db $0F, $30, $3C, $18

TitleScreen:
   .incbin "titlescreen.nam"

BoardBackground:
   .incbin "mainboard.nam"

;----------------------------------------------------------------
; interrupt vectors
;----------------------------------------------------------------

   .org $fffa

   .dw NMI
   .dw Reset
   .dw IRQ

;----------------------------------------------------------------
; CHR-ROM bank
;----------------------------------------------------------------

   .incbin "stock.chr"
   
