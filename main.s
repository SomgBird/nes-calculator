.include "const.inc"
.include "ines-header.s"

.segment "ZEROPAGE"
addrL:  .res 1
addrH:  .res 1
buttons: .res 1
pressedButtons: .res 1
releasedButtons: .res 1
lastFrameButtons: .res 1
cursorX: .res 1, $00
cursorY: .res 1, $00
palette: .res 1

firstOpHundreds: .res 1, $00
firstOpTens: .res 1, $00
firstOpOnes: .res 1, $00

secondOpHundreds: .res 1, $00
secondsOpTens: .res 1, $00
secondsOpOnes: .res 1, $00

outHundreds: .res 1, $00
outTens: .res 1, $00
outOnes: .res 1, $00

currentNumberMemoryAddr: .res 1
currentNumberTileAddr: .res 2
tmpPtr: .res 2 

selection: .res 1, $00
selectionFlag: .res 1, $00

operationFlag: .res 1   ; ---- PMPD
                        ;   P - plus
                        ;   M - minus
                        ;   P - product
                        ;   D - divide
numberFlag: .res 1 ; ---- -OTN
                        ;   O - writing ones
                        ;   T - writing tens
                        ;   H - writing hundreds

.segment "CODE"
.include "reset.s"
.include "read_input.s"
.include "update_info_panel.s"

main:
load_palettes:
    lda PPU_STATUS
    lda #$3F
    sta PPU_PPUADDR
    lda #$00
    sta PPU_PPUADDR
    ldx #$00
@loop:
    lda pdata, X
    sta PPU_PPUDATA ; write palette to PPU, PPU iterates after each write
    inx
    cpx #$20
    bne @loop

sprite_load:
    ldx #$00
@loop:
    lda sdata, X
    sta SPRITE_ADDR, X
    inx
    cpx #$3C
    bne @loop

load_nametable:
    lda PPU_STATUS
    lda #$20
    sta PPU_PPUADDR
    lda #$00
    sta PPU_PPUADDR
    lda #<nametable ; low byte
    sta addrL
    lda #>nametable ; high bute
    sta addrH
    ldy #$00        ; loop counter
    ldx #$04        ; times to repeat
@loop:
    lda (addrL), y  
    sta PPU_PPUDATA ; load nametable byte (256 * 4 bytes in total)
    iny
    bne @loop       ; if not 256 time - continue
    inc addrH       ; change high byte
    dex
    bne @loop

; load_attributes:
;     lda PPU_STATUS
;     lda #$23
;     sta PPU_PPUADDR
;     lda #$C0
;     sta PPU_PPUADDR
;     ldx #$00
; @loop:
;     lda attribute, X
;     sta PPU_PPUDATA
;     inx
;     cpx #$10
;     bne @loop

    lda #CURSOR_PALETTE
    sta palette
    jsr ChangeSpriteParams    ; update first selected button

    lda #%10000000 ; enable NMI, sprites from Pattern 0, background from Pattern 0
    sta PPU_CTRL
    lda #%00011110 ; enable sprites, enable background
    sta PPU_MASK

    lda #%000000100
    sta numberFlag
    lda #>FIRST_ONES_TILE_ADDR
    sta >currentNumberTileAddr
    lda #<FIRST_ONES_TILE_ADDR
    sta <currentNumberTileAddr

    lda #firstOpOnes
    sta currentNumberMemoryAddr

    lda #$08
    sta operationFlag

forever:
    jmp forever


nmi:
    ; standard NMI beginning
    lda #$00
    sta PPU_OAMADDR ; set the low byte of RAM
    lda #$02        ; set the high byte of RAM, and transfer
    sta PPU_OAMDMA

    jsr UpdateInput
    jsr HandleInput
    jsr UpdateNumbers
    
    lda #%10000000 ; enable NMI, sprites from Pattern 0, background from Pattern 1
    sta PPU_CTRL
    lda #%00011110 ; enable sprites, enable background
    sta PPU_MASK

    lda #$00
    sta PPU_SCROLL
    sta PPU_SCROLL

    rti

sdata:
        ; Y    №    a    X
    .byte $3F, $07, $00, $18    ; 789 0=
    .byte $3F, $08, $00, $20
    .byte $3F, $09, $00, $28
    .byte $3F, $0A, $00, $38
    .byte $3F, $0B, $00, $40

    .byte $4B, $04, $00, $18    ; 456 +-
    .byte $4B, $05, $00, $20
    .byte $4B, $06, $00, $28
    .byte $4B, $0C, $00, $38
    .byte $4B, $0D, $00, $40

    .byte $57, $01, $00, $18    ; 123 */
    .byte $57, $02, $00, $20
    .byte $57, $03, $00, $28
    .byte $57, $0E, $00, $38
    .byte $57, $0F, $00, $40

pdata:
    .incbin "nametable_palettes.pal"
    .incbin "sprites_palettes.pal"

nametable:
    .incbin "background.nam"

; attribute:
;     .byte %00000000,%00000000,%00000000, %00000000, %00000000, %00000000, %00000000,%00000000
;     .byte %00000000,%00000000,%00000000, %00000000, %00000000, %00000000, %00000000,%00000000
    
keymap:
    .byte $07, $08, $09, $0A, $0B   ; 789 0=
    .byte $04, $05, $06, $0C, $0D   ; 456 +-
    .byte $01, $02, $03, $0E, $0F   ; 123 */

.segment "OAM"

.segment "VECTORS"
    .word nmi
    .word reset
    .word main

.segment "TILES"
    .incbin "tiles.chr"