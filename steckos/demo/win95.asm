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

.autoimport

.export char_out=krn_chrout
.export fopen=krn_fopen
.export fread_byte=krn_fread_byte
.export fclose=krn_close

appstart $1000

screen_vram = $00000

progress_rows = 6

.zeropage
  p_progress: .res 2
  ix: .res 1

.code
            php
            sei
            jsr krn_textui_disable      ;disable textui

            jsr vdp_mode7_on         ;enable gfx7 mode
            vdp_sreg v_reg9_nt, v_reg9  ; 192px / PAL
            ldy #0
            jsr vdp_mode7_blank
            plp

            lda #<win95_ppm
            ldx #>win95_ppm
            ldy #0
            jsr ppm_load_image
            bcc :+
            jmp @exit

:           php
            sei
            copypointer user_isr, save_isr
            SetVector isr, user_isr

            vdp_sreg >(screen_vram>>3) | $1f, v_reg2 ; R#2
            vdp_sreg <.HIWORD(screen_vram<<2 & $07), v_reg14   ; #R14

            vdp_vram_r screen_vram+((192-progress_rows)*256)  ; capture progress bar
            SetVector progress_bar, p_progress
            ldy #0
            ldx #progress_rows
:           lda a_vram
            sta (p_progress),y
            iny
            bne :-
            inc p_progress+1
            dex
            bne :-

            stz ix
            stz state

            plp

            ;keyin

            inc state
:           keyin
            cmp #KEY_ESCAPE
            bne :-

 @exit:     php
            sei
            copypointer save_isr, user_isr
            jsr krn_textui_init
            plp

            jmp (retvec)

isr:
            bit a_vreg
            bpl @exit

            lda #$0;24
            jsr vdp_bgcolor

            lda state
            beq @exit

            jsr progress
            jsr progress

@exit:
            lda #$0
            jsr vdp_bgcolor
            rts

progress:
            vdp_vram_w screen_vram+((192-progress_rows)*256)  ; capture progress bar
            SetVector progress_bar, p_progress
            ldx #progress_rows
:           ldy ix
:           lda (p_progress),y
            sta a_vram
            iny
            cpy ix
            bne :-
            inc p_progress+1
            dex
            bne :--
            inc ix
            rts

.data
  win95_ppm: .asciiz "win95.ppm"

.bss
  state: .res 1
  save_isr: .res 2
  progress_bar: .res 256*8
