.proc ApplyOperation
@reset:
    lda #$00
    sta outHundreds
    sta outTens
    sta outOnes

@plus:
    lda operationFlag
    and #OP_PLUS
    beq @plus_done
    jsr ApplyPlus
@plus_done:

    lda #$00
    sta operandFlag
    ldx #$00
    lda #>OUT_NUMBER_TILE_ADDR
    sta PPU_PPUADDR
    lda #<OUT_NUMBER_TILE_ADDR
    sta PPU_PPUADDR
@update_out_tiles:
    cpx #$03
    beq @update_done

    lda outHundreds, X
    cmp #$00
    beq @load_zero
@load_number:
    sta PPU_PPUDATA
    jmp @load_done
@load_zero:
    lda #$0A
    sta PPU_PPUDATA
@load_done:
    inx
    jmp @update_out_tiles
@update_done:

    rts
.endproc


.proc ApplyPlus
    lda #$00 
    ldx #$02
@loop:
    clc
    lda outHundreds, X
    adc firstOpHundreds, X
    adc secondOpHundreds, X
    cmp #$0A
    bmi @no_carry

@carry:
    sbc #$0A
    sta outHundreds, X
    cpx #$00
    beq @end
    dex
    lda outHundreds, X
    clc
    adc #$01
    sta outHundreds, X
    jmp @loop

@no_carry:
    sta outHundreds, X

@decrement: 
    cpx #$00
    beq @end 
    dex
    jmp @loop

@end:
    rts
.endproc