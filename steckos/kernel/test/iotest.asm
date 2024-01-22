.include "steckos.inc"
.include "errno.inc"
.include "fcntl.inc"  ; @see ca65 fcntl.inc
.include "fat32.inc"

.autoimport

.export char_out=krn_chrout

appstart $1000

.code

main:
      lda (paramptr)  ; empty string?
      bne :+
      lda #EINVAL
      jmp errmsg

:     jsr primm
      .asciiz "op r+"
      lda paramptr
      ldx paramptr+1
      ldy #O_CREAT    ; "touch like", only create new file
      jsr krn_open
      jsr test_result
      bcc :+
      jmp exit
:     jsr krn_close

      jsr primm
      .asciiz "op ro"  ; open newly created file, read only
      lda paramptr
      ldx paramptr+1
      ldy #O_RDONLY
      jsr krn_open
      jsr test_result
      bcc :+
      jmp exit
:     jsr krn_close

      jsr primm
      .asciiz "op rw+"  ; open again for write
      lda paramptr
      ldx paramptr+1
      ldy #O_WRONLY
      jsr krn_open
      jsr test_result
      bcc :+
      jmp exit
:     ldy #0
@l0:  lda testdata,y
      beq :+
      jsr krn_write_byte
;      jsr test_result
      bcs :+
      iny
      bne @l0
:     jsr krn_close
      jsr test_result

      jsr primm
      .asciiz "op ro"  ; open newly created file, read only
      lda paramptr
      ldx paramptr+1
      ldy #O_RDONLY
      jsr krn_open
      bcc @ro_read
      jmp exit
@ro_read:
      jsr krn_fread_byte
close_exit:
      jsr krn_close
exit:
      jmp (retvec)

test_result:
      php
      php
      pha
      jsr primm
      .asciiz " r="
      pla
      jsr hexout

      pla
      lsr
      bcs @fail
      jsr primm
      .byte " .",CODE_LF,0
      bra @test_result_exit
@fail:
      jsr primm
      .byte " E",CODE_LF,0
@test_result_exit:
      pla
      lsr
      rts

test_not_exist:
    jsr primm
    .asciiz "op r "
    lda #<file_notexist
    ldx #>file_notexist
    ldy #O_RDONLY
    jsr krn_open
    beq @fail  ; anti test, expect open failed
    lda #0
    rts

@fail:  lda #$ff
    rts

errmsg:
    ;TODO FIXME maybe use oserror() from cc65 lib
    pha
    jsr primm
    .asciiz "Error: "
    pla
    jsr hexout
    jmp exit
file_notexist:
    .asciiz "notexist.dat"
fd1:  .res 1
fd2:  .res 1
testdata:
    .byte "Hallo World!",0
testdata_e:

.data
buffer:
