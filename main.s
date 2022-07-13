.include "const.inc"
.include "ines-header.s"

.segment "ZEROPAGE"
addrL:  .res 1
addrH:  .res 1

.segment "CODE"
.include "reset.s"

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
    sta $0200, X
    inx
    cpx #$74
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

    lda #%10000000 ; enable NMI, sprites from Pattern 0, background from Pattern 1
    sta PPU_CTRL
    lda #%00011000 ; enable sprites, enable background
    sta PPU_MASK

    lda #$00
    sta PPU_SCROLL
    sta PPU_SCROLL

loop:
    jmp loop



; TODO: make functions for sprite and patterntable drawing
;       arguments: low byte, hight byte, size, X, Y

sdata:
        ; X    №    a    Y
    .byte $1B, $0A, $00, $10    ; NNN+NNN
    .byte $1B, $0A, $00, $18
    .byte $1B, $0A, $00, $20
    .byte $1B, $0C, $00, $28
    .byte $1B, $0A, $00, $30
    .byte $1B, $0A, $00, $38
    .byte $1B, $0A, $00, $40

    .byte $27, $1B, $00, $10    ; OUT:NNN
    .byte $27, $1C, $00, $18
    .byte $27, $1D, $00, $20
    .byte $27, $1E, $00, $28
    .byte $27, $0A, $00, $30
    .byte $27, $0A, $00, $38
    .byte $27, $0A, $00, $40
    
    ; 33 empty

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
    
.segment "OAM"

.segment "VECTORS"
    .word nmi
    .word reset
    .word main

.segment "TILES"
    .incbin "tiles.chr"