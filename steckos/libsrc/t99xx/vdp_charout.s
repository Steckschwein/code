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

.export vdp_charout

.include "vdp.inc"
.include "common.inc"
.include "keyboard.inc"
.include "zeropage.inc"

.segment "ZEROPAGE_LIB": zeropage
  v_rd: .res 2
  v_wr: .res 2

.code

ROWS=23
.ifdef COLS80
  .ifndef V9958
    .assert 0, error, "80 COLUMNS ARE SUPPORTED ON V9958 ONLY! MAKE SURE -DV9958 IS ENABLED"
  .endif
  COLS=80
.else
  COLS=40
.endif

_vdp_scroll_up:
      phx
      SetVector  (ADDRESS_TEXT_SCREEN+COLS), v_rd            ; +COLS - offset second row
      SetVector  (ADDRESS_TEXT_SCREEN+(WRITE_ADDRESS<<8)), v_wr  ; offset first row as "write adress"
      php
      sei
@loop:
      lda  v_rd+0  ; 3cl
      sta  a_vreg
      nop
      lda  v_rd+1  ; 3cl
      sta  a_vreg
      vdp_wait_l    ; wait 2µs, 8Mhz = 16cl => 8 nop
      ldx  a_vram  ;
      vdp_wait_l

      lda  v_wr+0  ; 3cl
      sta  a_vreg
      vdp_wait_l
      lda  v_wr+1  ; 3cl
      sta a_vreg
      vdp_wait_l
      stx  a_vram
      inc  v_rd+0  ; 5cl
      bne  @l3     ; 3cl
      inc  v_rd+1
      lda  v_rd+1
      cmp  #>(ADDRESS_TEXT_SCREEN+(COLS * 24 + (COLS * 24 .MOD 256)))  ;screen ram end reached?
      beq  @l4
@l3:
      inc  v_wr+0  ; 5cl
      bne  @loop   ; 3cl
      inc  v_wr+1
      bra  @loop
@l4:
      ldx  #COLS  ; write address is already setup from loop
      lda  #' '
@l5:
      sta  a_vram
      vdp_wait_l
      dex
      bne  @l5
      plp
      plx
      rts

vdp_charout:
      cmp #KEY_CR      ;cariage return ?
      bne @l1
      stz crs_x
      rts
@l1:
      cmp #CODE_LF      ;line feed
      bne @l2
@inc_cursor_y:
      stz crs_x
      lda crs_y
      cmp #ROWS    ;last line ?
      bne @l_y
      bra _vdp_scroll_up  ; scroll up, dont inc y, exit
@l_y:
      inc crs_y
      rts
@l2:
      cmp  #KEY_BACKSPACE
      bne  @l3
      lda  crs_x
      beq  @l4
      dec  crs_x
      bra @l5
@l4:
      lda  crs_y      ; cursor y=0, no dec
      beq  @l6
      dec  crs_y
      lda  #(COLS-1)    ; set x to end of line above
      sta  crs_x
@l5:
      lda #' '
@vdp_putchar:
      php
      sei
      pha
      jsr vdp_set_addr
      pla
      vdp_wait_l 8
      sta a_vram
      plp
      rts
@l3:
      jsr @vdp_putchar
      lda crs_x
      cmp #(COLS-1)
      beq @inc_cursor_y
      inc crs_x
@l6:  rts


.ifndef CHAR6x8
vdp_set_addr:        ; set the vdp vram adress, write A to vram
    lda  crs_y       ; * 32
    asl
    asl
    asl
    asl
    asl
    ora crs_x
    sta a_vreg

    lda crs_y       ; * 32
    lsr          ; div 8 -> page offset 0-2
    lsr
    lsr
    ora #(WRITE_ADDRESS + >ADDRESS_TEXT_SCREEN)
    nop
    nop
    sta a_vreg
    rts
.endif

.ifdef CHAR6x8
vdp_set_addr:      ; set the vdp vram adress, write A to vram
      stz vdp_ptr+1
      lda crs_y
      asl
      asl
      asl             ; y*8
      sta vdp_ptr

      asl             ; y*16
      rol vdp_ptr+1
      asl             ; y*32
      rol vdp_ptr+1

      adc vdp_ptr
      bcc :+
      inc vdp_ptr+1
      clc             ; y*40
:
  .ifdef COLS80      ; y*80 = y*40 *2
      asl
      rol vdp_ptr+1
  .endif
      adc crs_x
      sta a_vreg

      lda #(WRITE_ADDRESS + >ADDRESS_TEXT_SCREEN)
      adc vdp_ptr+1  ; add carry and page to address high byte
      vdp_wait_s 4
      sta a_vreg
      rts
.endif
