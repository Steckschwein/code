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
.include "vdp.inc"


; draw some pixels using vdp_gfx7_set_pixel, which uses the v9958 PSET command

.import vdp_gfx7_on
.import vdp_gfx7_blank
; .import vdp_gfx7_set_pixel_n
.import vdp_gfx7_set_pixel
.import vdp_gfx7_set_pixel_cmd
.import vdp_display_off
.import vdp_memcpy
.import vdp_mode_sprites_off
.import vdp_bgcolor
.import hexout
.export char_out=krn_chrout

.importzp ptr1
tmp0 = $32
tmp1 = $33
list_size = 254
;list = $2000

.code

appstart $1000

.code
main:
        lda #<list
        sta ptr1
        lda #>list
        sta ptr1+1

		jsr	krn_textui_disable			;disable textui
		jsr	gfxui_on

        jsr shuffle_list

        jsr display_list

        jsr SORT8


		keyin
		jsr	gfxui_off

		jsr	krn_display_off			;restore textui
		jsr	krn_textui_init
		jsr	krn_textui_enable
		cli

		jmp (retvec)

blend_isr:
        pha
        vdp_reg 15,0
        vnops
        bit a_vreg
        bpl @0

        lda	#%11100000
        jsr vdp_bgcolor

        lda	#Black
        jsr vdp_bgcolor
@0:
        pla
        rti

gfxui_on:
        sei
        jsr vdp_display_off			;display off
        jsr vdp_mode_sprites_off	;sprites off

        jsr vdp_gfx7_on			    ;enable gfx7 mode

        lda #%00000011
        jsr vdp_gfx7_blank



        copypointer  $fffe, irqsafe
        SetVector  blend_isr, $fffe
        rts

@end:
        vdp_reg 14,0

        cli
        rts

gfxui_off:
        sei

        copypointer  irqsafe, $fffe
        cli
        rts



prnd:
        lda seed
        beq doEor
        asl
        beq noEor ;if the input was $80, skip the EOR
        bcc noEor
doEor:  eor #$1d
noEor:  sta seed
        rts

shuffle_list:
        ldy #0
        lda #list_size
        sta (ptr1),y
        iny
@loop:
        jsr prnd
        sta (ptr1),y
        iny
        cpy #list_size+1
        bne @loop
        rts

display_list:
        save

        ldx #1
@loop:
        ldy list,x
        lda #$ff
        jsr vdp_gfx7_set_pixel
        ;vnops
        inx
        cpx #list_size+1
        bne @loop

        restore
        rts

display_list2:
        save

        ldx #1
@loop:
        ldy list,x
        lda #%00000011
        jsr vdp_gfx7_set_pixel
        ;vnops
        inx
        cpx #list_size+1
        bne @loop

        restore
        rts

setpixel:
        pha
        phx
        phy
        tya
        tax
        lda (ptr1),y
        sta tmp1
        lda #192
        sec
        sbc tmp1
        tay

        lda #%00011100
        jsr vdp_gfx7_set_pixel
        ply
        plx
        pla
        rts

;THIS SUBROUTINE ARRANGES THE 8-BIT ELEMENTS OF A LIST IN ASCENDING
;ORDER.  THE STARTING ADDRESS OF THE LIST IS IN LOCATIONS $30 AND
;$31.  THE LENGTH OF THE LIST IS IN THE FIRST BYTE OF THE LIST.  LOCATION
;$32 IS USED TO HOLD AN EXCHANGE FLAG.

SORT8:  LDY #$00      ;TURN EXCHANGE FLAG OFF (= 0)
        STY tmp0
        LDA (ptr1),Y   ;FETCH ELEMENT COUNT
        TAX           ; AND PUT IT INTO X
        INY           ;POINT TO FIRST ELEMENT IN LIST
        DEX           ;DECREMENT ELEMENT COUNT
NXTEL:
        jsr display_list2
        LDA (ptr1),Y   ;FETCH ELEMENT
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


        jsr display_list

CHKEND:
        DEX           ;END OF LIST?
        BNE NXTEL     ;NO. FETCH NEXT ELEMENT
        BIT tmp0       ;YES. EXCHANGE FLAG STILL OFF?
        BMI SORT8     ;NO. GO THROUGH LIST AGAIN
        RTS           ;YES. LIST IS NOW ORDERED

seed:   .BYTE 99


irqsafe: .res 2, 0

.data
list:   .res 255
;list:
;    .byte 254
;    .repeat 254, i
;    .byte i
;    .endrepeat
.segment "STARTUP"
