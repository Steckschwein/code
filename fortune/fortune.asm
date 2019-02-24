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

.include "steckos.inc"
.include "rtc.inc"
appstart $1000
.export char_out=krn_chrout


.importzp ptr1

.code

main:
        lda rtc_systime_t+time_t::tm_sec
        eor rtc_systime_t+time_t::tm_min
        sta seed

        jsr prnd

        asl
        tay
        lda fortunes_tab+1,y
        sta ptr1+1
        lda fortunes_tab,y
        sta ptr1

out:

        ldy #0
loop:
        lda (ptr1),y
        beq exit
        jsr krn_chrout
        iny
        bne loop
exit:
		jmp (retvec)

prnd:
        lda seed
        beq doEor
        asl
        beq noEor ;if the input was $80, skip the EOR
        bcc noEor
doEor:  eor #$1d
noEor:  sta seed
        rts

seed:    .BYTE 42
.include "fortunes.inc"
