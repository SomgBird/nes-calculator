.segment "HEADER"
.byte "NES"     ; name of the game
.byte $1A       ; it is the game file to load
.byte $02       ; 2 * 16 KB PRG ROM
.byte $01       ; 1 * 8 KB CHR ROM
.byte %00000001 ; mapper and mirroring
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00, $00, $00, $00, $00 ; filler bytes