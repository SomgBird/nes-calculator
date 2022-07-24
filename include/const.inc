; PPU
PPU_CTRL    = $2000 ; VPHB SINN: 
                    ;   V - MNI enable
                    ;   P - PPU master/slave select
                    ;   H - sprite height
                    ;   B - background tile select
                    ;   S - sprite tile select
                    ;   I - increment mode
                    ;   NN - nametable select

PPU_MASK    = $2001 ; BGRs bMmG:
                    ;   BGR - color emphasis 
                    ;   s - sprite enable
                    ;   b - background enable
                    ;   M - sprite left column enable
                    ;   m - background left column enable
                    ;   G - grayscale

PPU_STATUS  = $2002 ; VSO- ----:
                    ; V - v-blank
                    ; S - sprite 0 overlap a nonzero background pixel
                    ; O - sprite overflow
                    ; - ---- PPU open bus

PPU_OAMADDR = $2003 ; OAM read/write address
PPU_OAMDATA = $2004 ; OAM data read/write
PPU_SCROLL  = $2005 ; file scroll position (X, Y)
PPU_PPUADDR = $2006 ; PPU read/write address
PPU_PPUDATA = $2007 ; PPU data read/write
PPU_OAMDMA  = $4014 ; OAM DMA address

SPRITE_ADDR =  $0200 

; Input
JOYPAD1 = $4016

; Buttons' flags
BUTTON_A      = 1 << 7
BUTTON_B      = 1 << 6
BUTTON_SELECT = 1 << 5
BUTTON_START  = 1 << 4
BUTTON_UP     = 1 << 3
BUTTON_DOWN   = 1 << 2
BUTTON_LEFT   = 1 << 1
BUTTON_RIGHT  = 1 << 0

; Misc
DEFAULT_PALETTE = %00000000
CURSOR_PALETTE = %00000010  ; Selected key sprite palette will be chancged to this one

KEYS_SPRITE_ADDR = $0237    ; Add where interactive keys sprites begin

X_KEYS_SIZE = $05           ; Number of key columns
Y_KEYS_SIZE = $03           ; Number of key rows
X_MIN_KEY = $00             ; Min column number
X_MAX_KEY = $04             ; Max column number
Y_MIN_KEY = $00             ; Min row number
Y_MAX_KEY = $02             ; Max row number
