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

.import hexout
.importzp ptr1
tmp0 = $32
list_size = 100
list = $2000

.code
        lda #<list
        sta ptr1
        lda #>list
        sta ptr1+1

        ldy #1
loop:
        jsr prnd
        sta (ptr1),y
        iny
        cpy #list_size+1
        bne loop


        jsr output_list

        jsr SORT8
        crlf
        jsr output_list

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

output_list:
        pha
        phx
        ldx #1
@loop:
        lda list,x
        jsr hexout
        inx
        cpx #list_size+1
        bne @loop

        plx
        pla
        rts

;THIS SUBROUTINE ARRANGES THE 8-BIT ELEMENTS OF A LIST IN ASCENDING
;ORDER.  THE STARTING ADDRESS OF THE LIST IS IN LOCATIONS $30 AND
;$31.  THE LENGTH OF THE LIST IS IN THE FIRST BYTE OF THE LIST.  LOCATION
;$32 IS USED TO HOLD AN EXCHANGE FLAG.

SORT8:   LDY #$00      ;TURN EXCHANGE FLAG OFF (= 0)
         STY tmp0
         LDA (ptr1),Y   ;FETCH ELEMENT COUNT
         TAX           ; AND PUT IT INTO X
         INY           ;POINT TO FIRST ELEMENT IN LIST
         DEX           ;DECREMENT ELEMENT COUNT
NXTEL:   LDA (ptr1),Y   ;FETCH ELEMENT
         INY
         CMP (ptr1),Y   ;IS IT LARGER THAN THE NEXT ELEMENT?
         BCC CHKEND
         BEQ CHKEND
                       ;YES. EXCHANGE ELEMENTS IN MEMORY
         PHA           ; BY SAVING LOW BYTE ON STACK.
         LDA (ptr1),Y   ; THEN GET HIGH BYTE AND
         DEY           ; STORE IT AT LOW ADDRESS
         STA (ptr1),Y
         PLA           ;PULL LOW BYTE FROM STACK
         INY           ; AND STORE IT AT HIGH ADDRESS
         STA (ptr1),Y
         LDA #$FF      ;TURN EXCHANGE FLAG ON (= -1)
         STA tmp0



CHKEND:  DEX           ;END OF LIST?
         BNE NXTEL     ;NO. FETCH NEXT ELEMENT
         BIT tmp0       ;YES. EXCHANGE FLAG STILL OFF?
         BMI SORT8     ;NO. GO THROUGH LIST AGAIN
         RTS           ;YES. LIST IS NOW ORDERED

seed:    .BYTE 42
