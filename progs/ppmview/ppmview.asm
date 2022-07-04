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

;
; use imagemagick $convert <image> -geometry 256 -colort 256 <image.ppm>
;
.setcpu "65c02"
.include "zeropage.inc"
.include "common.inc"
.include "vdp.inc"
.include "kernel_jumptable.inc"
.include "appstart.inc"

.autoimport

.export char_out=krn_chrout
.export fopen=krn_open
.export fread_byte=krn_fread_byte
.export fclose=krn_close

appstart $1000
.code
;		lda #<filename
;		ldx #>filename
		jsr gfxui_on

		lda paramptr
		ldx paramptr+1
        jsr ppm_load_image
        bcs io_error

		keyin

		jsr gfxui_off
exit:
        jmp (retvec)

io_error:
		jsr gfxui_off
        cmp #0
        beq :+
        jsr primm
		.byte $0a,"Not a valid ppm file! Must be type P6 with 256x192px and 8bpp colors.",0
        jmp exit
:       jsr primm
        .byte $0a,"i/o error, code: ",0
        txa
        jsr hexout
        jmp exit

gfxui_on:
		jsr krn_textui_disable			;disable textui

		jsr vdp_mode7_on			   ;enable gfx7 mode
		vdp_sreg v_reg9_ln | v_reg9_nt, v_reg9  ; 212px

		lda #%00000000
		jsr vdp_mode7_blank

		rts

gfxui_off:
      sei

      pha
      phx
      vdp_sreg v_reg9_nt, v_reg9  ; 192px
      jsr krn_textui_init
      plx
      pla

      cli

      rts
.bss
irqsafe: .res 2
