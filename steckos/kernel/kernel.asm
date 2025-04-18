; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
.ifdef DEBUG_KERNEL ; debug switch for this module
  debug_enabled=1
.endif


.include "kernel.inc"
.include "nvram.inc"


.code

.autoimport

; expose high level read_/write_block api
.export read_block=             blklayer_read_block
.export write_block=            blklayer_write_block
.export write_block_buffered=   blklayer_write_block_buffered
.export write_flush=            blklayer_flush
; configure low level or device read_/write_block api
.export dev_read_block=         sd_read_block
.export dev_write_block=        sd_write_block

.export char_out=ansi_chrout         ; account for page crossing

.export crc16_lo=BUFFER_0
.export crc16_hi=BUFFER_1
.export crc16_init=crc16_table_init
.export xmodem_rcvbuffer=BUFFER_2
.export xmodem_startaddress=startaddr

.export debug_chrout=textui_chrout         ; account for page crossing

.export do_upload

nvram = $1000

kern_init:
    lda #2  ; enable RAM below kernel
    sta slot2_ctrl
    
    lda #<nvram
    ldy #>nvram
    jsr read_nvram
    jsr uart_init

    sta __volatile_ptr
    sty __volatile_ptr+1
    ldy #nvram::textui_color
    lda (__volatile_ptr),y
    sta textui_color

    jsr blklayer_init

    SetVector user_isr_default, user_isr
    jsr textui_init

    jsr init_via1

    jsr init_rtc

    stz key
    stz flags


    stz ansi_state

;    jsr rtc_irq0

    cli

.ifndef DISABLE_INTRO
    jsr primm
    .byte $d5,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$b8,$0a
    .byte $b3," steckOS kernel "
    .include "version.inc"
    .byte $20,$b3,$0a
    .byte $d4,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$be,$0a
    .byte $00
.else
    jsr primm
    .byte CODE_LF, "steckOS kernel "
    .include "version.inc"
    .byte CODE_LF, 0
.endif

    SetVector do_upload, retvec ; retvec per default to do_upload. end up in do_upload again, if a program exits safely
    jsr __automount_init
    bcs do_upload

    lda #<filename
    ldx #>filename
    jsr execv

load_error:
    jsr hexout
    jsr primm
    .byte " read error", CODE_LF, 0
do_upload:
    jsr xmodem_upload
    bcs load_error

    jsr primm
    .byte " OK", CODE_LF, 0

    ldx #$ff
    txs

    jmp (startaddr); jump to start addr set by upload

;----------------------------------------------------------------------------------------------
; IO_IRQ Routine. Handle IRQ
;----------------------------------------------------------------------------------------------
do_irq:
;   PHX              ;
;   PHA              ;
;   TSX              ; get stack pointer
;   LDA  $0103,X        ; load INT-P Reg off stack
;   AND  #$10          ; mask BRK
;   BNE  @BrkCmd        ; BRK CMD
;   PLA              ;
;   PLX              ;
;   ;jmp  (INTvector)     ; let user routine have it
;   bra @irq
; @BrkCmd:
;   pla              ;
;   plx              ;
;   jmp  do_nmi

; system interrupt handler
; handle keyboard input and text screen refresh
    save

    cld ;clear decimal flag, maybe an app has modified it during execution
    jsr call_user_isr     ; user isr first, maybe there are timing critical things

    jsr system_irr        ; collect irq sources and store bits in system_irr accordingly

    bit sys_irr ; vdp irq ?
    bpl @check_via
    jsr textui_update_screen  ; update text ui
    lda #Dark_Yellow
;    jsr vdp_bgcolor

@check_via:
    bit sys_irr    ; Interrupt from VIA?
    bvc @check_opl
    lda #Light_Green
;    jsr vdp_bgcolor
    ; via irq handling code
    ;

