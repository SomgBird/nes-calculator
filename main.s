.include "const.inc"
.include "ines-header.s"

.segment "ZEROPAGE"
addrL:  .res 1
addrH:  .res 1
buttons: .res 1
pressed_buttons: .res 1
released_buttons: .res 1
last_frame_buttons: .res 1
cursorX: .res 1, $00
cursorY: .res 1, $00
palette: .res 1

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
    sta SPRITE_ADDR, X
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

    lda #CURSOR_PALETTE
    sta palette
    jsr change_sprite_params    ; update first selected button


forever:
    jmp forever

nmi:
    lda #$00
    sta PPU_OAMADDR ; set the low byte of RAM
    lda #$02        ; set the high byte of RAM, and transfer
    sta PPU_OAMDMA

@reread:
    ; read input
    lda buttons
    pha
    jsr readjoy
    pla
    cmp buttons
    bne @reread

    eor #%11111111
    and last_frame_buttons
    sta released_buttons
    lda last_frame_buttons
    eor #%11111111
    and buttons
    sta pressed_buttons

@read_up:
    ; is UP pressed?
    lda pressed_buttons
    and #BUTTON_UP
    beq @read_up_done

    ; is this move possible?
    ldx #Y_MIN_KEY
    cpx cursorY
    beq input_handled

    ; reload palette of the previous key
    lda #DEFAULT_PALETTE
    sta palette
    jsr change_sprite_params
    
    ; move cursor for the next key
    lda #CURSOR_PALETTE
    sta palette
    dec cursorY
    jsr change_sprite_params
@read_up_done:

@read_down:
    ; is DOWN pressed?
    lda pressed_buttons
    and #BUTTON_DOWN
    beq @read_down_done

    ; is this move possible?
    ldx #Y_MAX_KEY
    cpx cursorY
    beq input_handled

    ; reload palette of the previous key
    lda #DEFAULT_PALETTE
    sta palette
    jsr change_sprite_params

    ; move cursor for the next key
    lda #CURSOR_PALETTE
    sta palette
    inc cursorY
    jsr change_sprite_params
@read_down_done:

@read_left:
    ; is LEFT pressed?
    lda pressed_buttons
    and #BUTTON_LEFT
    beq @read_left_done

    ; is this move possible?
    ldx #X_MIN_KEY
    cpx cursorX
    beq input_handled

    ; reload palette of the previous key
    lda #DEFAULT_PALETTE
    sta palette
    jsr change_sprite_params

    ; move cursor for the next key
    lda #CURSOR_PALETTE
    sta palette
    dec cursorX
    jsr change_sprite_params
@read_left_done:

@read_right:
    ; is RIGHT pressed?
    lda pressed_buttons
    and #BUTTON_RIGHT
    beq @read_right_done

    ; is this move possible?
    ldx #X_MAX_KEY
    cpx cursorX
    beq input_handled

    ; reload palette of the previous key
    lda #DEFAULT_PALETTE
    sta palette
    jsr change_sprite_params

    ; move cursor for the next key
    lda #CURSOR_PALETTE
    sta palette
    inc cursorX
    jsr change_sprite_params
@read_right_done:

input_handled:
    lda buttons
    sta last_frame_buttons
    rti

change_sprite_params:
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
    adc #$03

    ; update sprite params
    tax
    lda palette
    sta KEYS_SPRITE_ADDR, X
    rts

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

sdata:
        ; Y    №    a    X
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