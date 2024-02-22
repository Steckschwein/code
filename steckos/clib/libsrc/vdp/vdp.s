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

.include "kernel/kernel_jumptable.inc"
.include "asminc/vdp.inc"
.include "asminc/gfx.inc"
.include "asminc/zeropage.inc"

.include "asminc/debug.inc"

.autoimport

;----------------------------------------------------------------------------
.code

; void __fastcall__ vdp_screen (unsigned char mode);
.export _vdp_screen
.proc _vdp_screen
    php
    sei
    asl
    sta _vdp_mode
    jsr krn_textui_disable			;disable textui
    ldx _vdp_mode
    jsr _gfx_set_mode
    plp
    rts
.endproc

_gfx_set_mode:
		jmp (_gfx_mode_table,x)

_gfx_mode_table:
    .word krn_textui_init  ; 0
    .word vdp_mode2_on  ; 1
    .word vdp_mode3_on ; 2
    .word vdp_mc_on ; 3
    .word gfx_notimplemented; 4
    .word gfx_notimplemented; 5
    .word vdp_mode6_on ; 6
    .word vdp_mode7_on ; 7
gfx_notimplemented:
    rts

; void __fastcall__ vdp_putpixel (unsigned int x, unsigned char y);
.export _vdp_putpixel
.proc _vdp_putpixel
    jsr pusha                     ; push y
    lda _vdp_line_t+line_t::color ; load color
.endproc

; void __fastcall__ vdp_plot (unsigned int x, unsigned char y, unsigned char color);
.export _vdp_plot
.proc _vdp_plot
    pha ;_vdp_px_color       ; save color
    jsr popa
    pha; _vdp_px_y
    jsr popax
    pha;sta _vdp_px_x
    ; TODO 16bit x
    ldx _vdp_mode
    jmp (gfx_plot_table,x)
.endproc

gfx_plot_table:
    .word gfx_notimplemented  ; 0
    .word GFX_2_Plot ; 2
    .word GFX_2_Plot ; 2
    .word GFX_MC_Plot; 3
    .word gfx_notimplemented; 4
    .word gfx_notimplemented; 5
    .word GFX_6_Plot ; 6
    .word GFX_7_Plot ; 7

GFX_2_Plot:
    plx
    ply
    pla
    jmp vdp_mode2_set_pixel

GFX_MC_Plot:
    plx
    ply
    pla
    jmp vdp_mc_set_pixel

GFX_6_Plot:
    plx
    ply
    pla
    jmp vdp_mode6_set_pixel

GFX_7_Plot:
    plx
    ply
    pla
    jmp vdp_mode7_set_pixel


; int __fastcall__ vdp_getcolor();
.export _vdp_getcolor
.proc _vdp_getcolor
        lda _vdp_line_t+line_t::color
        ldx #0
        rts
.endproc

; void __fastcall__ vdp_textxy (unsigned int x, unsigned char y, char *s);
.export _vdp_textxy
.proc _vdp_textxy
        sta __volatile_ptr
        stx __volatile_ptr+1
        lda slot2
        pha
        lda #$80
        sta slot2 ; char rom
        ldy #0
        lda (__volatile_ptr),y
        beq :+
:       pla
        sta slot2
        rts
.endproc

; void __fastcall__ vdp_line(int x1, char y1, int x2, char y2);
.export _vdp_line
.proc _vdp_line
        sta _vdp_line_t+line_t::y2
        jsr popax
        sta _vdp_line_t+line_t::x2
        stx _vdp_line_t+line_t::x2+1
        jsr popa
        sta _vdp_line_t+line_t::y1
        jsr popax
        sta _vdp_line_t+line_t::x1
        stx _vdp_line_t+line_t::x1+1
        lda #<_vdp_line_t
        ldy #>_vdp_line_t
        jmp gfx_line
.endproc

; void __fastcall__ vdp_setcolor (unsigned char color);
.export _vdp_setcolor
.proc _vdp_setcolor
    sta _vdp_line_t+line_t::color
    rts
.endproc

; void __fastcall__ vdp_blank (unsigned char color);
.export _vdp_blank
.proc _vdp_blank
    tay
    ldx _vdp_mode
    jmp (gfx_blank_table,x)
.endproc

gfx_blank_table:
    .word gfx_notimplemented  ; 0
    .word vdp_mode2_blank ; 2
    .word vdp_mode3_blank ; 2
    .word vdp_mc_blank; 3
    .word gfx_notimplemented; 4
    .word gfx_notimplemented; 5
    .word vdp_mode6_blank; 6
    .word vdp_mode7_blank ; 7

; void __fastcall__ vdp_memcpy (unsigned char *data, unsigned int vramaddress, unsigned char pages);
;
.export _vdp_memcpy
.proc _vdp_memcpy
    php
    sei

    pha ;save page count

    jsr popa
    sta a_vreg
    jsr popa
    and #$3f
    ora #WRITE_ADDRESS
    sta a_vreg

    jsr popax
    phx
    ply

    plx ;restore page count
    jsr vdp_memcpy

    plp
    rts
.endproc

; void __fastcall__ vdp_init (unsigned char mode);
.export _vdp_init
.proc _vdp_init
    jmp vdp_init_reg
.endproc

.export _vdp_restore
.proc _vdp_restore
    jmp krn_textui_enable
.endproc

.bss
  _vdp_mode:      .res 1
  _vdp_px_x:      .res 1
  _vdp_px_y:      .res 1
  _vdp_line_t:    .tag line_t