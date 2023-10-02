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

.zeropage
ptr3: .res 2
ptr4: .res 2

.code
ROWS=23
.ifdef CHAR6x8
  .import charset_6x8
  .ifdef COLS80
    .ifndef V9958
      .assert 0, error, "80 COLUMNS ARE SUPPORTED ON V9958 ONLY! MAKE SURE -DV9958 IS ENABLED"
    .endif
    COLS=80
  .else
    COLS=40
  .endif
.else
  COLS=32
  .import charset_8x8
.endif

.code

vdp_scroll_up:
      SetVector  (ADDRESS_TEXT_SCREEN+COLS), ptr3            ; +COLS - offset second row
      SetVector  (ADDRESS_TEXT_SCREEN+(WRITE_ADDRESS<<8)), ptr4  ; offset first row as "write adress"
@l1:
@l2:
      lda  ptr3+0  ; 3cl
      sta  a_vreg
      nop
      lda  ptr3+1  ; 3cl
      sta  a_vreg
      vdp_wait_l    ; wait 2µs, 8Mhz = 16cl => 8 nop
      ldx  a_vram  ;
      vdp_wait_l

      lda  ptr4+0  ; 3cl
      sta  a_vreg
      vdp_wait_l
      lda  ptr4+1  ; 3cl
      sta a_vreg
      vdp_wait_l
      stx  a_vram
      inc  ptr3+0  ; 5cl
      bne  @l3    ; 3cl
      inc  ptr3+1
      lda  ptr3+1
      cmp  #>(ADDRESS_TEXT_SCREEN+(COLS * 24 + (COLS * 24 .MOD 256)))  ;screen ram $1800 - $1b00
      beq  @l4
@l3:
      inc  ptr4+0  ; 5cl
      bne  @l2    ; 3cl
      inc  ptr4+1
      bra  @l1
@l4:
      ldx  #COLS  ; write address is already setup from loop
      lda  #' '
@l5:
      sta  a_vram
      vdp_wait_l
      dex
      bne  @l5
      rts

_inc_cursor_y:
      lda crs_y
      cmp  #ROWS    ;last line ?
      bne  @l1
      bra  vdp_scroll_up  ; scroll up, dont inc y, exit
@l1:
      inc crs_y
      rts

vdp_charout:
      cmp  #KEY_CR      ;cariage return ?
      bne  @l1
      stz  crs_x
      rts
@l1:
      cmp  #CODE_LF      ;line feed
      bne  @l2
      stz  crs_x
      bra  _inc_cursor_y
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
      bra  vdp_putchar

@l3:
      jsr  vdp_putchar
      lda  crs_x
      cmp  #(COLS-1)
      beq @l7
      inc  crs_x
@l6:
      rts
@l7:
      stz  crs_x
      bra  _inc_cursor_y

vdp_putchar:
      pha
      jsr vdp_set_addr
      pla
      vdp_wait_l 8
      sta a_vram
      rts

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
v_l=tmp1
v_h=tmp2
vdp_set_addr:      ; set the vdp vram adress, write A to vram
    stz v_h
    lda crs_y
    asl
    asl
    asl        ; crs_y*8

.ifdef COLS80
    ; crs_y*64 + crs_y*16 (crs_ptr) => y*80
    asl        ; y*16
    sta v_l
    rol v_h         ; save carry if overflow
.else
    ; crs_y*32 + crs_y*8  (crs_ptr) => y*40
    sta v_l      ; save
.endif

    asl
    rol v_h       ; save carry if overflow
    asl        ;
    rol v_h      ; save carry if overflow
    clc
    adc v_l

    bcc @l1
    inc v_h      ; overflow inc page count
    clc        ;
@l1:
    adc crs_x    ; add x to address
    sta a_vreg
    lda #(WRITE_ADDRESS + >ADDRESS_TEXT_SCREEN)
    adc v_h      ; add carry and page to address high byte
    vdp_wait_s 4
    sta a_vreg
    rts
.endif
