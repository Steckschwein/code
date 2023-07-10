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

.include "common.inc"
.include "system.inc"
.include "appstart.inc"
.include "uart.inc"
.include "keyboard.inc"

.import primm
.import hexout
.import hexout_s

.export char_out=uart_tx

.zeropage
      bank_nr:    .res 1
      bank_addr:  .res 2
      _ix: .res 1

appstart $1000

uart_cpb = $0200

.code
      sys_delay_ms 1000

      jsr primm
      .byte KEY_LF,"steckschwein 2.0 memory bank test", KEY_LF,0

@start:
      jsr primm
      .byte KEY_LF,"memooOOwWW_?ry test single banks",KEY_LF,0
      ; fill
      ldx #1         ; start with 2nd 16k window is used for testing, we start with RAM address $00000
@loop:
      stx bank_nr
      lda bank_tab_l,x
      sta bank_addr+0
      lda bank_tab_h,x
      sta bank_addr+1

      jsr memcheck_linear
      bne exit_error

      jsr primm
      .byte " bank ",0
      lda bank_nr
      jsr hexout_s
      jsr primm
      .byte " OK",KEY_LF,0

      ldx bank_nr
      inx
      cpx #04
      bne @loop

      jsr memcheck_mixed_bank
      bne exit_error

      jsr primm
      .byte KEY_LF,KEY_LF,"512k RAM memtest OK",KEY_LF,0
      bra @start

exit_error:
      phy
      phy
      pha
      jsr primm
      .byte KEY_LF, "Error detected bank ", 0
      lda bank_nr
      jsr hexout_s
      jsr primm
      .byte " expect pattern ",0
      pla
      jsr hexout_s
      jsr primm
      .byte " was ",0
      ply
      lda bank_addr,y
      jsr hexout_s
      jsr primm
      .byte " offset ",0
      pla
      jsr hexout_s
:     bra :-

memcheck_mixed_bank:
      jsr primm
      .byte KEY_LF, "memory test across banks",0

      ldy #0
@loop:
      sty _ix

      jsr print_srctgt
      ldx bank_cross_src,y ; src bank
      stx bank_nr
      stz ctrl_port,x
      lda bank_tab_l,x     ; init src address pointer
      sta bank_addr+0
      lda bank_tab_h,x
      sta bank_addr+1

      ;fill
      ldx #0
@l0:
      lda #KEY_CR
      jsr char_out
      jsr reg_dump

      lda pattern,x
      ldy #0            ; fill last page of the 16k ram segments with patterns
@l1:
      sta (bank_addr),y
      iny
      bne @l1

      phx
      ldx bank_nr
      inc ctrl_port,x
      plx
      inx
      cpx #(pattern_e-pattern) ; 32 pattern, for 32*16k = 512k RAM
      bne @l0

      ; test
      ldy _ix
      ldx bank_cross_tgt,y ; target bank
      stx bank_nr
      stz ctrl_port,x
      lda bank_tab_l,x     ; init target address pointer
      sta bank_addr+0
      lda bank_tab_h,x
      sta bank_addr+1

      ldx #0
@l2:
      lda #KEY_CR
      jsr char_out
      jsr reg_dump

      lda pattern,x
      ldy #0
@l3:
      cmp (bank_addr),y
      bne @exit
      iny
      bne @l3

      phx
      ldx bank_nr
      inc ctrl_port,x
      plx
      inx
      cpx #(pattern_e-pattern)
      bne @l2

      jsr primm
      .asciiz " OK"

      ldy _ix
      iny
      cpy #(bank_cross_tgt-bank_cross_src)
      bne @loop
@exit:
      rts

print_srctgt:
      phy
      jsr primm
      .byte KEY_LF," bank src ",0
      ldy _ix
      lda bank_cross_src,y ; src bank
      jsr hexout_s
      jsr primm
      .asciiz " target "
      ldy _ix
      lda bank_cross_tgt,y ; tgt bank
      jsr hexout_s
      lda #KEY_LF
      jsr char_out
      ply
      rts

memcheck_linear:
      ldx bank_nr      ; select bank
      stz ctrl_port,x
      ;fill
      ldx #0
@l0:
      lda #KEY_CR
      jsr char_out
      jsr reg_dump

      lda pattern,x
      ldy #0            ; fill last page of the 16k ram segments with patterns
@l1:
      sta (bank_addr),y
      iny
      bne @l1

      phx
      ldx bank_nr
      inc ctrl_port,x
      plx
      inx
      cpx #(pattern_e-pattern) ; 32 pattern, for 32*16k = 512k RAM
      bne @l0

      ; test
      ldx bank_nr
      stz ctrl_port,x
      ldx #0
@l2:
      lda #KEY_CR
      jsr char_out
      jsr reg_dump

      lda pattern,x
      ldy #0
@l3:
      cmp (bank_addr),y
      bne @exit
      iny
      bne @l3

      phx
      ldx bank_nr
      inc ctrl_port,x
      plx
      inx
      cpx #(pattern_e-pattern)
      bne @l2
@exit:
      rts


dump_cpu:
      rts
      pha
      lda #' '
      jsr char_out
      jsr hexout_s
      txa
      jsr hexout_s
      tya
      jsr hexout_s
      lda #KEY_LF
      jsr char_out
      pla
      rts

reg_dump:
      phx
      phy
      jsr primm
      .asciiz " R0:"
      lda ctrl_port+0
      jsr hexout_s

      jsr primm
      .asciiz " R1:"
      jsr char_out
      lda ctrl_port+1
      jsr hexout_s

      jsr primm
      .asciiz " R2:"
      lda ctrl_port+2
      jsr hexout_s

      jsr primm
      .asciiz " R3:"
      lda ctrl_port+3
      jsr hexout_s
      ply
      plx
      rts

uart_tx:
      pha
      lda #lsr_THRE
@l0:
      bit uart_cpb+uart_lsr
      beq @l0

      pla
      sta uart_cpb+uart_rxtx
      rts

.data
bank_tab_l:
      .byte $00
      .byte $00
      .byte $00
      .byte $00
bank_tab_h:
      .byte $04
      .byte $47
      .byte $89
      .byte $ce

bank_cross_src:
      .byte 1,1,2,2,3,3
bank_cross_tgt:
      .byte 2,3,1,3,1,2

pattern:
      .byte $f0,$0f,$96,$69,$a9,$9a,$10,$01
      .byte $3c,$c3,$61,$16,$e7,$7e,$81,$18
      .byte $24,$42,$ff,$00,$a7,$7a,$31,$13
      .byte $41,$14,$51,$15,$f3,$3f,$8a,$a8
pattern_e:
