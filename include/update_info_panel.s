.proc UpdateNumbers
@select:
    lda operationFlag
    and #OP_SELECTION
    beq @no_select

@check_overflow:
    lda #$00
    cmp numberFlag
    bne @no_overflow
    lda #$04
    sta numberFlag

    ; TODO: rework to adc?
    jsr SaveTilePtr
    jsr IncPtr
    jsr IncPtr
    jsr IncPtr
    jsr LoadTilePtr

    lda currentNumberMemoryAddr
    clc
    adc #$03
    sta currentNumberMemoryAddr
    
@no_overflow:
    lda >currentNumberTileAddr-0
    sta PPU_PPUADDR
    lda <currentNumberTileAddr-0
    sta PPU_PPUADDR

    ldx selection
    lda keymap, X

    ; cmp #$0A
    ; beq @handle_zero

    ; TODO: check keymap for +-*/=

@handle_zero:

@handle_plus:

@handle_minus:

@handle_product:

@handle_divide:

@handle_equals:


@handle_number:
    ; update number in memory (non-zero)
    ldx currentNumberMemoryAddr
    sta $0000, X
    dex 
    stx currentNumberMemoryAddr
@update_graphics:
    ; update number graphics
    sta PPU_PPUDATA
    lda #$00
    sta operationFlag
    jsr SaveTilePtr
    jsr DecPtr
    jsr LoadTilePtr


    lsr numberFlag
@no_select:
    rts
.endproc


.proc LoadTilePtr
    lda <tmpPtr-0
    sta <currentNumberTileAddr
    lda >tmpPtr-0
    sta >currentNumberTileAddr
    rts
.endproc


.proc SaveTilePtr
    lda <currentNumberTileAddr-0
    sta <tmpPtr
    lda >currentNumberTileAddr-0
    sta >tmpPtr
    rts
.endproc


.proc IncPtr
    inc tmpPtr
    bne @skip
    inc tmpPtr+1
@skip:
    rts
.endproc


.proc DecPtr
    dec tmpPtr
    bne @skip
    dec tmpPtr+1
@skip:
    rts
.endproc