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
		.importzp __volatile_ptr
		.importzp __volatile_tmp

		.import char_out

		.export crc7

.code
;crc = tmp2
polynom = $89
;polynom = $91

;
;  in:
;	  .A/.Y - pointer to input data
;	  .X length
;  out:
;	  .A calculated crc7
.proc crc7
			cpx #0
			beq @rts
			stx __volatile_tmp

			sta __volatile_ptr
			sty __volatile_ptr+1

			ldy #0
			lda #0	;crc = 0
@loop:
			ldx #8
			eor (__volatile_ptr),y
@loop_x:
			bit #$80			 ;
			beq @crc_shift
			asl					;
			eor #<(polynom<<1); crc<<1 ^ polynome<<1
			bra @next
@crc_shift:
			asl					; crc<<1
@next:
			dex
			bne @loop_x

			iny
			cpy __volatile_tmp
			bne @loop

			lsr	; crc >> 1
@rts:
			rts
.endproc
