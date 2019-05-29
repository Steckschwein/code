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

      .import vdp_bgcolor
      .importzp tmp1,tmp2

.code

hline=tmp1
index=tmp2
ypos=tmp3

.proc	_main: near
        jsr	krn_textui_disable
        
        sei
        set_irq isr, save_irq
        vdp_sreg v_reg0_IE1, v_reg0   ; enable hblank irq
        cli
@loop:
        keyin
        bcc @loop
        
        sei
        vdp_sreg 0, v_reg15
        vdp_sreg 0, v_reg0
        restore_irq save_irq
        cli
        
        jsr	krn_textui_init
        bit a_vreg ; acknowledge any vdp interrupts before re-enabling interrupts
        jmp (retvec)
.endproc

isr:
      save
      lda a_vreg
      and #1      ; h-blank irq?
      beq @vblank
      ldx index
      bmi @exit
      lda raster_bar_colors,x
      asl
      asl
      asl
      asl
;      ora raster_bar_colors,x
      sta a_vreg
      lda #v_reg7
      vdp_wait_s 2
      sta a_vreg
      dex
      stx index
      inc hline
      lda hline
      bra @sethline
@vblank:
      vdp_sreg 0, v_reg15 ; status register 0
      vdp_wait_s
      bit a_vreg  ; v-blank irq?
      bpl @exit
      lda #Black
      jsr vdp_bgcolor
      lda #(raster_bar_colors_end-raster_bar_colors-1)
      sta index
      dec ypos
      bpl :+
      lda #(sin_tab_end-sin_tab-1)
      sta ypos
:     ldy ypos
      lda sin_tab,y
      ;asl
      eor #$ff
      clc
      adc #50
      sta hline
@sethline:
      ldy #v_reg19
      vdp_sreg
      vdp_sreg 1, v_reg15 ; prepare for read status register 1 on next irq
@exit:
      restore
      rti

.data
raster_bar_colors:
      .byte Black
      .byte Magenta
      .byte Dark_Red
      .byte Medium_Red
      .byte Light_Red
      .byte Dark_Yellow
      .byte Light_Yellow
      .byte White
      .byte Light_Yellow
      .byte Dark_Yellow
      .byte Light_Red
      .byte Medium_Red
      .byte Dark_Red
      .byte Magenta
raster_bar_colors_end:

sin_tab:  ; taken from dinosaur game... FTW!
      .byte	5
      .byte	10
      .byte	14
      .byte	19
      .byte	24
      .byte	28
      .byte	32
      .byte	36
      .byte	40
      .byte	43
      .byte	46
      .byte	48
      .byte	51
      .byte	53
      .byte	54
      .byte	55
      .byte	56
      .byte	56
      .byte	56
      .byte	55
      .byte	54
      .byte	53
      .byte	51
      .byte	48
      .byte	46
      .byte	43
      .byte	40
      .byte	36
      .byte	32
      .byte	28
      .byte	24
      .byte	19
      .byte	14
      .byte	10
      .byte	5
sin_tab_end:

.bss
save_irq: .res 2
