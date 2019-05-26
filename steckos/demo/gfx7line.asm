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

.import vdp_gfx7_on
.import vdp_gfx7_blank
.import vdp_wait_cmd
.import vdp_bgcolor

appstart $1000

pt_x = $10
pt_y = $12
ht_x = $14
ht_y = $16

.code
main:
		lda #0
		sta pt_x
		stz pt_x+1

		lda #0
		sta pt_y
		lda #$01
		sta pt_y+1

		lda #0
		sta ht_x
		lda #0
		sta ht_x+1

		lda #0
		sta ht_y
		lda #0
		sta ht_y+1


    sei
    jsr	krn_textui_disable			;disable textui
    jsr	gfxui_on

		ldx #0

@loop:
    lda #$ff
    jsr vdp_gfx7_line

    stx ht_x
    stx pt_x
;        dec ht_y
;        dec ht_y
;        dec ht_y
;        dec ht_y
;        dec ht_y
;        dec ht_y
;        dec ht_y
;        dec ht_y
;        dec ht_y
;        dec ht_y
;        dec ht_y
;        dec ht_y

    inx
    cpx #212
    bne @loop

    keyin

    cli
    jsr	krn_textui_init
    jsr	krn_textui_enable
    bit a_vreg ; acknowledge any vdp interrupts before re-enabling interrupts

		jmp (retvec)

gfxui_on:
    jsr vdp_gfx7_on			    ;enable gfx7 mode
    ; set vertical dot count to 212
    ; V9938 Programmer's Guide Pg 18
    vdp_sreg  v_reg9_ln , v_reg9

    lda #%00000011
    jsr vdp_gfx7_blank

    rts

vdp_gfx7_line:
	pha

    vdp_sreg 36, v_reg17 ; start at ref36
    vdp_wait_s 4

	lda pt_x
	sta a_vregi
    vdp_wait_s 2

	lda pt_x+1
	sta a_vregi
    vdp_wait_s 4

	lda pt_y
	sta a_vregi
    vdp_wait_s 2

	lda pt_y+1
	sta a_vregi
    vdp_wait_s 4

	lda ht_x
	sta a_vregi
    vdp_wait_s 2

	lda ht_x+1
	sta a_vregi
    vdp_wait_s 4

	lda ht_y
	sta a_vregi
    vdp_wait_s 2

	lda ht_y+1
	sta a_vregi
    vdp_wait_s 4

	pla
	sta a_vregi
    vdp_wait_s 4

    ; R#45 Set mode byte
	lda #%0000001
         ;^^^^^^^
         ;|||||||--- Long/short axis definition - 0: long x, 1: long y
         ;||||||---- undefined
         ;|||||----- x transfer direction       - 0: right,  1: left
         ;||||------ y transfer direction       -
         ;|||------- Destination location       - 0: VRAM,   1: ExpRAM
         ;||-------- undefined
         ;|--------- 0
	sta a_vregi
  vdp_wait_s 2

    ; R#46 - define logical operation and exec command
	lda #v_cmd_line
	sta a_vregi
  jmp vdp_wait_cmd