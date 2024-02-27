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

.export vdp_mc_set_pixel

.importzp vdp_tmp

.code

;@name: vdp_mc_set_pixel
;@desc: set pixel to mc screen - VRAM ADDRESS = 8(INT(X DIV 2)) + 256(INT(Y DIV 8)) + (Y MOD 8)
;  !!! NOTE !!! mc screen vram adress is assumed to be at $0000 (ADDRESS_GFX_MC_PATTERN)
;@in: X - x coordinate [0..3f]
;@in: Y - y coordinate [0..2f]
;@in: A - color [0..f]
vdp_mc_set_pixel:
    phx
    phy

    and #$0f        ;only the 16 colors
    sta vdp_tmp+1    ;safe color

    txa
    and #$3e        ; x div 2 * 8 => x div 2 * 2 * 2 * 2 => lsr, asl, asl, asl => lsr,asl = and #3e ($3f - x boundary), asl, asl
    asl
    asl
    sta vdp_tmp

    tya
    and  #$07        ; y mod 8
    ora  vdp_tmp        ; with x
    sta  a_vreg        ;4 set vdp vram address low byte
    sta  vdp_tmp        ;3 safe vram address low byte for write

    ; high byte vram address - div 8, result is vram address "page" $0000, $0100, ... until $05ff
    tya            ;2
    lsr            ;2
    lsr            ;2
    lsr            ;2
    ora #(>.LOWORD(ADDRESS_GFX_MC_PATTERN) & $3f)
    vdp_wait_s 5
    sta  a_vreg        ;set vdp vram address high byte
    ora #WRITE_ADDRESS | (>.LOWORD(ADDRESS_GFX_MC_PATTERN) & $3f) ;2 adjust for write

    tay            ;2 safe vram high byte for write in y

    txa            ;2
    bit #1          ;3 test color shift required, upper nibble?
    beq l1          ;2/3

    lda #$f0        ;2
    bra l2          ;3
l1:    lda vdp_tmp+1        ;3
    asl            ;2
    asl            ;2
    asl            ;2
    asl            ;2
    sta vdp_tmp+1
    lda #$0f
l2:
    vdp_wait_l 14
    and a_vram
    ora vdp_tmp+1

    ldx vdp_tmp        ;3
    vdp_wait_l 5
    stx  a_vreg        ;4 setup write address
    vdp_wait_s
    sty a_vreg
    vdp_wait_l
    sta a_vram

    ply
    plx

    rts
