reset:
    sei         ; disable interrupts
    cld         ; turn off decimal mode

    ldx #$40
    stx $4017   ; disable APU

    ldx #$ff
    txs         ; set up stack
    inx         ; x = 0

    stx PPU_CTRL   ; disable NMI (non-maskable interrupt)
    stx PPU_MASK   ; disable rendering
    stx $4010      ; disable DMC IRQs

    bit PPU_STATUS   ; make sure for @vblankwait1 does not exit immediatly

@vblankwait1:
    bit PPU_STATUS   ; check v-blank flag value
    bpl @vblankwait1

    ; ~30 000 cycles are awailable before PPU stabilizes
    ; this section puts RAM into known state (fills it with zeros)
    txa
@clearmem:
    sta $0000,x
    sta $0100,x
    sta $0200,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne @clearmem

@vblankwait2:
    bit PPU_STATUS   ; check v-blank flag value
    bpl @vblankwait2

    ; Load palettes to PPU
    lda PPU_STATUS  ; read PPU status to reset the high/low latch
    lda #$3F        ; PPU will accept palettes from $3F00
    sta PPU_PPUADDR ; write the most significant byte
    lda #$10
    sta PPU_PPUADDR ; write the least significant byte

    rti