@check_opl:
    lda sys_irr  ; IRQ from OPL?
    and #IRQ_SND
    beq @check_spi_rtc
    lda #Light_Yellow<<4|Light_Yellow
;    jsr vdp_bgcolor

@check_spi_rtc:
    ;jsr rtc_irq0_ack
    ;bcc @check_spi_keyboard
    ;lda #Cyan<<4|Cyan
    ;jsr vdp_bgcolor

@check_spi_keyboard:
    jsr fetchkey        ; fetch key
    bcc @system
    cmp #KEY_CTRL_C     ; was it ctrl c?
    bne @system  ; no

    lda flags           ; it is ctrl c. set bit 7 of flags
    ora #$80
    sta flags

@system:
    dec frame
    lda frame
    and #$0f            ; every 16 frames we try to update rtc, gives 320ms clock resolution
    bne @spi_busy
    jsr rtc_systime_update     ; update system time, read date time and store to rtc_systime_t (see rtc.inc)
    ;jsr __automount

@spi_busy:
    lda via1portb
    and #spi_device_deselect
    cmp #spi_device_deselect
    beq @exit
;    jsr textui_status
 ;   bpl @exit
;    lda #Medium_Red<<4|Medium_Red ; indicates busy spi
;    jsr vdp_bgcolor
@exit:
    lda #Medium_Green<<4|Black
    jsr vdp_bgcolor

    restore
    rti

call_user_isr:
    jmp (user_isr)
user_isr_default:
    rts

frame:
   .res 1

;----------------------------------------------------------------------------------------------
; IO_NMI Routine. Handle NMI
;----------------------------------------------------------------------------------------------



.code
do_nmi:
    sta save_stat + save_status::ACC
    stx save_stat + save_status::XREG
    sty save_stat + save_status::YREG

    tsx
    stx save_stat + save_status::SP

    pla
    sta save_stat + save_status::STATUS
    pla
    sta save_stat + save_status::PC
    pla
    sta save_stat + save_status::PC+1


    ldx #3
:
    lda slot0_ctrl,x
    sta save_stat + save_status::SLOT0,x
    dex
    bpl :-

    jsr primm
    .byte CODE_LF, "PC   S0 S1 S2 S3 AC XR YR SP NV-BDIZC", CODE_LF,0

    lda save_stat + save_status::PC+1
    jsr hexout
    lda save_stat + save_status::PC
    jsr hexout

    lda #' '
    jsr char_out

    ldx #save_status::SLOT0
:
    lda save_stat,x
    jsr hexout

    lda #' '
    jsr char_out
    inx
    cpx #save_status::STATUS
    bne :-


    lda save_stat + save_status::STATUS
    sta atmp

    ldx #0
@next:
    asl atmp
    bcs @set
    lda #'0'
    bra @skip
@set:
    lda #'1'
@skip:
    jsr char_out
    inx
    cpx #8
    bne @next

    crlf

    jsr wozmon

    lda save_stat + save_status::PC+1
    pha
    lda save_stat + save_status::PC
    pha

    lda save_stat + save_status::STATUS
    pha


    lda save_stat + save_status::ACC
    ldx save_stat + save_status::XREG
    ldy save_stat + save_status::YREG

    rti

do_reset:
  ; disable interrupt
  sei

  ; clear decimal flag
  cld

  ; init stack pointer
  ldx #$ff
  txs
  jmp kern_init




filename: .asciiz "/steckos/shell.prg"


.segment "VECTORS"
; $FFF8/$FFF9 RETVEC
.word 0
; ----------------------------------------------------------------------------------------------
; Interrupt vectors
; ----------------------------------------------------------------------------------------------
; $FFFA/$FFFB NMI Vector
.word do_nmi
; $FFFC/$FFFD reset vector
;*= $fffc
.word do_reset
; $FFFE/$FFFF IRQ vector
;*= $fffe
.word do_irq

.bss
startaddr:  .res 2
save_stat: .res   .sizeof(save_status)
atmp: .res 1