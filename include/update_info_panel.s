.include "mptr.s"

.proc UpdateNumbers
    lda #$01
    bit selectionFlag
    bne @select
    jmp @no_select
@select:

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

    jsr ParseKeymap

    cmp #$0A    ; zero check
    bmi @handle_number

    cmp #$0B    ; equals check
    beq @handle_equals

    cmp #$0C    ; plus check
    beq @handle_plus

    cmp #$0D    ; minus check
    beq @handle_minus

    cmp #$0E    ; product check
    beq @handle_product

    cmp #$0F    ; division check
    beq @handle_divide

@handle_zero:
    ldy #$00
    ldx currentNumberMemoryAddr
    sty $0000, X
    dex 
    stx currentNumberMemoryAddr
    jmp @update_number_graphics

@handle_number:
    ; update number in memory (non-zero)
    ldx currentNumberMemoryAddr
    sta $0000, X
    dex 
    stx currentNumberMemoryAddr

@update_number_graphics:
    ; update number graphics
    sta PPU_PPUDATA
    jsr SaveTilePtr
    jsr DecPtr
    jsr LoadTilePtr
    jmp @next_number

@handle_equals:
    ; TODO: apply operation
    jsr ApplyOperation
    ; reset pointers and flags
    lda #<FIRST_ONES_TILE_ADDR
    sta <currentNumberTileAddr
    lda #>FIRST_ONES_TILE_ADDR
    sta >currentNumberTileAddr
    lda #firstOpOnes
    sta currentNumberMemoryAddr
    lda #$04
    sta numberFlag
    lda #$00
    sta selectionFlag
    jmp @selection_done

@handle_plus:
    ; update operation sign
    lda #OP_PLUS
    jmp @operation_update

@handle_minus:
    ; update operation sign
    lda #OP_MINUS
    jmp @operation_update

@handle_product:
    ; update operation sign
    lda #OP_PRODUCT
    jmp @operation_update

@handle_divide:
    ; update operation sign
    lda #OP_DIVIDE
    jmp @operation_update


@operation_update:
    sta operationFlag
    jsr UpdateOperationTile
    jsr SwitchOperand
    jmp @selection_done
@next_number:
    lsr numberFlag
@selection_done:
    lda #$00
    sta selectionFlag
@no_select:
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