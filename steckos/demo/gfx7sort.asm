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


.import vdp_mode7_on
.import vdp_mode7_blank
.import gfx_plot
.import vdp_wait_cmd

;.import hexout
;.export char_out=krn_chrout


.zeropage
    ptr1:  .res 2
    ptr2:  .res 2
    ptr3:  .res 2
    ptr4:  .res 2
    ptr5:  .res 2
    tmp1:  .res 1
    tmp2:  .res 1
    tmp3:  .res 1
.code
pt_x = ptr2;$10
pt_y = ptr3;$12
ht_x = ptr4;$14
ht_y = ptr5;$16
mode = tmp2;$18
;tmp1 = $32
old_y = tmp3;$34

list_size = 254
draw_bar  = draw_bar_cmd


.code

appstart $1000

main:
        stz pt_x
        stz pt_x+1

        stz pt_y
        lda #$01
        sta pt_y+1

        stz ht_x
        stz ht_x+1

        stz ht_y
        stz ht_y+1

        lda #%00000001
        sta mode

        lda #<list
        sta ptr1
        lda #>list
        sta ptr1+1

        jsr	krn_textui_disable			;disable textui
        jsr	gfxui_on
@loop:

        jsr shuffle_list
        jsr display_list

        jsr SORT8

        keyin
        cmp #'q'
        beq @exit
        sta seed
        jmp @loop
@exit:
        jsr	krn_textui_init
        bit a_vreg ; acknowledge any vdp interrupts before re-enabling interrupts
        cli

        jmp (retvec)

gfxui_on:
        sei
        jsr vdp_mode7_on			    ;enable gfx7 mode

        ; set vertical dot count to 212
        ; V9938 Programmer's Guide Pg 18
        vdp_sreg  v_reg9_ln , v_reg9

        lda #%00000011
        jsr vdp_mode7_blank

        cli
        rts

;@end:

;        vdp_reg 14,0

;        cli
;        rts

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
        lda list,x

        jsr draw_bar

        inx
        cpx #list_size+1
        bne @loop

        restore
        rts

; a - value
; x - pos
draw_bar_cmd:
        pha
        phx
        pha
        stx pt_x

        ldx #212
        stx ht_x

        lda #%00000011
        jsr vdp_gfx7_line

        pla
        sta ht_x

        vdp_wait_s 4

        lda #$ff
        jsr vdp_gfx7_line

        plx
        pla
        rts

; a - value
; x - pos
draw_bar_cmd_color:
        pha
        phx
        pha
        stx pt_x

        ldx #212
        stx ht_x

        ;lda #%00000011
        pla
        jsr vdp_gfx7_line

        ;pla
        ;sta ht_x

        ;vdp_wait_s 4

        ;lda #$ff
        ;jsr vdp_gfx7_line

        plx
        pla
        rts

draw_bar_slow:
        pha
        phy
        sta old_y
        ldy #0
@l1:
        lda #$ff
        jsr gfx_plot
        iny
        cpy old_y
        bne @l1

@l2:
        lda #%00000011
        jsr gfx_plot
        iny
        cpy #list_size+1
        bne @l2

        ply
        pla
        rts


;THIS SUBROUTINE ARRANGES THE 8-BIT ELEMENTS OF A LIST IN ASCENDING
;ORDER.  THE STARTING ADDRESS OF THE LIST IS IN LOCATIONS $30 AND
;$31.  THE LENGTH OF THE LIST IS IN THE FIRST BYTE OF THE LIST.  LOCATION
;$32 IS USED TO HOLD AN EXCHANGE FLAG.

SORT8:
        LDY #$00      ;TURN EXCHANGE FLAG OFF (= 0)
        STY tmp1
        LDA (ptr1),Y   ;FETCH ELEMENT COUNT
        TAX           ; AND PUT IT INTO X
        INY           ;POINT TO FIRST ELEMENT IN LIST
        DEX           ;DECREMENT ELEMENT COUNT
NXTEL:  LDA (ptr1),Y   ;FETCH ELEMENT
        INY
        CMP (ptr1),Y   ;IS IT LARGER THAN THE NEXT ELEMENT?
        BCC CHKEND
        BEQ CHKEND
                      ;YES. EXCHANGE ELEMENTS IN MEMORY
        PHA           ; BY SAVING LOW BYTE ON STACK.
        LDA (ptr1),Y  ; THEN GET HIGH BYTE AND
        DEY           ; STORE IT AT LOW ADDRESS
        STA (ptr1),Y

        jsr draw_sort_bar

        PLA           ;PULL LOW BYTE FROM STACK
        INY           ; AND STORE IT AT HIGH ADDRESS
        STA (ptr1),Y

        jsr draw_sort_bar

        LDA #$FF      ;TURN EXCHANGE FLAG ON (= -1)
        STA tmp1
CHKEND: DEX           ;END OF LIST?
        BNE NXTEL     ;NO. FETCH NEXT ELEMENT
        BIT tmp1       ;YES. EXCHANGE FLAG STILL OFF?
        BMI SORT8     ;NO. GO THROUGH LIST AGAIN
        RTS           ;YES. LIST IS NOW ORDERED

draw_sort_bar:
        save
        pha
        tya
        tax
        pla
        jsr draw_bar
        restore
        rts

vdp_gfx7_line:
    pha

    sei ; disable interrupts while we feed the VDP to prevent intermittend writes to the vdp regs by the isr

    vdp_sreg 36, v_reg17 ; start at ref36

    lda pt_x
    vdp_wait_s 2
    sta a_vregi

    lda pt_x+1
    vdp_wait_s 2
    sta a_vregi

    lda pt_y
    vdp_wait_s 2
    sta a_vregi

    lda pt_y+1
    vdp_wait_s 2
    sta a_vregi

    lda ht_x
    vdp_wait_s 2
    sta a_vregi

    lda ht_x+1
    vdp_wait_s 2
    sta a_vregi

    lda ht_y
    vdp_wait_s 2
    sta a_vregi

    lda ht_y+1
    vdp_wait_s 2
    sta a_vregi

    pla
    vdp_wait_s 2
    sta a_vregi

    ; R#45 Set mode byte

;   lda #%0000001
         ;^^^^^^^
         ;|||||||--- Long/short axis definition - 0: long x, 1: long y
         ;||||||---- undefined
         ;|||||----- x transfer direction       - 0: right,  1: left
         ;||||------ y transfer direction       -
         ;|||------- Destination location       - 0: VRAM,   1: ExpRAM
         ;||-------- undefined
         ;|--------- 0
    lda mode
    vdp_wait_s 2
    sta a_vregi

    ; R#46 - define logical operation and exec command
    lda #v_cmd_line
    vdp_wait_s 2
    sta a_vregi
    jsr vdp_wait_cmd  ; optimize if move to library.... since wait cmd also disables irq
    cli ; interrupts back on
    rts

.data
seed:   .BYTE 242
.bss
list:   .res list_size
;list:
;    .byte list_size
;    .repeat list_size, i
;    .byte i
;    .endrepeat
