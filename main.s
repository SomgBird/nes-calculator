.include "const.inc"
.include "ines-header.s"

.segment "ZEROPAGE"
.segment "CODE"


.include "reset.s"


main:
    ldx #$00
@pload:
    lda pdata, X
    sta PPU_PPUDATA ; write palette to PPU, PPU iterates after each write
    inx
    cpx #$20
    bne @pload

    ldx #$00
@sload:
    lda sdata, X
    sta $0200, X
    inx
    cpx #$40
    bne @sload
    cli
    lda #%10000000  ; enable NMI
    sta PPU_CTRL
    lda #%00010000  ; enable sprites
    sta PPU_MASK


@loop:
    jmp @loop

sdata:
        ; X   №   a   Y
    .byte $40, $00, $00, $08
    .byte $40, $01, $00, $10
    .byte $40, $02, $00, $18
    .byte $40, $03, $00, $20
    .byte $40, $04, $00, $28
    .byte $40, $05, $00, $30
    .byte $40, $06, $00, $38
    .byte $40, $07, $00, $40
    .byte $50, $08, $00, $08
    .byte $50, $09, $00, $10
    .byte $50, $0A, $00, $18
    .byte $50, $0B, $00, $20
    .byte $50, $0C, $00, $28
    .byte $50, $0D, $00, $30
    .byte $50, $0E, $00, $38
    .byte $50, $0F, $00, $40

pdata:
    .byte $FF,$1A,$23,$37,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F  ;background palette data
    .byte $FF,$1C,$15,$14,$0F,$02,$38,$3C,$0F,$1C,$15,$14,$0F,$02,$38,$3C  ;sprite palette data

.segment "OAM"

.segment "VECTORS"
    .word nmi
    .word reset
    .word main

.segment "TILES"
    .incbin "tiles.chr"