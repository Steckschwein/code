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

;@module: vdp

.include "vdp.inc"

.export vdp_mode6_set_pixel

.importzp vdp_tmp

;@name: vdp_mode6_set_pixel
;@desc: set pixel to gfx6 mode screen - VRAM ADDRESS = 8(INT(X DIV 2)) + 256(INT(Y DIV 8)) + (Y MOD 8)
;@in: X - x coordinate [0..ff]
;@in: Y - y coordinate [0..bf]
;@in: A - color [0..f] and bit 7 MSB x coordinate
vdp_mode6_set_pixel:
    php
    sei

    txa            ;2
    and  #$f8
    sta  vdp_tmp
    tya
    and  #$07
    ora  vdp_tmp
    sta  a_vreg   ;4 set vdp vram address low byte
    sta  vdp_tmp  ;3 safe vram low byte

    ; high byte vram address - div 8, result is vram address "page" $0000, $0100, ...
    tya            ;2
    lsr            ;2
    lsr            ;2
    lsr            ;2
    sta  a_vreg        ;set vdp vram address high byte
    ora #WRITE_ADDRESS    ;2 adjust for write
    tay            ;2 safe vram high byte for write in y

    txa            ;2 set the appropriate bit
    and  #$07        ;2
    tax            ;2
    lda  bitmask,x      ;4
    ora  a_vram        ;4 read current byte in vram and OR with new pixel
    tax            ;2 or value to x
    nop            ;2
    nop            ;2
    nop            ;2
    lda  vdp_tmp      ;2
    sta a_vreg
    tya            ;2
    nop            ;2
    nop            ;2
    sta  a_vreg
    vdp_wait_l
    stx a_vram  ;set vdp vram address high byte

    plp
    rts
bitmask:
  .byte $80,$40,$20,$10,$08,$04,$02,$01
