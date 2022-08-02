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