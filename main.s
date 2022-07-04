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

@loop:
    jmp @loop

pdata:
    .byte $0F,$31,$32,$33,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F  ;background palette data
    .byte $33,$1C,$15,$14,$0F,$02,$38,$3C,$0F,$1C,$15,$14,$0F,$02,$38,$3C  ;sprite palette data

.segment "OAM"

.segment "VECTORS"
    .word nmi
    .word reset
    .word main

.segment "TILES"