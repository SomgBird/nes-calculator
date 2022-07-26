.proc UpdateInfoPanel
@select:
    lda operationFlag
    and #%00100000
    beq @no_select

    lda >currentNumberTileAddr-0
    sta PPU_PPUADDR
    lda <currentNumberTileAddr-0
    sta PPU_PPUADDR

@check_overflow:
    lsr numberFlag
    lda #$00
    cmp numberFlag
    bne @no_overflow
    lda #$04
    sta numberFlag
    lda <currentNumberTileAddr-0
    adc #$02
    sta <currentNumberTileAddr
    
@no_overflow:
    ldx selection
    lda keymap, X
    sta PPU_PPUDATA
    lda #$00
    sta operationFlag
    dec <currentNumberTileAddr  ; TODO: rework for two bytes

    ; TODO: check keymap for +-*/=
    
@no_select:
    lda #%10000000 ; enable NMI, sprites from Pattern 0, background from Pattern 1
    sta PPU_CTRL
    lda #%00011110 ; enable sprites, enable background
    sta PPU_MASK

    lda #$00
    sta PPU_SCROLL
    sta PPU_SCROLL

    rts
.endproc