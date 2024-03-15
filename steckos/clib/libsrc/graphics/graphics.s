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

.importzp __volatile_ptr
.importzp __volatile_tmp

.zeropage
  _graphics_x:  .res 1
  _graphics_y:  .res 1
  _graphics_ix: .res 1

;----------------------------------------------------------------------------
.code

; void __fastcall__ vdp_syncvblank();
.export _vdp_syncvblank
.proc _vdp_syncvblank
:       lda sys_irr
        bpl :-
        and #%01111111
        sta sys_irr
        rts
.endproc

; void __fastcall__ graphics_initgraph( char graphmode );
.export _graphics_initgraph
.proc _graphics_initgraph
        jmp _vdp_screen
.endproc


; int __fastcall__  vdp_maxx();
.export _graphics_getmaxx
.proc _graphics_getmaxx
        ldx #0
        lda #$ff  ; TODO
        rts
.endproc

; int __fastcall__ graphics_getmaxy();
.export _graphics_getmaxy
.proc _graphics_getmaxy
        ldx #0
        lda #211  ; TODO
        rts
.endproc

; int __fastcall__ graphics_getcolor();
.export _graphics_getcolor
.proc _graphics_getcolor
        lda _graphics_color
        ldx #0
        rts
.endproc

; void __fastcall__ graphics_putpixel(int x, char y, char color);
.export _graphics_putpixel
.proc _graphics_putpixel
        jsr _graphics_setcolor
        jmp _vdp_plot
.endproc

; void __fastcall__ graphics_bar( int left, char top, int right, char bottom );
.export _graphics_bar
.proc _graphics_bar
        sta _graphics_y
        jsr popax
        sta _graphics_x
        jsr popa
        pha
        jsr popax
        sta _graphics_ix
        ply
@row:   ldx _graphics_ix
@col:   lda _graphics_color_fill
        jsr vdp_mode7_set_pixel
        inx
        cpx _graphics_x
        bne @col
        iny
        cpy _graphics_y
        bne @row
        rts
.endproc


; void __fastcall__ _graphics_textxy (unsigned int x, unsigned char y, char *s);
.export _graphics_textxy
.proc _graphics_textxy
        php
        sei
        sta __volatile_ptr
        stx __volatile_ptr+1
        jsr popa
        sta _graphics_y
        jsr popax
        sta _graphics_x

        lda slot3_ctrl
        pha
        lda #$80
        sta slot3_ctrl ; char rom
        ldy #0

@loop:  lda (__volatile_ptr),y    ; read char
        beq @done
        stz vdp_ptr+1
        asl
        rol vdp_ptr+1
        asl
        rol vdp_ptr+1
        asl
        sta vdp_ptr
        lda vdp_ptr+1
        rol
        ora #>slot3
        sta vdp_ptr+1

        phy

        ldy _graphics_y

@row:   ldx _graphics_x
        lda (vdp_ptr)           ; read char row from charset (rom)
        sta vdp_tmp

        lda #8
        sta _graphics_ix
@col:   rol vdp_tmp
        bcc @col_next
        lda _graphics_color
        ;jsr @plot ; TODO use plot, mode independent
        jsr vdp_mode7_set_pixel
@col_next:
        inx
        dec _graphics_ix
        bne @col

        iny ; next row, y
        inc vdp_ptr
        lda vdp_ptr
        and #$07
        bne @row

        stx _graphics_x

        ply
        iny
        bne @loop

@done:  pla
        sta slot3_ctrl

        plp
        rts
;@plot:  jmp (gfx_plot_table,x)
.endproc

; void __fastcall__ graphics_setfillstyle ( int pattern, unsigned char color);
.export _graphics_setfillstyle
.proc _graphics_setfillstyle
        jsr graphics_colors
        sta _graphics_color_fill
        jmp popax
.endproc

; void __fastcall__ graphics_setcolor (unsigned char color);
.export _graphics_setcolor
.proc _graphics_setcolor
        jsr graphics_colors
        sta _graphics_color
        jmp _vdp_setcolor
.endproc

graphics_colors:
        and #$0f
        tay
        lda @colors,y
        rts
@colors:
    ; { BLACK, BLUE, GREEN, CYAN, RED, MAGENTA, BROWN, LIGHTGRAY, DARKGRAY, LIGHTBLUE, LIGHTGREEN, LIGHTCYAN, LIGHTRED, LIGHTMAGENTA, YELLOW, WHITE }
        vdp_rgb 0,0,0
        vdp_rgb 0,0,255
        vdp_rgb 0,255,0
        vdp_rgb 0,255,255 ; CYAN
        vdp_rgb 255,0,0
        vdp_rgb 255,0,255 ; MAGENTA
        vdp_rgb 128,64,0
        vdp_rgb 200,200,200
        vdp_rgb 128,128,128 ; DARKGRAY
        vdp_rgb 128,128,255 ; LIGHTBLUE
        vdp_rgb 128,255,128 ; LIGHTGREEN
        vdp_rgb 128,255,255
        vdp_rgb 255,128,128 ; LIGHTRED
        vdp_rgb 255,128,255 ; LIGHTMAGENTA
        vdp_rgb 255,255,0
        vdp_rgb 255,255,255 ; WHITE

.bss
  _graphics_color:      .res 1
  _graphics_color_fill: .res 1