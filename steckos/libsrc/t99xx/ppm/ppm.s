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
; use imagemagick $convert <image> -geometry 256 -color 256 <image.ppm>
; convert <file>.pdf[page] -resize 256x212^ -gravity center -crop x212+0+0 +repage pic.ppm
; convert <file> -resize 256^x192 -gravity center -crop 256x192+0+0 +repage <out file>.ppm
;
.setcpu "65c02"
.include "common.inc"
.include "vdp.inc"
.include "fcntl.inc"
.include "errno.inc"
.include "zeropage.inc"

.import hexout
.import primm

.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_display_off
.import vdp_bgcolor

.import fopen
.import fread_byte
.import fclose

;.export ppm_data
.export ppm_width
.export ppm_height

.export ppm_load_image
.export ppm_parse_header
; for TEST purpose only
.export rgb_bytes_to_grb

.define MAX_WIDTH 256
.define MAX_HEIGHT 212
.define COLOR_DEPTH 255
.define BLOCK_BUFFER 8

.zeropage
_i:     .res 1

.code

;
; in:
;   A/X file name to load
; out:
;   C=0 success and image loaded to vram (mode 7), C=1 otherwise with A/X error code - A ppm specific error, X i/o specific error
.proc ppm_load_image
		stz fd

		ldy #O_RDONLY
		jsr fopen
		bne @io_error
		stx fd

		jsr ppm_parse_header					; .Y - return with offset to first data byte
		bcs @ppm_error

		jsr load_image ; timing critical
		bcs @io_error

		clc
		bra @close_exit

@ppm_error:
        ldx #0
        bra @error
@io_error:
        tax
        lda #0
@error:
        sec
@close_exit:
        php
        phx
        pha
		ldx fd
		beq @l_exit
		jsr fclose
@l_exit:
        pla
        plx
        plp
		rts
.endproc

load_image:
		stz cols
		stz rows

        php
        sei ;critical section, avoid vdp irq here

		jsr set_screen_addr	; initial vram address
		jsr copy_to_vram
		bcs @l_err
        plp
		clc
		rts
@l_err:
        plp
		sec
		rts

next_byte:
		jmp fread_byte

copy_to_vram:
		jsr rgb_bytes_to_grb
		bcs @exit
		sta a_vram
;		jsr hexout
		inc cols
		lda cols
		cmp ppm_width
		bne copy_to_vram
		stz cols
		jsr set_screen_addr	; adjust vram address to cols/rows
		inc rows
		lda rows
		cmp ppm_height
		bne copy_to_vram
		clc
@exit:
		rts

rgb_bytes_to_grb:	; GRB 332 format
		jsr next_byte	;R
		bcs @exit
		and #$e0
		lsr
		lsr
		lsr
		sta _i
		jsr next_byte	;G
		bcs @exit
		and #$e0
		ora _i
		sta _i
		jsr next_byte	;B
		bcs @exit
		rol
		rol
		rol
		and #$03		;blue - bit 1,0
		ora _i
		clc ; no error
@exit:
		rts

set_screen_addr:
		vdp_wait_s 5
		lda cols
		sta a_vreg                 ; A7-A0 vram address low byte
		lda rows
		and #$3f                   ; A13-A8 vram address highbyte
		ora #WRITE_ADDRESS
		vdp_wait_s 4
		sta a_vreg
		lda rows                   ; A16-A14 bank select via reg#14
		rol
		rol
		rol
		and #$03
		ora #<.HIWORD(ADDRESS_GFX7_SCREEN<<2)
		vdp_wait_s
		sta a_vreg
		vdp_wait_s 2
		lda #v_reg14
		sta a_vreg
		rts

ppm_parse_header:
		jsr next_byte
		bcs @l_invalid_ppm
		cmp #'P'
		bne @l_invalid_ppm
		jsr next_byte
		bcs @l_invalid_ppm
		cmp #'3'
		beq :+
		cmp #'6'
		bne @l_invalid_ppm
		jsr parse_string
:
		jsr parse_until_size	;not, skip until <width> <height>
		jsr parse_int			;try parse ppm width
		cmp #<MAX_WIDTH
		bcc @l_invalid_ppm ;
		sta ppm_width
		
		jsr parse_int0	;height
		cmp #MAX_HEIGHT+1
		bcs @l_invalid_ppm
        sta ppm_height

		jsr parse_int0	;color depth
		cpy #3
		bne @l_invalid_ppm
		clc
		rts

@l_invalid_ppm:
        sec
		rts

; C=0 parse ok, C=1 on error
parse_int0:
		jsr next_byte
		bcc parse_int
		rts
parse_int:
		ldy #0
		stz _i
@l_toi:
		cmp #'0'
		bcc @l_exit
		cmp #'9'+1
		bcs @l_exit

		pha		;n*10 => n*2 + n*8
		lda _i
		asl
		sta _i
		asl
		asl
		adc _i
		sta _i
		pla
		sec
		sbc #'0'
		clc
		adc _i
		sta _i
		iny
		phy
		jsr next_byte
		ply
		bcc @l_toi ; C=1 on error
@l_exit:
		lda _i
		rts

; C=0 if digit
is_digit:
		cmp #'0'
		bcc @l_end
		cmp #'9'+1
		bcs @l_end
		rts
@l_end:	sec
		rts

parse_until_size:
		jsr next_byte
		bcs @l
		cmp #'#'				; skip comments
		bne @l
		jsr parse_string
		bra parse_until_size
@l:		rts

parse_string:
@l0:	jsr next_byte
		bcs @le ; C=1 on error
		cmp #$20		; < $20 - control characters are treat as string delimiter
		bcc @le
		bcs @l0
@le:	rts

.bss
_offs: 	.res 1
_error:	.res 1
_pages:	.res 1
cols:   .res 1
rows:   .res 1
fd:     .res 1
ppm_width:  .res 1
ppm_height: .res 1
;ppm_data:    .res BLOCK_BUFFER * $200
