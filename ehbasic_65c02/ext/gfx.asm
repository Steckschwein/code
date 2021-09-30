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

.include "vdp.inc"
.include "gfx.inc"
.include "kernel_jumptable.inc"

.import	vdp_display_off
.import	vdp_mc_on
.import	vdp_mc_blank
.import	vdp_mc_init_screen
.import	vdp_mc_set_pixel

.import vdp_gfx2_blank
.import vdp_gfx2_on
.import vdp_mode2_on
.import vdp_mode2_set_pixel

.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_gfx7_set_pixel
.import vdp_gfx7_set_pixel_cmd
.import vdp_bgcolor

.import gfx_line
.import gfx_circle
.import gfx_plot

.import LAB_SCGB
.import LAB_GTBY

.export GFX_BgColor

.export gfx_mode
.export LAB_GFX_PLOT
.export LAB_GFX_LINE
.export LAB_GFX_CIRCLE

.export GFX_MODE

;
;	within basic define extensions as follows
;
;	PLOT = $xxxx 				- assign the adress of GFX_Plot from label file
;	CALL PLOT,X,Y,COLOR		- invoke GFX_Plot with CALL api
;

;	in .A - mode 0-7
gfx_mode:
		php
		sei
		cmp #8
		bne @gfx
		jsr GFX_Off
		bra @out
@gfx:
		pha
		jsr krn_textui_disable			;disable textui
		jsr krn_display_off
		plx
		jsr _gfx_set_mode
@out:
		plp
gfx_dummy:
		rts

_gfx_set_mode:
	jmp (_gfx_mode_table,x)


_gfx_mode_table:
      .word GFX_Off  ; 0
      .word GFX_Off  ; 1
      .word vdp_mode2_on ; 2
      .word vdp_mc_on ; 3
      .word gfx_dummy; 4
      .word gfx_dummy; 5
      .word gfx_dummy; 6
      .word vdp_gfx7_on ; 7

GFX_BgColor:
		JSR LAB_GTBY	; Get byte parameter and ensure numeric type, else do type mismatch error. Return the byte in X.
		txa
		jmp vdp_bgcolor

GFX_Off = krn_textui_init     ;restore textui

;	in .A - mode 0-7
LAB_GFX_PLOT:
	jsr LAB_GTBY
	stx GFX_STRUCT+plot_t::x1
	stz GFX_STRUCT+plot_t::x1+1

	JSR LAB_SCGB 	; scan for "," and get byte
	stx GFX_STRUCT+plot_t::y1

	; color
	JSR LAB_SCGB 	; scan for "," and get byte
	stx GFX_STRUCT+plot_t::color
	; TODO
	stz GFX_STRUCT+plot_t::operator

	lda #<GFX_STRUCT
	ldy #>GFX_STRUCT
	jmp gfx_plot

LAB_GFX_LINE:
	jsr LAB_GTBY
	stx GFX_STRUCT+line_t::x1
	stz GFX_STRUCT+line_t::x1+1

	JSR LAB_SCGB 	; scan for "," and get byte
	stx GFX_STRUCT+line_t::y1

	JSR LAB_SCGB 	; scan for "," and get byte
	stx GFX_STRUCT+line_t::x2
	stz GFX_STRUCT+line_t::x2+1

	JSR LAB_SCGB 	; scan for "," and get byte
	stx GFX_STRUCT+line_t::y2

	; color
	JSR LAB_SCGB 	; scan for "," and get byte
	stx GFX_STRUCT+line_t::color
	; TODO
	stz GFX_STRUCT+line_t::operator

	lda #<GFX_STRUCT
	ldy #>GFX_STRUCT

	jmp gfx_line

LAB_GFX_CIRCLE:
	jsr LAB_GTBY
	stx CIRCLE_STRUCT+circle_t::x1
	stz CIRCLE_STRUCT+circle_t::x1+1

	JSR LAB_SCGB 	; scan for "," and get byte
	stx CIRCLE_STRUCT+circle_t::y1

	JSR LAB_SCGB 	; scan for "," and get byte
	stx CIRCLE_STRUCT+circle_t::radius

	JSR LAB_SCGB 	; scan for "," and get byte
	stx CIRCLE_STRUCT+circle_t::color

	stz CIRCLE_STRUCT+circle_t::operator

	lda #<CIRCLE_STRUCT
	ldy #>CIRCLE_STRUCT

	jmp gfx_circle

.bss
GFX_MODE:  .res 1, 0 ;mode as power of 2
GFX_STRUCT: .res .sizeof(line_t) ; we use size of line_t, biggest one
