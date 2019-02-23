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
.import hexout

.code

main:
        lda rtc_systime_t+time_t::tm_sec
        eor rtc_systime_t+time_t::tm_min
        sta seed
        ;jsr hexout

        jsr prnd
        ;jsr hexout

        tay
        lda fortunes_hi,y
        sta ptr1+1
        lda fortunes_lo,y
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

fortunes_hi:
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
        .byte >fortune0, >fortune1, >fortune2, > fortune3, >fortune4, >fortune5, >fortune6, >fortune7
fortunes_lo:
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
        .byte <fortune0, <fortune1, <fortune2, < fortune3, <fortune4, <fortune5, <fortune6, <fortune7
fortune0:
        .byte "Mathematiker:",$0a,"Meine Lieblingszahl ist ",$e3,".",$0a
        .byte "Physiker:",$0a,"Meine Lieblingszahl ist e.", $0a
        .byte "Ingenieur:",$0a,"Witzig! Meine Lieblingszahl ist auch 3.", $0a,$0a
        .byte 0
fortune1:
        .byte "A conservative is a man who is too cowardly to fight and too fat to run.",$0a
        .byte "    -- Elbert Hubbard",$0a
        .byte $0a,0
fortune2:
        .byte "psychologist, n.:",$0a
        .byte "   Someone who watches everyone else when an attractive woman walks",$0a
        .byte "   into a room.",$0a
        .byte $0a,0
fortune3:
        .byte "If it ain't broke, don't fix it.",$0a
		.byte "    -- Bert Lantz",$0a
        .byte $0a,0
fortune4:
        .byte "If you steal from one author it's plagiarism; if you steal from", $0a
        .byte "many it's research.", $0a
        .byte "    -- Wilson Mizner", $0a
        .byte $0a,0
fortune5:
        .byte "Auch wenn das Brett vor dem Kopf aus Teakholz ist, wird sein Träger", $0a
        .byte "dadurch nicht edeler.", $0a
		.byte "    -- Edmund Kreuzner", $0a
        .byte $0a,0
fortune6:
        .byte "Wer nicht immer weiser wird, der ist nicht einmal weise.", $0a
        .byte "    -- Jean Paul", $0a
        .byte $0a,0
fortune7:
        .byte "Fleiß kann man vortäuschen - faul muß man wirklich sein.",$0a
        .byte $0a,0

seed:    .BYTE 42
