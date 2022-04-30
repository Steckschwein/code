; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschein.de
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

.export hexout_s
.export hexout

.import char_out
.code
;
;	hexout a binary number - convert a byte given in A into 2 character ascii and output to char_out
;	in :
;		A - the byte to convert
;	out:
;		-
hexout_s:
        pha
        lda #'$'
        jsr char_out
        pla 
hexout:
        pha
		pha

		lsr     ; msb first
		lsr
		lsr
		lsr
        ; https://twitter.com/adumont/status/1381857942467702785
        sed
        cmp #$0a
        adc #$30
        cld
        jsr char_out

        pla
        and #$0f    ;mask lsd for hex print

        sed
        cmp #$0a
        adc #$30
        cld
_out:
        jsr char_out

        pla
		rts
