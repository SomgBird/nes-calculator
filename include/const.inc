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
