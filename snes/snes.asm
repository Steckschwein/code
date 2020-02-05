.include "steckos.inc"
.include "via.inc"
.include "joystick.inc"
.export char_out=krn_chrout
.import query_controllers
.import hexout

appstart $1000

.exportzp controller1=$00, controller2=$03


main:
    joy_off ; disable joystick ports

loop:
    jsr query_controllers
    ;jsr hexout
    ;lda controller1+1
    ;jsr hexout
    ;lda controller1+2
    ;jsr hexout
    rol controller1
    bcs foo1
    lda #'B'
    jsr char_out
foo1:
    rol controller1
    bcs foo2
    lda #'Y'
    jsr char_out
foo2:
    rol controller1
    bcs foo3
    lda #'S'
    jsr char_out
foo3:
    rol controller1
    bcs foo4
    lda #'T'
    jsr char_out
foo4:
    rol controller1
    bcs foo5
    lda #'U'
    jsr char_out
foo5:
    rol controller1
    bcs foo6
    lda #'D'
    jsr char_out
foo6:
    rol controller1
    bcs foo7
    lda #'L'
    jsr char_out
foo7:
    rol controller1
    bcs foo8
    lda #'R'
    jsr char_out
foo8:
    rol controller1+1
    bcs foo9
    lda #'A'
    jsr char_out
foo9:
    rol controller1+1
    bcs foo10
    lda #'X'
    jsr char_out
foo10:
    rol controller1+1
    bcs foo11
    lda #'l'
    jsr char_out
foo11:
    rol controller1+1
    bcs foo12
    lda #'r'
    jsr char_out
foo12:

;    crlf
    jmp loop



;.zeropage
; controller1:
;         .res 3
; controller2:
;         .res 3
