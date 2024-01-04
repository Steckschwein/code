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
.setcpu "65c02"

.include "zeropage.inc"

.export _debugout
.export _debugout8
.export _debugout16
.export _debugout32
.export _debugdump
.export _debugdumpptr

.export _debugdirentry

.import debug_chrout, primm

.code

dbg_acc     = $02f9 ; basic uses $0290 - $02f8
dbg_xreg    = $02fa
dbg_yreg    = $02fb
dbg_status  = $02fc
dbg_bytes   = $02fd
dbg_savept  = $02fe
dbg_return  = $028e

__dbg_ptr=$0

_debugout_enter:
    sta dbg_acc
    stx dbg_xreg
    sty dbg_yreg
    php
    pla
    sta dbg_status
    cld

    lda __dbg_ptr
    sta dbg_savept
    lda __dbg_ptr+1
    sta dbg_savept+1

    stz dbg_bytes
;    jsr primm
;    .asciiz "AXYP "
    lda dbg_acc
    jsr _hexout
    lda dbg_xreg
    jsr _hexout
    lda dbg_yreg
    jsr _hexout
    lda dbg_status
    jsr _hexout
    tsx
    txa
    jsr _hexout
    lda  #' '
    jmp debug_chrout

_debugdirentry:
    jsr _debugout_enter
    ldy #0
@l0:
    lda (dirptr),y
    jsr _hexout
    lda #' '
    jsr debug_chrout
    iny
    cpy #32
    bne @l0
    bra _debugoutnone

_debugdumpptr:
    jsr _debugout_enter
    lda #$4b
    bra _debugout0
_debugdump:
    jsr _debugout_enter
    lda #11
    bra _debugout0
_debugout32:
    jsr _debugout_enter
    lda #3
    bra _debugout0
_debugout16:
    jsr _debugout_enter
    lda #1
    bra _debugout0
_debugout8:
    jsr _debugout_enter
    lda #0
    bra _debugout0
_debugout:
    jsr _debugout_enter
_debugoutnone:
    lda #$80
_debugout0:
    sta dbg_bytes
    pla           ; Get the low part of "return" address
                  ; (data start address)
    sta dbg_return
    sta __dbg_ptr
    pla
    sta dbg_return+1       ; Get the high part of "return" address
    sta __dbg_ptr+1      ; (data start address)

    bit dbg_bytes      ; bytes to output
    bmi @PSINB

    ldy #2          ; 2 byte address argument
    jsr _set_dbg_ptr

    lda __dbg_ptr
    jsr _hexout
    lda __dbg_ptr+1
    jsr _hexout
    lda #' '
    jsr debug_chrout

    bit dbg_bytes
    bvc :+            ; pointer to debug?
    ldy #1            ; yes, resolve address from pointer
    jsr _set_dbg_ptr

:   lda dbg_bytes      ; bytes to output
    and #$3f
    tay
@l1:
    lda (__dbg_ptr),y
    jsr _hexout
    lda #' '
    jsr debug_chrout
    dey
    bpl @l1
    lda #' '
    jsr debug_chrout

    clc
    lda    dbg_return    ; restore address for message argument
    adc    #2        ; +2 - 16bit debug address argument
                ; Note: actually we're pointing one short
    sta   __dbg_ptr    ;
    lda   dbg_return+1
    adc   #0
    sta    __dbg_ptr+1

@PSINB:              ; Note: actually we're pointing one short
    inc    __dbg_ptr     ; update the pointer
    bne    @PSICHO      ; if not, we're pointing to next character
    inc    __dbg_ptr+1    ; account for page crossing

@PSICHO:
    lda    (__dbg_ptr)     ; Get the next string character
    beq    @PSIX1       ; don't print the final NULL
    jsr    debug_chrout    ; write it out
    bra    @PSINB       ; back around
@PSIX1:  inc    __dbg_ptr      ;
    bne    @PSIX2      ;
    inc    __dbg_ptr+1    ; account for page crossing
@PSIX2:  lda    #$0a      ; line feed
    jsr   debug_chrout

    lda    __dbg_ptr    ; __dbg_ptr points to instruction after msg, adjust ret vector
    sta   dbg_return
    lda    __dbg_ptr+1
    sta   dbg_return+1

    lda   dbg_savept    ; restore
    sta   __dbg_ptr
    lda   dbg_savept+1
    sta   __dbg_ptr+1

    lda   dbg_status
    pha
    lda    dbg_acc
    ldx    dbg_xreg
    ldy    dbg_yreg
    plp

    jmp    (dbg_return)        ; return to byte following final NULL

_set_dbg_ptr:
    lda (__dbg_ptr),y
    tax
    dey
    lda (__dbg_ptr),y
    sta __dbg_ptr      ; address is setup in __dbg_ptr
    stx __dbg_ptr+1
    rts

;----------------------------------------------------------------------------------------------
; Output byte as hex string on active output device
;----------------------------------------------------------------------------------------------
_hexout:
    pha
    phx

    tax
    lsr
    lsr
    lsr
    lsr
    jsr @hexdigit
    txa
    jsr @hexdigit
    plx
    pla
    rts

@hexdigit:
    and    #%00001111    ;mask lsd for hex print
    ora    #'0'        ;add "0"
    cmp    #'9'+1       ;is it a decimal digit?
    bcc    @l          ;yes! output it
    adc    #6          ;add offset for letter a-f
@l:
    jmp   debug_chrout
