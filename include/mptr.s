.proc ParseKeymap
    ldx selection
    lda keymap, X
    rts
.endproc


.proc UpdateOperationTile
    lda #>OPERATION_TILE_ADDR
    sta PPU_PPUADDR
    lda #<OPERATION_TILE_ADDR
    sta PPU_PPUADDR
    lda selection
    jsr ParseKeymap
    sta PPU_PPUDATA
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


.proc SwitchOperand
@switch1:
    lda #$00
    cmp operandFlag
    jne @switch0
    lda #$01
    sta operandFlag
    lda #<SECOND_ONES_TILE_ADDR
    sta <currentNumberTileAddr
    lda #>SECOND_ONES_TILE_ADDR
    sta >currentNumberTileAddr
    lda #secondOpOnes
    sta currentNumberMemoryAddr
    jmp @end

@switch0:
    sta operandFlag
    lda #<FIRST_ONES_TILE_ADDR
    sta <currentNumberTileAddr
    lda #>FIRST_ONES_TILE_ADDR
    sta >currentNumberTileAddr
    lda #firstOpOnes
    sta currentNumberMemoryAddr

@end:
    lda #$04
    sta numberFlag
    rts
.endproc
