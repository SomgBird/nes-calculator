.proc HandleInput
@read_select:
    ; is SELECT pressed?
    lda pressedButtons
    and #BUTTON_SELECT
    beq @read_select_done
    
    lda #$00    ; shift
    ldy #$00    ; counter
@loop:
    cpy cursorY
    beq @end_loop
    adc #X_KEYS_SIZE
    iny
    jmp @loop
@end_loop:
    clc
    adc cursorX

    sta selection
    lda #OP_SELECTION
    sta operationFlag
@read_select_done:

@read_up:
    ; is UP pressed?
    lda pressedButtons
    and #BUTTON_UP
    beq @read_up_done

    ; is this move possible?
    ldx #Y_MIN_KEY
    cpx cursorY
    beq input_handled

    ; reload palette of the previous key
    lda #DEFAULT_PALETTE
    sta palette
    jsr ChangeSpriteParams
    
    ; move cursor for the next key
    lda #CURSOR_PALETTE
    sta palette
    dec cursorY
    jsr ChangeSpriteParams
@read_up_done:

@read_down:
    ; is DOWN pressed?
    lda pressedButtons
    and #BUTTON_DOWN
    beq @read_down_done

    ; is this move possible?
    ldx #Y_MAX_KEY
    cpx cursorY
    beq input_handled

    ; reload palette of the previous key
    lda #DEFAULT_PALETTE
    sta palette
    jsr ChangeSpriteParams

    ; move cursor for the next key
    lda #CURSOR_PALETTE
    sta palette
    inc cursorY
    jsr ChangeSpriteParams
@read_down_done:

@read_left:
    ; is LEFT pressed?
    lda pressedButtons
    and #BUTTON_LEFT
    beq @read_left_done

    ; is this move possible?
    ldx #X_MIN_KEY
    cpx cursorX
    beq input_handled

    ; reload palette of the previous key
    lda #DEFAULT_PALETTE
    sta palette
    jsr ChangeSpriteParams

    ; move cursor for the next key
    lda #CURSOR_PALETTE
    sta palette
    dec cursorX
    jsr ChangeSpriteParams
@read_left_done:

@read_right:
    ; is RIGHT pressed?
    lda pressedButtons
    and #BUTTON_RIGHT
    beq @read_right_done

    ; is this move possible?
    ldx #X_MAX_KEY
    cpx cursorX
    beq input_handled

    ; reload palette of the previous key
    lda #DEFAULT_PALETTE
    sta palette
    jsr ChangeSpriteParams

    ; move cursor for the next key
    lda #CURSOR_PALETTE
    sta palette
    inc cursorX
    jsr ChangeSpriteParams
@read_right_done:

input_handled:
    rts
.endproc


.proc UpdateInput
    lda buttons
    sta lastFrameButtons
@reread:
    ; read input
    lda buttons
    pha
    jsr ReadJoy
    pla
    cmp buttons
    bne @reread

    eor #%11111111
    and lastFrameButtons
    sta releasedButtons
    lda lastFrameButtons
    eor #%11111111
    and buttons
    sta pressedButtons

    rts
.endproc


.proc ReadJoy
; At the same time that we strobe bit 0, we initialize the ring counter
; so we're hitting two birds with one stone here
readjoy:
    lda #$01
    ; While the strobe bit is set, buttons will be continuously reloaded.
    ; This means that reading from JOYPAD1 will only return the state of the
    ; first button: button A.
    sta JOYPAD1
    sta buttons
    lsr a        ; now A is 0
    ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
    ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
    sta JOYPAD1
@loop:
    lda JOYPAD1
    lsr a	       ; bit 0 -> Carry
    rol buttons  ; Carry -> bit 0; bit 7 -> Carry
    bcc @loop
    rts
.endproc


.proc ChangeSpriteParams
    ; Changes sprite's palette.

    ; compute sprite shift
    lda #$00    ; shift
    ldy #$00    ; counter
@loop:
    cpy cursorY
    beq @end_loop
    adc #X_KEYS_SIZE
    iny
    jmp @loop
@end_loop:
    clc
    adc cursorX

    ; compute sprite address
    clc
    asl
    asl
    adc #$02

    ; update sprite params
    tax
    lda palette
    sta KEYS_SPRITE_ADDR, X
    rts
.endproc

