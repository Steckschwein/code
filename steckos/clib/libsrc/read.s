;
;
;
; int __fastcall__ read(int fd,void *buf,int count)

    .include "fcntl.inc"
    .include "errno.inc"
    .include "kernel/kernel_jumptable.inc"
    .include "asminc/zeropage.inc"
    .include "asminc/common.inc"

    .import __rwsetup,__do_oserror,__inviocb,__oserror, popax, popptr1

    .importzp tmp1,tmp2,tmp3,ptr1,ptr2,ptr3

    .export _read

;--------------------------------------------------------------------------
; _read
.code

.proc  _read
    sta ptr3
    eor #$FF      ; the count argument
    sta ptr2
    txa
    sta ptr3+1
    eor #$FF
    sta ptr2+1      ; Remember -count-1

    jsr popptr1    ; get pointer to buf

    jsr popax      ; the fd handle
    cpx #0        ; high byte must be 0
    bne invalidfd

    tax            ; fd to x

; read bytes loop
@r0:
    inc    ptr2       ; count bytes read ?
    bne    @r1
    inc    ptr2+1
    beq    @exit
@r1:
    jsr krn_fread_byte
    bcs @eof

    sta (ptr1)  ; save byte

    inc ptr1
    bne @r0
    inc ptr1+1
    bra @r0

; set _oserror and return the number of bytes read
@eof:
    sta __oserror
;    jmp __directerrno  ; Sets _errno, clears _oserror, returns -1
@exit:
    clc          ; calc count bytes read
    lda ptr2
    adc ptr3
    pha
    lda ptr2+1
    adc ptr3+1
    tax
    pla
    rts

; Error entry: Device not present

devnotpresent:
      lda    #ENODEV
      jmp    __directerrno  ; Sets _errno, clears _oserror, returns -1

; Error entry: The given file descriptor is not valid or not open

invalidfd:
      lda    #EBADF
      jmp    __directerrno  ; Sets _errno, clears _oserror, returns -1

.endproc
