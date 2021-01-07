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
.import fread
.import fclose

.export ppm_data
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

		jsr read_blocks
		bne @io_error

		jsr ppm_parse_header					; .Y - return with offset to first data byte
		bne @ppm_error
		sty _offs

		jsr load_image
		bne @io_error

        clc
		bra @close_exit

;		jsr primm
;		.byte CODE_LF, "Not a valid ppm file! Must be type P6 with max. ", .string(MAX_WIDTH), "x", .string(MAX_HEIGHT), "px and 8bpp colors.",CODE_LF, 0

;		bra close_exit
;io_error:
;		pha
;		jsr primm
;		.byte $0a,"i/o error, code: ",0
;		pla
;		jsr hexout
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

read_blocks:
		SetVector ppm_data, read_blkptr
		stz _error
		ldx fd
		ldy #BLOCK_BUFFER
		jsr fread
		bne @l_error
		tya
		asl
		sta _pages
		SetVector ppm_data, read_blkptr ; reset ptr to begin of buffer
		lda #EOK
;		clc ; cleared by asl above
		rts
@l_error:
		sta _error	; save error
		stz _pages
		sec
		rts

load_image:
		stz cols
		stz rows

		jsr set_screen_addr	; initial vram address

		ldy _offs ; .Y - data offset
		jsr blocks_to_vram
		lda _error ; on any error
		rts

next_byte:
		clc ; no error
		lda (read_blkptr),y
		iny
		bne @l_exit
		inc read_blkptr+1
		dec _pages
		bne @l_exit
		pha ;save last byte from above
		jsr read_blocks
		bne @l_exit_restore
		ldy #0
@l_exit_restore:
		pla
@l_exit:
		rts

blocks_to_vram:
		jsr rgb_bytes_to_grb
		bcs @exit
		sta a_vram
;		jsr hexout
		inc cols
		lda cols
		cmp ppm_width
		bne blocks_to_vram
		stz cols
		jsr set_screen_addr	; adjust vram address to cols/rows
		inc rows
		lda rows
		cmp ppm_height
		bne blocks_to_vram
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
		php
		sei	;critical section, avoid vdp irq here
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
		plp
		rts

ppm_parse_header:
		lda #'P'
		cmp ppm_data
		bne @l_invalid_ppm
		lda #'6'
		cmp ppm_data+1
		bne @l_invalid_ppm

		ldy #0
		jsr parse_string		;skip "P6"

        jsr parse_until_size	;skip until <width> <height>
		jsr parse_int	;width
		cmp #<MAX_WIDTH
		bcc @l_invalid_ppm ;
		sta ppm_width

		jsr parse_int	;height
		cmp #MAX_HEIGHT+1
		bcs @l_invalid_ppm
        sta ppm_height
		sty _offs ;safe y offset, to check how many chars are consumed during parse
		
        jsr parse_int	;depth
		cmp #COLOR_DEPTH
		bne @l_invalid_ppm
		tya
		sec
		sbc _offs
		cmp #4+1 ; check that 3 digits + 1 delimiter was parsed, so number is <=3 digits
		bcs @l_invalid_ppm
		lda #0
		rts
@l_invalid_ppm:
        lda #$ff
        sec
		rts

parse_until_size:
		lda ppm_data, y
		cmp #'#'				; skip comments
		bne @l
		jsr parse_string
		bra parse_until_size
@l:
		rts

parse_int:
		stz _i
@l_toi:
		lda ppm_data, y
		cmp #'0'
		bcc @l_end
		cmp #'9'+1
		bcs @l_end
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
		bne @l_toi
@l_end:
		iny
		lda _i
		rts

parse_string:
		ldx #0
@l0:	lda ppm_data, y
		cmp #$20		; < $20 - control characters are treat as whitespace
		bcc @le
		iny
		bne @l0
@le:	iny
		rts

.bss
_offs: 	.res 1
_error:	.res 1
_pages:	.res 1
cols:   .res 1
rows:   .res 1
fd:     .res 1
ppm_width:  .res 1
ppm_height: .res 1
ppm_data:    .res BLOCK_BUFFER * $200
